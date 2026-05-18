import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/adherence_logs_table.dart';
import '../tables/medications_table.dart';
import '../tables/patients_table.dart';
import '../tables/reminders_table.dart';

part 'adherence_logs_dao.g.dart';

/// Data Access Object for the adherence_logs table.
/// The most-queried DAO in the app — powers:
///   - adherence_calendar_screen.dart  → range queries by date
///   - risk_engine.dart                → streak + miss-rate calculations
///   - report_screen.dart              → aggregations for PDF export
///   - dashboard_screen.dart           → clinic-wide adherence stats
@DriftAccessor(tables: [AdherenceLogs, Patients, Medications, Reminders])
class AdherenceLogsDao extends DatabaseAccessor<AppDatabase>
    with _$AdherenceLogsDaoMixin {
  AdherenceLogsDao(super.db);

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Insert a single adherence log. Returns the auto-generated id.
  /// Called when a patient taps "Take" or "Skip" on a dose card.
  /// The unique constraint on (patientId, medicationId, scheduledAt)
  /// prevents duplicates on retry or sync replay.
  Future<int> insertLog(AdherenceLogsCompanion entry) =>
      into(adherenceLogs).insert(
        entry,
        mode: InsertMode.insertOrIgnore, // silently skip on duplicate
      );

  /// Insert multiple logs in one transaction.
  /// Used by sync_service.dart when replaying offline-queued logs.
  Future<void> insertLogs(List<AdherenceLogsCompanion> entries) =>
      batch((b) => b.insertAll(
        adherenceLogs,
        entries,
        mode: InsertMode.insertOrIgnore,
      ));

  // ─── READ — single & basic ────────────────────────────────────────────────

  /// Fetch a single log by id.
  Future<AdherenceLog?> getLogById(int id) =>
      (select(adherenceLogs)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Fetch the most recent log for a specific medication.
  /// Used by dose_card.dart to show last-taken status.
  Future<AdherenceLog?> getLatestLogForMedication(int medicationId) =>
      (select(adherenceLogs)
        ..where((l) => l.medicationId.equals(medicationId))
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)])
        ..limit(1))
          .getSingleOrNull();

  /// Fetch all logs for a patient ordered by most recent first.
  /// Used by patient_detail_screen.dart for the full history list.
  Future<List<AdherenceLog>> getLogsForPatient(int patientId) =>
      (select(adherenceLogs)
        ..where((l) => l.patientId.equals(patientId))
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)]))
          .get();

  /// Watch all logs for a patient — reactive stream for
  /// patient_detail_screen.dart so the list updates after each dose action.
  Stream<List<AdherenceLog>> watchLogsForPatient(int patientId) =>
      (select(adherenceLogs)
        ..where((l) => l.patientId.equals(patientId))
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)]))
          .watch();

  // ─── READ — calendar range queries ────────────────────────────────────────

  /// Fetch all logs for a patient within a date range.
  /// Primary query for adherence_calendar_screen.dart — called each time
  /// the user swipes to a new month with the first and last day of that month.
  Future<List<AdherenceLog>> getLogsInRange({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      (select(adherenceLogs)
        ..where(
              (l) =>
          l.patientId.equals(patientId) &
          l.scheduledAt.isBiggerOrEqualValue(from) &
          l.scheduledAt.isSmallerOrEqualValue(to),
        )
        ..orderBy([(l) => OrderingTerm.asc(l.scheduledAt)]))
          .get();

  /// Watch logs in a date range — live stream so the calendar re-renders
  /// immediately when the patient logs a dose without leaving the screen.
  Stream<List<AdherenceLog>> watchLogsInRange({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      (select(adherenceLogs)
        ..where(
              (l) =>
          l.patientId.equals(patientId) &
          l.scheduledAt.isBiggerOrEqualValue(from) &
          l.scheduledAt.isSmallerOrEqualValue(to),
        )
        ..orderBy([(l) => OrderingTerm.asc(l.scheduledAt)]))
          .watch();

  /// Fetch logs for a specific day — used by the calendar day-detail view
  /// when a patient taps a date cell in adherence_calendar_screen.dart.
  Future<List<AdherenceLog>> getLogsForDay({
    required int patientId,
    required DateTime day,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return getLogsInRange(patientId: patientId, from: start, to: end);
  }

  // ─── READ — risk engine queries ───────────────────────────────────────────

  /// Fetch logs by status for a patient within a date range.
  /// risk_engine.dart calls this with each status to calculate
  /// taken-rate, miss-rate, and skip-rate independently.
  Future<List<AdherenceLog>> getLogsByStatus({
    required int patientId,
    required String status,
    required DateTime from,
    required DateTime to,
  }) =>
      (select(adherenceLogs)
        ..where(
              (l) =>
          l.patientId.equals(patientId) &
          l.status.equals(status) &
          l.scheduledAt.isBiggerOrEqualValue(from) &
          l.scheduledAt.isSmallerOrEqualValue(to),
        )
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)]))
          .get();

  /// Count logs grouped by status for a patient in a date range.
  /// Returns a map of status → count e.g. {'taken': 25, 'missed': 3}.
  /// Used by risk_engine.dart and report_screen.dart for summary stats.
  Future<Map<String, int>> getStatusCounts({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await (select(adherenceLogs)
      ..where(
            (l) =>
        l.patientId.equals(patientId) &
        l.scheduledAt.isBiggerOrEqualValue(from) &
        l.scheduledAt.isSmallerOrEqualValue(to),
      ))
        .get();

    final counts = <String, int>{
      'taken': 0,
      'missed': 0,
      'skipped': 0,
      'late': 0,
    };
    for (final row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Fetch the N most recent logs for a patient regardless of date.
  /// risk_engine.dart uses the last 30 days of logs for rolling
  /// adherence score calculations.
  Future<List<AdherenceLog>> getRecentLogs({
    required int patientId,
    int limit = 30,
  }) =>
      (select(adherenceLogs)
        ..where((l) => l.patientId.equals(patientId))
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)])
        ..limit(limit))
          .get();

  /// Calculate current streak — consecutive days with at least one
  /// 'taken' log. Returns count of days in the streak.
  /// Used by skreak_badge.dart (streak badge widget) on home_screen.dart.
  Future<int> getCurrentStreak(int patientId) async {
    final logs = await (select(adherenceLogs)
      ..where(
            (l) =>
        l.patientId.equals(patientId) & l.status.equals('taken'),
      )
      ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)]))
        .get();

    if (logs.isEmpty) return 0;

    // Collect unique calendar dates that had at least one taken dose
    final takenDays = logs
        .map((l) => DateTime(
      l.scheduledAt.year,
      l.scheduledAt.month,
      l.scheduledAt.day,
    ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // most recent first

    int streak = 1;
    for (int i = 0; i < takenDays.length - 1; i++) {
      final diff = takenDays[i].difference(takenDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break; // gap found — streak ends
      }
    }
    return streak;
  }

  // ─── READ — dashboard & reporting queries ─────────────────────────────────

  /// Fetch all logs for a specific medication — used by
  /// medication_detail_screen.dart to show per-drug adherence history.
  Future<List<AdherenceLog>> getLogsForMedication(int medicationId) =>
      (select(adherenceLogs)
        ..where((l) => l.medicationId.equals(medicationId))
        ..orderBy([(l) => OrderingTerm.desc(l.scheduledAt)]))
          .get();

  /// Fetch clinic-wide status counts across all patients in a date range.
  /// Used by dashboard_screen.dart clinic_stats_chart.dart.
  /// Returns a map of status → count across the whole clinic.
  Future<Map<String, int>> getClinicStatusCounts({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await (select(adherenceLogs)
      ..where(
            (l) =>
        l.scheduledAt.isBiggerOrEqualValue(from) &
        l.scheduledAt.isSmallerOrEqualValue(to),
      ))
        .get();

    final counts = <String, int>{
      'taken': 0,
      'missed': 0,
      'skipped': 0,
      'late': 0,
    };
    for (final row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Fetch all unsynced logs — called by sync_service.dart when
  /// connectivity is restored to build the upload queue.
  Future<List<AdherenceLog>> getUnsyncedLogs() =>
      (select(adherenceLogs)..where((l) => l.isSynced.equals(false))).get();

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Partial update — only touches provided columns.
  Future<int> updateLogFields(int id, AdherenceLogsCompanion fields) =>
      (update(adherenceLogs)..where((l) => l.id.equals(id))).write(fields);

  /// Mark a log as taken — called when patient confirms dose from
  /// a notification action or from home_screen.dart dose card.
  Future<int> markAsTaken(int id, {DateTime? takenAt}) {
    final now = takenAt ?? DateTime.now();
    return updateLogFields(
      id,
      AdherenceLogsCompanion(
        status: const Value('taken'),
        takenAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Mark a log as skipped with an optional note.
  /// Called when patient taps "Skip" on a dose card.
  Future<int> markAsSkipped(int id, {String? note}) => updateLogFields(
    id,
    AdherenceLogsCompanion(
      status: const Value('skipped'),
      note: Value(note),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Mark a log as missed — called by a background job after the
  /// dose window has passed with no patient response.
  Future<int> markAsMissed(int id) => updateLogFields(
    id,
    AdherenceLogsCompanion(
      status: const Value('missed'),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Mark a log as synced after successful backend upload.
  Future<int> markAsSynced(int id) => updateLogFields(
    id,
    AdherenceLogsCompanion(
      isSynced: const Value(true),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Bulk mark multiple logs as synced — used by sync_service.dart
  /// after a successful batch upload to avoid N individual updates.
  Future<void> markMultipleAsSynced(List<int> ids) => batch((b) {
    for (final id in ids) {
      b.update(
        adherenceLogs,
        AdherenceLogsCompanion(
          isSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
        where: (l) => l.id.equals(id),
      );
    }
  });

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Hard delete a single log by id.
  /// Use sparingly — adherence history should rarely be deleted.
  Future<int> deleteLog(int id) =>
      (delete(adherenceLogs)..where((l) => l.id.equals(id))).go();

  /// Delete all logs for a patient — used during full local wipe
  /// before re-syncing from the backend.
  Future<int> deleteLogsForPatient(int patientId) =>
      (delete(adherenceLogs)..where((l) => l.patientId.equals(patientId)))
          .go();
}