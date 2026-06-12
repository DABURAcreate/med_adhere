import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';

/// Data for updating one medication's schedule from MedicationScheduleScreen.
class MedScheduleEntry {
  final int? existingId; // null = new medication to insert
  final String name;
  final String dosage;
  final List<String> times; // HH:mm strings
  final bool active;

  const MedScheduleEntry({
    this.existingId,
    required this.name,
    required this.dosage,
    required this.times,
    required this.active,
  });
}

/// Data for one medication + its reminder times collected from the UI.
class MedicationRegistrationData {
  final String name;
  final String dosage;
  final int timesPerDay;
  final List<String> reminderTimes; // HH:mm strings

  const MedicationRegistrationData({
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.reminderTimes,
  });
}

/// Returned by [PatientMgmtRepository.registerPatient].
sealed class RegistrationResult {
  const RegistrationResult();
}

final class RegistrationSuccess extends RegistrationResult {
  final int patientId;
  final String activationCode;
  const RegistrationSuccess({
    required this.patientId,
    required this.activationCode,
  });
}

final class RegistrationFailure extends RegistrationResult {
  final String message;
  const RegistrationFailure(this.message);
}

/// Handles healthcare-worker operations: registering patients and saving their
/// medication schedules to both the local Drift DB and Firestore.
class PatientMgmtRepository {
  final AppDatabase _db;
  final FirebaseFirestore? _firestore;

  PatientMgmtRepository({required AppDatabase db})
      : _db = db,
        _firestore = kFirebaseConfigured ? FirebaseFirestore.instance : null;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Registers a new patient record, saves medications and reminders, and
  /// pushes everything to Firestore.  Returns the activation code that the
  /// worker should hand to the patient.
  Future<RegistrationResult> registerPatient({
    required String fullName,
    required String clinicCode,
    required String conditions,
    String? clinicName,
    String? caregiverPhone,
    required List<MedicationRegistrationData> medications,
  }) async {
    try {
      final code = await _generateUniqueActivationCode();
      final now = DateTime.now();
      final caregiver =
          (caregiverPhone == null || caregiverPhone.isEmpty) ? null : caregiverPhone;
      final resolvedClinicName =
          (clinicName == null || clinicName.isEmpty) ? null : clinicName;

      // 1. Persist patient locally.
      final patientId = await _db.patientsDao.insertPatient(
        PatientsCompanion(
          registrationCode: Value(clinicCode),
          fullName: Value(fullName),
          phoneNumber: const Value(''),
          dateOfBirth: const Value(''),
          gender: const Value('other'),
          pinHash: const Value(''),
          caregiverPhone: Value(caregiver),
          clinicName: Value(resolvedClinicName),
          activationCode: Value(code),
          conditions: Value(conditions.isEmpty ? null : conditions),
          isActivated: const Value(false),
          isSynced: const Value(false),
        ),
      );

      // 2. Persist medications + reminders locally.
      for (final med in medications) {
        final medId = await _db.medicationsDao.insertMedication(
          MedicationsCompanion(
            patientId: Value(patientId),
            name: Value(med.name),
            dosage: Value(med.dosage),
            frequency: Value(med.timesPerDay == 1 ? 'daily' : 'custom'),
            customTimes: Value(med.reminderTimes.join(',')),
            startDate: Value(now.toIso8601String().substring(0, 10)),
            isSynced: const Value(false),
          ),
        );

        for (final time in med.reminderTimes) {
          await _db.remindersDao.insertReminder(
            RemindersCompanion(
              patientId: Value(patientId),
              medicationId: Value(medId),
              scheduledTime: Value(time),
              isSynced: const Value(false),
            ),
          );
        }
      }

      // 3. Push to Firestore immediately so the patient can activate right away.
      if (_firestore != null) {
        await _pushRegistrationToFirestore(
          patientId: patientId,
          fullName: fullName,
          clinicCode: clinicCode,
          clinicName: resolvedClinicName,
          conditions: conditions,
          caregiverPhone: caregiver,
          activationCode: code,
        );
      }

      return RegistrationSuccess(patientId: patientId, activationCode: code);
    } catch (e) {
      return RegistrationFailure(e.toString());
    }
  }

  // ── Schedule management ────────────────────────────────────────────────────

  /// Load a patient by local DB id.
  Future<Patient?> getPatientById(int id) => _db.patientsDao.getPatientById(id);

  /// Load a patient by their registration / clinic code.
  Future<Patient?> getPatientByRegistrationCode(String code) =>
      _db.patientsDao.getPatientByRegistrationCode(code);

  /// Load all medications + their reminders for a patient.
  Future<List<Medication>> getMedicationsForPatient(int patientId) =>
      _db.medicationsDao.getMedicationsForPatient(patientId);

  Future<List<Reminder>> getRemindersForPatient(int patientId) =>
      _db.remindersDao.getRemindersForPatient(patientId);

