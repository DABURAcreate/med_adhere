import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';

/// Wraps PatientsDao and MedicationsDao with business-level operations
/// used by patient-facing screens.
///
/// Screens call this — never the DAOs directly.
class PatientRepository {
  final AppDatabase _db;

  const PatientRepository({required AppDatabase db}) : _db = db;

  // ── Patient queries ────────────────────────────────────────────────────────

  Future<Patient?> getPatient(int id) => _db.patientsDao.getPatientById(id);

  Stream<Patient?> watchPatient(int id) => _db.patientsDao.watchPatientById(id);

  Future<Patient?> getPatientByCode(String code) =>
      _db.patientsDao.getPatientByRegistrationCode(code);

  /// Registers a new patient locally. Returns the generated local id.
  Future<int> registerPatient({
    required String registrationCode,
    required String fullName,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    String language = 'en',
    required String pinHash,
  }) =>
      _db.patientsDao.insertPatient(
        PatientsCompanion(
          registrationCode: Value(registrationCode),
          fullName: Value(fullName),
          phoneNumber: Value(phoneNumber),
          dateOfBirth: Value(dateOfBirth),
          gender: Value(gender),
          language: Value(language),
          pinHash: Value(pinHash),
        ),
      );

  Future<void> updateLanguage(int patientId, String languageCode) =>
      _db.patientsDao.updatePatientFields(
        patientId,
        PatientsCompanion(
          language: Value(languageCode),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> linkCaregiver(int patientId, String? phone) =>
      _db.patientsDao.updateCaregiverPhone(patientId, phone);

  // ── Medication queries ─────────────────────────────────────────────────────

  Future<List<Medication>> getMedications(int patientId) =>
      _db.medicationsDao.getMedicationsForPatient(patientId);

  Stream<List<Medication>> watchMedications(int patientId) =>
      _db.medicationsDao.watchMedicationsForPatient(patientId);

  Stream<List<Medication>> watchActiveMedications(int patientId) =>
      _db.medicationsDao.watchActiveMedicationsForPatient(patientId);

  Future<Medication?> getMedication(int id) =>
      _db.medicationsDao.getMedicationById(id);

  Stream<Medication?> watchMedication(int id) =>
      _db.medicationsDao.watchMedicationById(id);

  /// Logs a dose as taken and decrements stock.
  Future<void> logDoseTaken(int medicationId) async {
    await _db.medicationsDao.decrementStock(medicationId);
  }

  Future<void> setMedicationActive(int id, {required bool isActive}) async {
    await _db.runInTransaction(() async {
      await _db.medicationsDao.setMedicationActive(id, isActive: isActive);
      if (!isActive) {
        await _db.remindersDao.deactivateRemindersForMedication(id);
      }
    });
  }
}
