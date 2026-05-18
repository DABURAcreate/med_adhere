import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/medications_table.dart';
import '../tables/patients_table.dart';

part 'medications_dao.g.dart';

/// Data Access Object for the medications table.
/// All medication reads and writes go through here.
/// Injected into patient_repository.dart and patient_mgmt_repository.dart.
@DriftAccessor(tables: [Medications, Patients])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Insert a new medication. Returns the auto-generated id.
  Future<int> insertMedication(MedicationsCompanion entry) =>
      into(medications).insert(entry);

  /// Insert multiple medications in one transaction — used when registering
  /// a new patient with a pre-set medication schedule.
  Future<void> insertMedications(List<MedicationsCompanion> entries) =>
      batch((b) => b.insertAll(medications, entries));

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Fetch a single medication by id.
  /// Used by medication_detail_screen.dart.
  Future<Medication?> getMedicationById(int id) =>
      (select(medications)..where((m) => m.id.equals(id))).getSingleOrNull();

  /// Watch a single medication — live updates for medication_detail_screen.dart.
  Stream<Medication?> watchMedicationById(int id) =>
      (select(medications)..where((m) => m.id.equals(id))).watchSingleOrNull();

  /// Fetch all medications for a patient — used by home_screen.dart
  /// to build the upcoming doses list.
  Future<List<Medication>> getMedicationsForPatient(int patientId) =>
      (select(medications)
        ..where((m) => m.patientId.equals(patientId))
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .get();

  /// Watch all medications for a patient — reactive stream for home_screen.dart.
  Stream<List<Medication>> watchMedicationsForPatient(int patientId) =>
      (select(medications)
        ..where((m) => m.patientId.equals(patientId))
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .watch();

  /// Fetch only active medications for a patient.
  /// Used by reminder_settings_screen.dart and notification_service.dart —
  /// inactive medications should never trigger reminders.
  Future<List<Medication>> getActiveMedicationsForPatient(int patientId) =>
      (select(medications)
        ..where(
              (m) => m.patientId.equals(patientId) & m.isActive.equals(true),
        )
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .get();

  /// Watch active medications for a patient — used by home_screen.dart
  /// dose cards to reactively reflect activation changes.
  Stream<List<Medication>> watchActiveMedicationsForPatient(int patientId) =>
      (select(medications)
        ..where(
              (m) => m.patientId.equals(patientId) & m.isActive.equals(true),
        )
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .watch();

  /// Fetch medications with stock at or below the refill reminder threshold.
  /// Called by a background job to surface low-stock alerts in home_screen.dart.
  Future<List<Medication>> getLowStockMedications(int patientId) =>
      (select(medications)
        ..where(
              (m) =>
          m.patientId.equals(patientId) &
          m.isActive.equals(true) &
          m.stockCount.isNotNull() &
          m.refillReminderAt.isNotNull() &
          m.stockCount.isSmallerOrEqualValue(0),
        ))
          .get();

  /// Fetch all unsynced medications — called by sync_service.dart.
  Future<List<Medication>> getUnsyncedMedications() =>
      (select(medications)..where((m) => m.isSynced.equals(false))).get();

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Replace all fields on a medication row.
  Future<bool> updateMedication(Medication medication) =>
      update(medications).replace(medication);

  /// Partial update — only touches provided columns.
  Future<int> updateMedicationFields(int id, MedicationsCompanion fields) =>
      (update(medications)..where((m) => m.id.equals(id))).write(fields);

  /// Activate or deactivate a medication — called by medication_schedule_screen.dart.
  /// Deactivating stops reminders without losing prescription history.
  Future<int> setMedicationActive(int id, {required bool isActive}) =>
      updateMedicationFields(
        id,
        MedicationsCompanion(
          isActive: Value(isActive),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Decrement stock count by 1 when a dose is logged as taken.
  /// Called by adherence_logs_dao after a successful dose confirmation.
  Future<void> decrementStock(int id) => (update(medications)
    ..where((m) => m.id.equals(id) & m.stockCount.isNotNull()))
      .write(
    MedicationsCompanion.custom(
      stockCount: medications.stockCount - const Constant(1),
      updatedAt: Variable(DateTime.now()),
    ),
  );

  /// Mark a medication as synced after backend upload.
  Future<int> markAsSynced(int id) => updateMedicationFields(
    id,
    MedicationsCompanion(
      isSynced: const Value(true),
      updatedAt: Value(DateTime.now()),
    ),
  );

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Hard delete a medication by id.
  /// Cascade rules remove all linked reminders and adherence logs.
  /// Prefer setMedicationActive(false) to preserve history.
  Future<int> deleteMedication(int id) =>
      (delete(medications)..where((m) => m.id.equals(id))).go();

  /// Delete all medications for a patient — used when a patient
  /// record is fully wiped locally before re-syncing from the backend.
  Future<int> deleteMedicationsForPatient(int patientId) =>
      (delete(medications)..where((m) => m.patientId.equals(patientId))).go();
}