import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/utils/constants.dart';
import '../domain/auth_models.dart';

/// All authentication operations — registration code validation, PIN setup,
/// and PIN login.
class AuthRepository {
  final AppDatabase _db;

  const AuthRepository({required AppDatabase db}) : _db = db;

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
    final patientDocId = codeData['patientFirestoreDocId'] as String;

    // ── Already activated ──────────────────────────────────────────────────
    // The account exists in Firestore. This device may be a second device or
    // a reinstall — pull the full patient record (including pinHash) so the
    // user can log in with their existing PIN without going through setup again.
    if (codeData['isActivated'] == true) {
      // If we already have a local record (e.g. mid-registration retry), reuse it.
      final existing = await _db.patientsDao.getPatientByActivationCode(code);
      if (existing != null) {
        final needsSetup = existing.pinHash.isEmpty;
        return AuthSuccess(existing.id, needsPinSetup: needsSetup);
      }

      // Pull the patient document from Firestore, including the pinHash that
      // was saved when the account was first activated.
      final patientDoc =
          await fs.collection(kColPatients).doc(patientDocId).get();
      if (!patientDoc.exists) {
        return const AuthFailure(
          'Patient record not found. Please contact your clinic.',
        );
      }

      final pd = patientDoc.data()!;
      final existingPin = pd['pinHash'] as String? ?? '';

      final localId = await _db.patientsDao.insertPatient(
        PatientsCompanion(
          registrationCode: Value(pd['registrationCode'] as String? ?? ''),
          fullName: Value(pd['fullName'] as String? ?? ''),
          phoneNumber: Value(pd['phoneNumber'] as String? ?? ''),
          dateOfBirth: Value(pd['dateOfBirth'] as String? ?? ''),
          gender: Value(pd['gender'] as String? ?? 'other'),
          pinHash: Value(existingPin),
          activationCode: Value(code),
          conditions: Value(pd['conditions'] as String?),
          caregiverPhone: Value(pd['caregiverPhone'] as String?),
          isActivated: const Value(true),
          isSynced: const Value(true),
        ),
      );

      await _pullMedsAndReminders(
        firestorePatientId: patientDocId,
        localPatientId: localId,
      );

      // PIN already set → send straight to login.
      return AuthSuccess(localId, needsPinSetup: existingPin.isEmpty);
    }

    // ── First activation ───────────────────────────────────────────────────
    // Check if we already created a local record during a previous attempt.
    final patient = await _db.patientsDao.getPatientByActivationCode(code);
    if (patient != null) {
      return AuthSuccess(patient.id);
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
      firestorePatientId: patientDocId,
      localPatientId: localId,
    );

    return AuthSuccess(localId);
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
    return AuthSuccess(patient.id);
  }

  /// Pulls all medications and reminders for a patient from Firestore and
  /// inserts them into the local Drift DB, remapping medication IDs.
  /// [firestorePatientId] is the Firestore document ID string for the patient.
  Future<void> _pullMedsAndReminders({
    required String firestorePatientId,
    required int localPatientId,
  }) async {
    final fs = FirebaseFirestore.instance;

    final medSnap = await fs
        .collection(kColMedications)
        .where('patientFirestoreDocId', isEqualTo: firestorePatientId)
        .get();

    // Firestore med doc ID → new local Drift medId
    final medIdMap = <String, int>{};

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
      medIdMap[doc.id] = newMedId;
    }

    final remSnap = await fs
        .collection(kColReminders)
        .where('patientFirestoreDocId', isEqualTo: firestorePatientId)
        .get();

    for (final doc in remSnap.docs) {
      final d = doc.data();
      final medDocId = d['medicationFirestoreDocId'] as String? ?? '';
      final newMedId = medIdMap[medDocId];
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
  /// as used in both Drift and Firestore, then saves the local session.
  Future<AuthResult> setupPin(int patientId, String pin) async {
    try {
      final hash = AuthService.hashPin(pin);
      await _db.patientsDao.updatePinHash(patientId, hash);
      await _db.patientsDao.markAsActivated(patientId);

      // Push PIN hash + activation status to Firestore.
      if (kFirebaseConfigured) {
        final patient = await _db.patientsDao.getPatientById(patientId);
        if (patient?.activationCode != null) {
          try {
            final fs = FirebaseFirestore.instance;
            final activationCode = patient!.activationCode!;

            // Look up the patient's Firestore document ID from the activation
            // code doc — this is guaranteed to exist and avoids a field query.
            final codeDoc = await fs
                .collection(kColActivationCodes)
                .doc(activationCode)
                .get();

            if (codeDoc.exists) {
              final patientDocId =
                  codeDoc.data()!['patientFirestoreDocId'] as String?;

              if (patientDocId != null) {
                // Write pinHash directly to the patient document so other
                // devices can pull it when the user enters the same code.
                await fs.collection(kColPatients).doc(patientDocId).update({
                  'pinHash': hash,
                  'isActivated': true,
                  'activatedAt': FieldValue.serverTimestamp(),
                });
              }

              // Mark the activation code as used.
              await codeDoc.reference.update({
                'isActivated': true,
                'activatedAt': FieldValue.serverTimestamp(),
              });
            }
          } catch (_) {
            // Firestore write failed — isSynced=false ensures sync_service
            // retries on next connectivity restore.
          }
        }
      }

      await _db.patientsDao.updatePatientFields(
        patientId,
        PatientsCompanion(isSynced: const Value(false)),
      );
      await AuthService.saveSession(patientId);
      return AuthSuccess(patientId);
    } catch (e) {
      return AuthFailure('Could not save PIN: $e');
    }
  }

  // ── PIN login ──────────────────────────────────────────────────────────────

  /// Finds the activated patient on this device and verifies their PIN.
  Future<AuthResult> login(String pin) async {
    try {
      final all = await _db.patientsDao.getAllPatients();
      if (all.isEmpty) {
        return const AuthFailure('No account found. Please register first.');
      }
      // Use the first activated patient on the device.
      final patient = all.firstWhere(
        (p) => p.pinHash.isNotEmpty,
        orElse: () => all.first,
      );
      if (patient.pinHash.isEmpty) {
        return const AuthFailure('PIN not set. Please complete registration.');
      }
      if (!AuthService.verifyPin(pin, patient.pinHash)) {
        return const AuthFailure('Incorrect PIN. Please try again.');
      }
      await AuthService.saveSession(patient.id);
      return AuthSuccess(patient.id);
    } catch (e) {
      return AuthFailure('Login failed: $e');
    }
  }
}
