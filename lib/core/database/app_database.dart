import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/adherence_logs_dao.dart';
import 'daos/medications_dao.dart';
import 'daos/patients_dao.dart';
import 'daos/reminders_dao.dart';
import 'tables/adherence_logs_table.dart';
import 'tables/medications_table.dart';
import 'tables/patients_table.dart';
import 'tables/reminders_table.dart';

part 'app_database.g.dart';

/// The single Drift database instance for the entire app.
///
/// Created once in main.dart and provided to the widget tree via Provider.
/// All feature repositories receive this via constructor injection —
/// nothing accesses the DAOs directly except through a repository.
///
/// Schema version history:
///   v1 — initial schema: patients, medications, reminders, adherence_logs
@DriftDatabase(
  tables: [
    Patients,
    Medications,
    Reminders,
    AdherenceLogs,
  ],
  daos: [
    PatientsDao,
    MedicationsDao,
    RemindersDao,
    AdherenceLogsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Standard constructor — opens (or creates) the SQLite file on disk.
  AppDatabase() : super(_openConnection());

  /// Named constructor for injecting a test executor.
  /// Usage in tests:
  ///   final db = AppDatabase.forTesting(NativeDatabase.memory());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  // ─── Schema version ───────────────────────────────────────────────────────

  @override
  int get schemaVersion => 1;

  // ─── Migrations ───────────────────────────────────────────────────────────

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Create all tables defined in @DriftDatabase(tables: [...])
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Add future migration steps here as schema version increases.
      // Example for v2:
      //   if (from < 2) {
      //     await m.addColumn(patients, patients.someNewColumn);
      //   }
    },
    beforeOpen: (details) async {
      // Enable foreign key enforcement — SQLite disables this by default.
      // Must be set before any queries run, hence beforeOpen.
      await customStatement('PRAGMA foreign_keys = ON');

      // Enable WAL mode for better concurrent read performance.
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  // ─── Convenience transaction helper ───────────────────────────────────────

  /// Wrap multiple DAO calls in a single atomic transaction.
  ///
  /// Use this in repositories when two or more tables must be updated
  /// together — e.g. deactivating a medication AND its reminders:
  ///
  /// ```dart
  /// await db.runInTransaction(() async {
  ///   await db.medicationsDao.setMedicationActive(id, isActive: false);
  ///   await db.remindersDao.deactivateRemindersForMedication(id);
  /// });
  /// ```
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}

// ─── Database connection ─────────────────────────────────────────────────────

/// Opens the SQLite database file.
/// drift_flutter's driftDatabase helper resolves the correct file path
/// per platform automatically — no manual path_provider calls needed.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'mzansi_meds_db');
}