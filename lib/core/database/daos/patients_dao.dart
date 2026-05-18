import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/patients_table.dart';

part 'patients_dao.g.dart';

/// Data Access Object for the patients table.
/// All patient reads and writes go through here — no raw SQL elsewhere.
/// Injected into patient_repository.dart and auth_repository.dart.
@DriftAccessor(tables: [Patients])
class PatientsDao extends DatabaseAccessor<AppDatabase>
    with _$PatientsDaoMixin {
  PatientsDao(super.db);

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Insert a new patient. Returns the auto-generated id.
  Future<int> insertPatient(PatientsCompanion entry) =>
      into(patients).insert(entry);

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Fetch a single patient by id.
  /// Returns null if no patient with that id exists.
  Future<Patient?> getPatientById(int id) =>
      (select(patients)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Fetch a patient by their clinic registration code.
  /// Used during login to look up the account from the onboarding code.
  Future<Patient?> getPatientByRegistrationCode(String code) =>
      (select(patients)..where((p) => p.registrationCode.equals(code)))
          .getSingleOrNull();

  /// Watch a single patient row — emits a new value whenever the row changes.
  /// Used by home_screen.dart to reactively update the UI.
  Stream<Patient?> watchPatientById(int id) =>
      (select(patients)..where((p) => p.id.equals(id))).watchSingleOrNull();

  /// Fetch all patients — used by the healthcare worker patient_list_screen.dart.
  Future<List<Patient>> getAllPatients() => select(patients).get();

  /// Watch all patients — live stream for patient_list_screen.dart.
  Stream<List<Patient>> watchAllPatients() => select(patients).watch();

  /// Fetch all patients filtered by risk level ('low' | 'medium' | 'high').
  /// Used by dashboard_screen.dart risk overview card.
  Future<List<Patient>> getPatientsByRiskLevel(String riskLevel) =>
      (select(patients)..where((p) => p.riskLevel.equals(riskLevel))).get();

  /// Search patients by name — case-insensitive partial match.
  /// Powers the search bar in patient_list_screen.dart.
  Future<List<Patient>> searchPatients(String query) => (select(patients)
    ..where((p) => p.fullName.lower().like('%${query.toLowerCase()}%')))
      .get();

  /// Fetch all patients that have not yet been synced to the backend.
  /// Called by sync_service.dart when connectivity is restored.
  Future<List<Patient>> getUnsyncedPatients() =>
      (select(patients)..where((p) => p.isSynced.equals(false))).get();

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Replace all fields on a patient row with new values.
  Future<bool> updatePatient(Patient patient) =>
      update(patients).replace(patient);

  /// Partial update — only touches the columns provided in the companion.
  /// Use this to update a single field without fetching the full row first.
  /// e.g. updatePatientFields(id, PatientsCompanion(riskLevel: Value('high')))
  Future<int> updatePatientFields(int id, PatientsCompanion fields) =>
      (update(patients)..where((p) => p.id.equals(id))).write(fields);

  /// Mark a patient as synced after a successful backend upload.
  Future<int> markAsSynced(int id) => updatePatientFields(
    id,
    PatientsCompanion(
      isSynced: const Value(true),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Update the patient's risk level — called by risk_engine.dart.
  Future<int> updateRiskLevel(int id, String riskLevel) => updatePatientFields(
    id,
    PatientsCompanion(
      riskLevel: Value(riskLevel),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Update the patient's PIN hash — called by auth_service.dart on PIN change.
  Future<int> updatePinHash(int id, String pinHash) => updatePatientFields(
    id,
    PatientsCompanion(
      pinHash: Value(pinHash),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Link or update the caregiver phone number — called by caregiver_link_screen.dart.
  Future<int> updateCaregiverPhone(int id, String? phone) =>
      updatePatientFields(
        id,
        PatientsCompanion(
          caregiverPhone: Value(phone),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Hard delete a patient by id.
  /// Cascade rules in medications, reminders, and adherence_logs
  /// will automatically remove all related rows.
  Future<int> deletePatient(int id) =>
      (delete(patients)..where((p) => p.id.equals(id))).go();
}