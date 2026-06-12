import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/utils/constants.dart';
import '../domain/auth_models.dart';

/// All authentication operations — registration code validation, PIN setup,
/// PIN login, and worker registration.
class AuthRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  AuthRepository({
    required AppDatabase db,
    required ConnectivityService connectivity,
  })  : _db = db,
        _connectivity = connectivity;

  // ── Existing-user check ────────────────────────────────────────────────────

  /// True when at least one activated patient record exists on this device.
  Future<bool> isExistingUser() async {
    final all = await _db.patientsDao.getAllPatients();
    return all.any((p) => p.pinHash.isNotEmpty);
  }

  // ── Activation code flow ───────────────────────────────────────────────────

  /// Validates the 5-digit activation code.
  ///
  /// When Firebase is configured:
  ///   - Looks up `activation_codes/{code}` in Firestore (O(1) doc read).
  ///   - Rejects codes that don't exist or are already activated.
  ///   - Pulls the patient's data, medications, and reminders from Firestore
  ///     into the local Drift DB (if not already present).
  ///
  /// When offline / Firebase not configured:
  ///   - Falls back to a local DB lookup by activation_code column.
  Future<AuthResult> lookupOrCreateByCode(String code) async {
    try {
      if (kFirebaseConfigured) {
        return await _lookupFromFirestore(code);
      }
      return await _lookupFromLocalDb(code);
    } catch (e) {
      return AuthFailure('Could not validate activation code: $e');
    }
  }

  Future<AuthResult> _lookupFromFirestore(String code) async {
    final fs = FirebaseFirestore.instance;

    final codeDoc = await fs.collection(kColActivationCodes).doc(code).get();

    if (!codeDoc.exists) {
      return const AuthFailure(
        'Invalid activation code. Please check with your clinic.',
      );
    }

    final codeData = codeDoc.data()!;
    if (codeData['isActivated'] == true) {
      return const AuthFailure(
        'This activation code has already been used.',
      );
    }

    final patientDocId = codeData['patientFirestoreDocId'] as String;

    // Check if we already created a local record during a previous attempt.
    var patient = await _db.patientsDao.getPatientByActivationCode(code);
    if (patient != null) {
      return AuthSuccess(role: AuthRole.patient, userId: patient.id.toString());
    }

    // Pull patient document from Firestore.
    final patientDoc =
        await fs.collection(kColPatients).doc(patientDocId).get();
    if (!patientDoc.exists) {
      return const AuthFailure(
        'Patient record not found. Please contact your clinic.',
      );
    }

    final pd = patientDoc.data()!;

    final localId = await _db.patientsDao.insertPatient(
      PatientsCompanion(
        registrationCode: Value(pd['registrationCode'] as String? ?? ''),
        fullName: Value(pd['fullName'] as String? ?? ''),
        phoneNumber: const Value(''),
        dateOfBirth: const Value(''),
        gender: const Value('other'),
        pinHash: const Value(''),
        activationCode: Value(code),
        conditions: Value(pd['conditions'] as String?),
        caregiverPhone: Value(pd['caregiverPhone'] as String?),
        isActivated: const Value(false),
        isSynced: const Value(true),
      ),
    );

    // Pull medications and reminders so the patient sees their schedule
    // immediately after PIN setup.
    await _pullMedsAndReminders(
      firestorePatientId: int.tryParse(patientDocId) ?? 0,
      localPatientId: localId,
    );

    return AuthSuccess(role: AuthRole.patient, userId: localId.toString());
  }

  Future<AuthResult> _lookupFromLocalDb(String code) async {
    final patient = await _db.patientsDao.getPatientByActivationCode(code);
    if (patient == null) {
      return const AuthFailure(
        'Activation code not found. Connect to the internet to activate.',
      );
    }
    if (patient.isActivated) {
      return const AuthFailure(
        'This activation code has already been used.',
      );
    }
    return AuthSuccess(role: AuthRole.patient, userId: patient.id.toString());
  }

  /// Pulls all medications and reminders for a patient from Firestore and
  /// inserts them into the local Drift DB, remapping patient/medication IDs.
  Future<void> _pullMedsAndReminders({
    required int firestorePatientId,
    required int localPatientId,
  }) async {
    final fs = FirebaseFirestore.instance;

    final medSnap = await fs
        .collection(kColMedications)
        .where('patientId', isEqualTo: firestorePatientId)
        .get();

    final medIdMap = <int, int>{};

    for (final doc in medSnap.docs) {
      final d = doc.data();
      final newMedId = await _db.medicationsDao.insertMedication(
        MedicationsCompanion(
          patientId: Value(localPatientId),
          name: Value(d['name'] as String? ?? ''),
          dosage: Value(d['dosage'] as String? ?? ''),
          frequency: Value(d['frequency'] as String? ?? 'custom'),
          customTimes: Value(d['customTimes'] as String?),
          startDate: Value(
            d['startDate'] as String? ??
                DateTime.now().toIso8601String().substring(0, 10),
          ),
          isActive: Value(d['isActive'] as bool? ?? true),
          isSynced: const Value(true),
        ),
      );
      medIdMap[d['localId'] as int? ?? 0] = newMedId;
    }

    final remSnap = await fs
        .collection(kColReminders)
        .where('patientId', isEqualTo: firestorePatientId)
        .get();

    for (final doc in remSnap.docs) {
      final d = doc.data();
      final oldMedId = d['medicationId'] as int? ?? 0;
      final newMedId = medIdMap[oldMedId];
      if (newMedId == null) continue;

      await _db.remindersDao.insertReminder(
        RemindersCompanion(
          patientId: Value(localPatientId),
          medicationId: Value(newMedId),
          scheduledTime: Value(d['scheduledTime'] as String? ?? '08:00'),
          deliveryChannel: Value(d['deliveryChannel'] as String? ?? 'push'),
          isActive: Value(d['isActive'] as bool? ?? true),
          isSynced: const Value(true),
        ),
      );
    }
  }

  // ── PIN setup ──────────────────────────────────────────────────────────────

  /// Hashes [pin], stores it on the patient record, marks the activation code
  /// as used, saves the PIN hash to Firestore for cross-device recovery, then
  /// persists the local session.
  Future<AuthResult> setupPin(int patientId, String pin) async {
    try {
      final hash = AuthService.hashPin(pin);
      await _db.patientsDao.updatePinHash(patientId, hash);
      await _db.patientsDao.markAsActivated(patientId);

      if (kFirebaseConfigured) {
        final patient = await _db.patientsDao.getPatientById(patientId);
        if (patient?.activationCode != null) {
          try {
            final fs = FirebaseFirestore.instance;
            final activationCode = patient!.activationCode!;

            // Mark the activation code as used.
            await fs
                .collection(kColActivationCodes)
                .doc(activationCode)
                .update({
              'isActivated': true,
              'activatedAt': FieldValue.serverTimestamp(),
            });

            // Update the patient document: mark activated AND store pinHash
            // so the patient can recover their account from a new device.
            await fs
                .collection(kColPatients)
                .where('activationCode', isEqualTo: activationCode)
                .limit(1)
                .get()
                .then((snap) {
              for (final doc in snap.docs) {
                doc.reference.update({
                  'isActivated': true,
                  'activatedAt': FieldValue.serverTimestamp(),
                  'pinHash': hash,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
            });
          } catch (_) {
            // Firestore update failed — the local record is already updated.
            // SyncService will push isSynced=false rows on next connectivity
            // restore, but pinHash is intentionally excluded from that sync.
            // If recovery is needed before the next online session, the patient
            // will need to re-enter their activation code.
          }
        }
      }

      await _db.patientsDao.updatePatientFields(
        patientId,
        PatientsCompanion(isSynced: const Value(false)),
      );
      await AuthService.saveSession(patientId: patientId);
      return AuthSuccess(role: AuthRole.patient, userId: patientId.toString());
    } catch (e) {
      return AuthFailure('Could not save PIN: $e');
    }
  }

  // ── PIN login ──────────────────────────────────────────────────────────────

  /// Login order:
  ///   1. Local Drift patients (offline-capable, primary path).
  ///   2. Firestore workers (online; workers are cloud-only).
  ///   3. Firestore patients (online; recovery for new/reinstalled devices).
  ///
  /// The Firestore patient fallback stores the hash in Firestore so that
  /// patients can sign in on a replacement device without their activation code.
  ///
  /// SECURITY NOTE: querying by PIN hash alone is safe for a single-user local
  /// DB, but on Firestore two patients could share the same 4-digit PIN.
  /// For production recovery, combine PIN with a second identifier such as
  /// the registration code or a phone number OTP.
  Future<AuthResult> login(String pin) async {
    try {
      final pinHash = AuthService.hashPin(pin);
      debugPrint('[Auth] Local login attempt started.');

      // ── Phase 1: local Drift patients ──────────────────────────────────────
      final patients = await _db.patientsDao.getAllPatients();
      for (final patient in patients) {
        if (patient.pinHash.isNotEmpty && patient.pinHash == pinHash) {
          debugPrint('[Auth] Patient found locally (id=${patient.id}).');
          await AuthService.saveSession(patientId: patient.id);
          return AuthSuccess(
            role: AuthRole.patient,
            userId: patient.id.toString(),
          );
        }
      }
      debugPrint('[Auth] No local patient match.');

      // ── Phase 2: Cached workers (offline-capable) ──────────────────────────
      debugPrint('[Auth] Checking local worker cache...');
      final cachedWorker =
          await AuthService.lookupCachedWorkerByPinHash(pinHash);
      if (cachedWorker != null) {
        final workerId = cachedWorker['workerId'] as String;
        final clinicName = cachedWorker['clinicName'] as String?;
        final fullName = cachedWorker['fullName'] as String?;
        debugPrint('[Auth] Worker found in local cache (id=$workerId).');
        await AuthService.saveSession(
          workerId: workerId,
          workerClinicName: clinicName,
          workerFullName: fullName,
        );
        return AuthSuccess(
          role: AuthRole.worker,
          userId: workerId,
          workerClinicName: clinicName,
          workerFullName: fullName,
        );
      }

      // ── Phase 3 & 4: Firestore fallback (requires connectivity) ───────────
      if (!kFirebaseConfigured) {
        return patients.isEmpty
            ? const AuthFailure('No account found. Please register first.')
            : const AuthFailure('Incorrect PIN. Please try again.');
      }

      final connected = await _connectivity.isConnected;
      if (!connected) {
        debugPrint('[Auth] Offline — Firestore fallback skipped.');
        return patients.isEmpty
            ? const AuthFailure(
                'No local account found. Connect to the internet to restore your account.',
              )
            : const AuthFailure('Incorrect PIN. Please try again.');
      }

      final fs = FirebaseFirestore.instance;

      // ── Phase 3: Firestore workers ─────────────────────────────────────────
      debugPrint('[Auth] Checking Firestore workers...');
      final workerSnap = await fs
          .collection(kColWorkers)
          .where('pinHash', isEqualTo: pinHash)
          .limit(1)
          .get();
      if (workerSnap.docs.isNotEmpty) {
        final doc = workerSnap.docs.first;
        final workerId = doc.id;
        final workerData = doc.data();
        final clinicName = workerData['clinicName'] as String?;
        final fullName = workerData['fullName'] as String?;
        debugPrint('[Auth] Worker found in Firestore (id=$workerId, clinic=$clinicName).');
        // Cache credentials for future offline logins.
        await AuthService.cacheWorker(
          workerId: workerId,
          pinHash: pinHash,
          fullName: fullName,
          clinicName: clinicName,
        );
        await AuthService.saveSession(
          workerId: workerId,
          workerClinicName: clinicName,
          workerFullName: fullName,
        );
        return AuthSuccess(
          role: AuthRole.worker,
          userId: workerId,
          workerClinicName: clinicName,
          workerFullName: fullName,
        );
      }
      debugPrint('[Auth] No Firestore worker match.');

      // ── Phase 4: Firestore patient recovery (new / reinstalled device) ─────
      debugPrint('[Auth] Checking Firestore patients for recovery...');
      final patientSnap = await fs
          .collection(kColPatients)
          .where('pinHash', isEqualTo: pinHash)
          .where('isActivated', isEqualTo: true)
          .limit(1)
          .get();

      if (patientSnap.docs.isNotEmpty) {
        debugPrint('[Auth] Patient found in Firestore — caching locally...');
        final localId = await _cachePatientLocally(patientSnap.docs.first);
        await AuthService.saveSession(patientId: localId);
        return AuthSuccess(role: AuthRole.patient, userId: localId.toString());
      }
      debugPrint('[Auth] No Firestore patient match.');

      return patients.isEmpty
          ? const AuthFailure('No account found. Please register first.')
          : const AuthFailure('Incorrect PIN. Please try again.');
    } catch (e) {
      return AuthFailure('Login failed: $e');
    }
  }

  /// Downloads a Firestore patient document into the local Drift DB.
  ///
  /// Checks for an existing local record by registration code first to avoid
  /// duplicates. If the patient already exists locally (e.g., stale session was
  /// cleared but the DB wasn't), it refreshes the stored PIN hash and returns
  /// the existing local ID.
  ///
  /// After inserting, attempts to pull medications and reminders from Firestore
  /// using the Firestore-side [localId] field so the patient sees their schedule
  /// immediately.
  Future<int> _cachePatientLocally(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final regCode = data['registrationCode'] as String? ?? '';

    // Avoid creating a duplicate if this patient is already in local DB.
    final existing = await _db.patientsDao.getPatientByRegistrationCode(regCode);
    if (existing != null) {
      final remoteHash = data['pinHash'] as String? ?? '';
      if (existing.pinHash != remoteHash && remoteHash.isNotEmpty) {
        await _db.patientsDao.updatePinHash(existing.id, remoteHash);
      }
      debugPrint('[Auth] Patient already cached locally (id=${existing.id}).');
      return existing.id;
    }

    final localId = await _db.patientsDao.insertPatient(
      PatientsCompanion(
        registrationCode: Value(regCode),
        fullName: Value(data['fullName'] as String? ?? ''),
        phoneNumber: const Value(''),
        dateOfBirth: const Value(''),
        gender: const Value('other'),
        pinHash: Value(data['pinHash'] as String? ?? ''),
        activationCode: Value(data['activationCode'] as String?),
        conditions: Value(data['conditions'] as String?),
        caregiverPhone: Value(data['caregiverPhone'] as String?),
        riskLevel: Value(data['riskLevel'] as String? ?? kRiskLow),
        isActivated: const Value(true),
        isSynced: const Value(true),
      ),
    );

    // Pull medications + reminders using the Firestore document's stored localId
    // (which is the original local ID from the worker's device).
    final firestoreLocalId = data['localId'] as int?;
    if (firestoreLocalId != null) {
      try {
        await _pullMedsAndReminders(
          firestorePatientId: firestoreLocalId,
          localPatientId: localId,
        );
        debugPrint('[Auth] Medications/reminders pulled for restored patient.');
      } catch (_) {
        // Non-fatal: the patient is signed in; they may see an empty schedule
        // until the next sync cycle pulls their data.
        debugPrint('[Auth] Could not pull medications — schedule may be empty initially.');
      }
    }

    return localId;
  }

  // ── Worker registration ────────────────────────────────────────────────────

  /// Creates a new worker document in Firestore.
  ///
  /// Validates that [staffNumber] is unique before writing.
  /// [pin] is hashed with the same SHA-256 method used for patients.
  Future<AuthResult> registerWorker({
    required String fullName,
    required String staffNumber,
    String? clinicName,
    required String pin,
  }) async {
    try {
      if (!kFirebaseConfigured) {
        return const AuthFailure(
          'Worker registration requires an internet connection.',
        );
      }

      final fs = FirebaseFirestore.instance;

      // Enforce unique staff number.
      final existing = await fs
          .collection(kColWorkers)
          .where('staffNumber', isEqualTo: staffNumber.trim())
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return const AuthFailure(
          'A worker with this staff number already exists.',
        );
      }

      final pinHash = AuthService.hashPin(pin);
      final docRef = await fs.collection(kColWorkers).add({
        'fullName': fullName.trim(),
        'staffNumber': staffNumber.trim(),
        if (clinicName != null && clinicName.trim().isNotEmpty)
          'clinicName': clinicName.trim(),
        'pinHash': pinHash,
        'role': 'worker',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AuthSuccess(role: AuthRole.worker, userId: docRef.id);
    } catch (e) {
      return AuthFailure('Registration failed: $e');
    }
  }
}