  /// Persist an updated medication schedule.
  ///
  /// For existing medications: updates fields + replaces all reminders.
  /// For new entries (existingId == null): inserts medication + reminders.
  /// Medications whose DB ids are in [removedIds] are deactivated (not deleted
  /// so that adherence history is preserved).
  Future<void> saveMedicationSchedule({
    required int patientId,
    required List<MedScheduleEntry> entries,
    required List<int> removedIds,
  }) async {
    await _db.runInTransaction(() async {
      for (final id in removedIds) {
        await _db.medicationsDao.setMedicationActive(id, isActive: false);
        await _db.remindersDao.deactivateRemindersForMedication(id);
      }

      for (final entry in entries) {
        int medId;
        final now = DateTime.now();

        if (entry.existingId != null) {
          medId = entry.existingId!;
          await _db.medicationsDao.updateMedicationFields(
            medId,
            MedicationsCompanion(
              name: Value(entry.name),
              dosage: Value(entry.dosage),
              frequency: Value(
                  entry.times.length == 1 ? 'daily' : 'custom'),
              customTimes: Value(entry.times.join(',')),
              isActive: Value(entry.active),
              isSynced: const Value(false),
              updatedAt: Value(now),
            ),
          );
          // Replace reminders: delete old, insert new
          await _db.remindersDao.deleteRemindersForMedication(medId);
        } else {
          medId = await _db.medicationsDao.insertMedication(
            MedicationsCompanion(
              patientId: Value(patientId),
              name: Value(entry.name),
              dosage: Value(entry.dosage),
              frequency: Value(
                  entry.times.length == 1 ? 'daily' : 'custom'),
              customTimes: Value(entry.times.join(',')),
              startDate: Value(now.toIso8601String().substring(0, 10)),
              isActive: Value(entry.active),
              isSynced: const Value(false),
            ),
          );
        }

        if (entry.active) {
          for (final time in entry.times) {
            await _db.remindersDao.insertReminder(
              RemindersCompanion(
                patientId: Value(patientId),
                medicationId: Value(medId),
                scheduledTime: Value(time),
                isActive: const Value(true),
                isSynced: const Value(false),
              ),
            );
          }
        }
      }

      // Mark patient as unsynced so sync picks up the schedule change
      await _db.patientsDao.updatePatientFields(
        patientId,
        PatientsCompanion(
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns a 5-digit string that does not yet exist in the
  /// Firestore activation_codes collection.  Retries up to 10 times.
  Future<String> _generateUniqueActivationCode() async {
    final rand = Random.secure();
    for (int i = 0; i < 10; i++) {
      final code = (10000 + rand.nextInt(90000)).toString();
      if (_firestore == null) return code; // offline: skip uniqueness check
      final doc =
          await _firestore.collection(kColActivationCodes).doc(code).get();
      if (!doc.exists) return code;
    }
    throw Exception(
      'Could not generate a unique activation code after 10 attempts.',
    );
  }

  /// Writes the patient, activation code, medications, and reminders to
  /// Firestore and marks the corresponding Drift rows as synced.
  Future<void> _pushRegistrationToFirestore({
    required int patientId,
    required String fullName,
    required String clinicCode,
    String? clinicName,
    required String conditions,
    required String? caregiverPhone,
    required String activationCode,
  }) async {
    final fs = _firestore!;
    final serverNow = FieldValue.serverTimestamp();

    // Batch 1: patient document + activation code document.
    final batch1 = fs.batch();

    batch1.set(
      fs.collection(kColPatients).doc(patientId.toString()),
      {
        'localId': patientId,
        'registrationCode': clinicCode,
        'fullName': fullName,
        'conditions': conditions,
        'caregiverPhone': caregiverPhone,
        'clinicName': ?clinicName,
        'riskLevel': kRiskLow,
        'activationCode': activationCode,
        'isActivated': false,
        'activatedAt': null,
        'createdAt': serverNow,
        'updatedAt': serverNow,
      },
      SetOptions(merge: true),
    );

    // activation_codes/{code} — doc ID is the code itself for O(1) lookup.
    batch1.set(
      fs.collection(kColActivationCodes).doc(activationCode),
      {
        'patientFirestoreDocId': patientId.toString(),
        'fullName': fullName,
        'clinicCode': clinicCode,
        'conditions': conditions,
        'isActivated': false,
        'activatedAt': null,
        'createdAt': serverNow,
      },
    );

    await batch1.commit();
    await _db.patientsDao.markAsSynced(patientId);

    // Batch 2: medications.
    final meds = await _db.medicationsDao.getMedicationsForPatient(patientId);
    if (meds.isNotEmpty) {
      final batch2 = fs.batch();
      for (final m in meds) {
        batch2.set(
          fs.collection(kColMedications).doc(m.id.toString()),
          {
            'localId': m.id,
            'patientId': patientId,
            'name': m.name,
            'dosage': m.dosage,
            'frequency': m.frequency,
            'customTimes': m.customTimes,
            'startDate': m.startDate,
            'isActive': m.isActive,
            'createdAt': serverNow,
            'updatedAt': serverNow,
          },
          SetOptions(merge: true),
        );
      }
      await batch2.commit();
      for (final m in meds) {
        await _db.medicationsDao.markAsSynced(m.id);
      }
    }

    // Batch 3: reminders.
    final reminders =
        await _db.remindersDao.getRemindersForPatient(patientId);
    if (reminders.isNotEmpty) {
      final batch3 = fs.batch();
      for (final r in reminders) {
        batch3.set(
          fs.collection(kColReminders).doc(r.id.toString()),
          {
            'localId': r.id,
            'patientId': patientId,
            'medicationId': r.medicationId,
            'scheduledTime': r.scheduledTime,
            'deliveryChannel': r.deliveryChannel,
            'isActive': r.isActive,
            'createdAt': serverNow,
            'updatedAt': serverNow,
          },
          SetOptions(merge: true),
        );
      }
      await batch3.commit();
      for (final r in reminders) {
        await _db.remindersDao.markAsSynced(r.id);
      }
    }
  }
}
