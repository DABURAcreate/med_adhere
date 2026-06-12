import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';
import '../../risk_assessment/domain/risk_engine.dart';
import '../../risk_assessment/domain/risk_model.dart';
import '../domain/today_dose_item.dart';

/// Wraps AdherenceLogsDao with business-level operations.
/// All dose-logging flows go through here so the risk engine is always
/// re-evaluated after a state change.
class AdherenceRepository {
  final AppDatabase _db;
  final RiskEngine _riskEngine;

  const AdherenceRepository({
    required AppDatabase db,
    required RiskEngine riskEngine,
  })  : _db = db,
        _riskEngine = riskEngine;

  // ── Today dose stream ─────────────────────────────────────────────────────

  /// Returns a live stream of today's dose slots for the home screen.
  ///
  /// Produces one [TodayDoseItem] per active reminder (dose time slot).
  /// When a medication has no reminders, one fallback item is produced with
  /// scheduledAt = dayStart.
  ///
  /// The stream re-emits whenever an adherence log changes today. Each
  /// emission re-fetches medications and reminders to pick up schedule changes.
  Stream<List<TodayDoseItem>> watchTodayDoses(int patientId) async* {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    await for (final logs in _db.adherenceLogsDao.watchLogsInRange(
      patientId: patientId,
      from: dayStart,
      to: dayEnd,
    )) {
      final meds =
          await _db.medicationsDao.getActiveMedicationsForPatient(patientId);
      final reminders =
          await _db.remindersDao.getActiveRemindersForPatient(patientId);

      // Group reminders by medicationId
      final remindersByMed = <int, List<Reminder>>{};
      for (final r in reminders) {
        remindersByMed.putIfAbsent(r.medicationId, () => []).add(r);
      }

      // Build log lookup keyed by "medicationId_scheduledAtMs"
      final logByKey = <String, AdherenceLog>{};
      for (final l in logs) {
        final key = '${l.medicationId}_${l.scheduledAt.millisecondsSinceEpoch}';
        logByKey[key] = l;
      }

      final items = <TodayDoseItem>[];

      for (final med in meds) {
        final medReminders = remindersByMed[med.id] ?? [];

        if (medReminders.isEmpty) {
          // Fallback: one card per medication scheduled at midnight
          final scheduledAt = dayStart;
          final key = '${med.id}_${scheduledAt.millisecondsSinceEpoch}';
          final log = logByKey[key];
          items.add(TodayDoseItem(
            patientId: patientId,
            medicationId: med.id,
            medicationName: med.name,
            doseTime: '--:--',
            reminderId: null,
            status: _toDoseStatus(log?.status),
            scheduledAt: scheduledAt,
            loggedAt: log?.takenAt ?? log?.updatedAt,
            logId: log?.id,
          ));
        } else {
          for (final r in medReminders) {
            final parts = r.scheduledTime.split(':');
            final hour = int.tryParse(parts[0]) ?? 0;
            final minute =
                parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
            final scheduledAt = DateTime(
              today.year,
              today.month,
              today.day,
              hour,
              minute,
            );
            final key = '${med.id}_${scheduledAt.millisecondsSinceEpoch}';
            final log = logByKey[key];
            items.add(TodayDoseItem(
              patientId: patientId,
              medicationId: med.id,
              medicationName: med.name,
              doseTime: r.scheduledTime,
              reminderId: r.id,
              status: _toDoseStatus(log?.status),
              scheduledAt: scheduledAt,
              loggedAt: log?.takenAt ?? log?.updatedAt,
              logId: log?.id,
            ));
          }
        }
      }

      // Sort by scheduled time so the next upcoming dose appears first
      items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      debugPrint(
        '[Adherence] watchTodayDoses emitting ${items.length} items'
        ' (taken=${items.where((i) => i.status == DoseStatus.taken).length}'
        ', missed=${items.where((i) => i.status == DoseStatus.missed).length}'
        ', pending=${items.where((i) => i.status == DoseStatus.pending).length})',
      );
      yield items;
    }
  }

  static DoseStatus _toDoseStatus(String? dbStatus) {
    switch (dbStatus) {
      case kStatusTaken:
      case kStatusLate:
        return DoseStatus.taken;
      case kStatusMissed:
      case kStatusSkipped:
        return DoseStatus.missed;
      default:
        return DoseStatus.pending;
    }
  }

  // ── Home-screen dose actions ──────────────────────────────────────────────

  /// Marks a specific dose slot as taken.
  ///
  /// Checks whether the exact slot (patientId + medicationId + scheduledAt)
  /// already has a log. If it does, this is a no-op — the card is already
  /// locked. Otherwise inserts a new log, decrements stock, and recalculates
  /// patient risk.
  Future<void> markDoseTaken({
    required int patientId,
    required int medicationId,
    required DateTime scheduledAt,
    int? reminderId,
  }) async {
    final existing = await _db.adherenceLogsDao.getLogForScheduledDose(
      patientId: patientId,
      medicationId: medicationId,
      scheduledAt: scheduledAt,
    );
    if (existing != null) {
      debugPrint(
        '[Adherence] markDoseTaken: slot already logged (id=${existing.id}), skipping',
      );
      return;
    }

    final now = DateTime.now();
    debugPrint(
      '[Adherence] markDoseTaken: inserting log for med=$medicationId at $scheduledAt',
    );
    await _db.adherenceLogsDao.insertLog(
      AdherenceLogsCompanion(
        patientId: Value(patientId),
        medicationId: Value(medicationId),
        reminderId: Value(reminderId),
        status: const Value(kStatusTaken),
        scheduledAt: Value(scheduledAt),
        takenAt: Value(now),
        isManualEntry: const Value(true),
        isSynced: const Value(false),
      ),
    );
    await _db.medicationsDao.decrementStock(medicationId);
    await _riskEngine.calculate(patientId);
  }

  /// Marks a specific dose slot as missed.
  ///
  /// Same guard as [markDoseTaken] — already-logged slots are skipped.
  Future<void> markDoseMissed({
    required int patientId,
    required int medicationId,
    required DateTime scheduledAt,
    int? reminderId,
  }) async {
    final existing = await _db.adherenceLogsDao.getLogForScheduledDose(
      patientId: patientId,
      medicationId: medicationId,
      scheduledAt: scheduledAt,
    );
    if (existing != null) {
      debugPrint(
        '[Adherence] markDoseMissed: slot already logged (id=${existing.id}), skipping',
      );
      return;
    }

    debugPrint(
      '[Adherence] markDoseMissed: inserting log for med=$medicationId at $scheduledAt',
    );
    await _db.adherenceLogsDao.insertLog(
      AdherenceLogsCompanion(
        patientId: Value(patientId),
        medicationId: Value(medicationId),
        reminderId: Value(reminderId),
        status: const Value(kStatusMissed),
        scheduledAt: Value(scheduledAt),
        isManualEntry: const Value(true),
        isSynced: const Value(false),
      ),
    );
    await _riskEngine.calculate(patientId);
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  Future<List<AdherenceLog>> getLogsForPatient(int patientId) =>
      _db.adherenceLogsDao.getLogsForPatient(patientId);

  Stream<List<AdherenceLog>> watchLogsForPatient(int patientId) =>
      _db.adherenceLogsDao.watchLogsForPatient(patientId);

  Future<List<AdherenceLog>> getLogsInRange({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      _db.adherenceLogsDao
          .getLogsInRange(patientId: patientId, from: from, to: to);

  Stream<List<AdherenceLog>> watchLogsInRange({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      _db.adherenceLogsDao
          .watchLogsInRange(patientId: patientId, from: from, to: to);

  Future<List<AdherenceLog>> getLogsForDay({
    required int patientId,
    required DateTime day,
  }) =>
      _db.adherenceLogsDao.getLogsForDay(patientId: patientId, day: day);

  Future<int> getCurrentStreak(int patientId) =>
      _db.adherenceLogsDao.getCurrentStreak(patientId);

  // ── Dose logging ───────────────────────────────────────────────────────────

  /// Records a new dose event with the given [status].
  /// Re-calculates risk after the insert and returns the updated [RiskResult].
  Future<RiskResult> logDose({
    required int patientId,
    required int medicationId,
    required DateTime scheduledAt,
    required String status,
    int? reminderId,
    String? note,
    bool isManualEntry = false,
  }) async {
    final now = DateTime.now();
    final minutesLate = status == kStatusLate
        ? now.difference(scheduledAt).inMinutes.abs()
        : null;

    await _db.adherenceLogsDao.insertLog(
      AdherenceLogsCompanion(
        patientId: Value(patientId),
        medicationId: Value(medicationId),
        reminderId: Value(reminderId),
        status: Value(status),
        scheduledAt: Value(scheduledAt),
        takenAt: Value(
          status == kStatusTaken || status == kStatusLate ? now : null,
        ),
        minutesLate: Value(minutesLate),
        note: Value(note),
        isManualEntry: Value(isManualEntry),
      ),
    );

    if (status == kStatusTaken || status == kStatusLate) {
      await _db.medicationsDao.decrementStock(medicationId);
    }

    return _riskEngine.calculate(patientId);
  }

  Future<RiskResult> markTaken(int logId, int patientId,
      {DateTime? takenAt}) async {
    await _db.adherenceLogsDao.markAsTaken(logId, takenAt: takenAt);
    return _riskEngine.calculate(patientId);
  }

  Future<RiskResult> markSkipped(int logId, int patientId,
      {String? note}) async {
    await _db.adherenceLogsDao.markAsSkipped(logId, note: note);
    return _riskEngine.calculate(patientId);
  }

  Future<RiskResult> markMissed(int logId, int patientId) async {
    await _db.adherenceLogsDao.markAsMissed(logId);
    return _riskEngine.calculate(patientId);
  }

  // ── Auto-mark missed ──────────────────────────────────────────────────────

  /// Scans the last [lookbackDays] days for dose slots that were never logged
  /// and inserts "missed" records for each one that has passed the [grace]
  /// window.  Called once per session start so the risk engine stays accurate
  /// even when the patient doesn't open the app every day.
  ///
  /// Returns the number of auto-inserted logs.
  Future<int> autoMarkPastDoses(
    int patientId, {
    Duration grace = const Duration(hours: 4),
    int lookbackDays = 7,
  }) async {
    final now = DateTime.now();
    final cutoff = now.subtract(grace);
    final meds =
        await _db.medicationsDao.getActiveMedicationsForPatient(patientId);
    final reminders =
        await _db.remindersDao.getActiveRemindersForPatient(patientId);

    final remindersByMed = <int, List<Reminder>>{};
    for (final r in reminders) {
      remindersByMed.putIfAbsent(r.medicationId, () => []).add(r);
    }

    int count = 0;

    for (int daysAgo = lookbackDays; daysAgo >= 0; daysAgo--) {
      final day = now.subtract(Duration(days: daysAgo));
      final dayDate = DateTime(day.year, day.month, day.day);

      for (final med in meds) {
        final medReminders = remindersByMed[med.id] ?? [];
        final slotsToCheck = medReminders.isEmpty
            ? [dayDate] // one midnight slot per medication
            : medReminders.map((r) {
                final parts = r.scheduledTime.split(':');
                final h = int.tryParse(parts[0]) ?? 0;
                final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
                return DateTime(dayDate.year, dayDate.month, dayDate.day, h, m);
              }).toList();

        for (final scheduledAt in slotsToCheck) {
          // Only mark slots that are past the grace window.
          if (!scheduledAt.isBefore(cutoff)) continue;

          final existing =
              await _db.adherenceLogsDao.getLogForScheduledDose(
            patientId: patientId,
            medicationId: med.id,
            scheduledAt: scheduledAt,
          );
          if (existing != null) continue;

          final matchedReminder = medReminders.isEmpty
              ? null
              : reminders
                  .where((r) =>
                      r.medicationId == med.id &&
                      '${scheduledAt.hour.toString().padLeft(2, "0")}:${scheduledAt.minute.toString().padLeft(2, "0")}' ==
                          r.scheduledTime)
                  .firstOrNull;

          await _db.adherenceLogsDao.insertLog(
            AdherenceLogsCompanion(
              patientId: Value(patientId),
              medicationId: Value(med.id),
              reminderId: Value(matchedReminder?.id),
              status: const Value(kStatusMissed),
              scheduledAt: Value(scheduledAt),
              isManualEntry: const Value(false),
              isSynced: const Value(false),
            ),
          );
          count++;
        }
      }
    }

    if (count > 0) {
      debugPrint('[Adherence] Auto-marked $count missed dose(s) for patient $patientId.');
      await _riskEngine.calculate(patientId);
    }
    return count;
  }

  // ── Aggregates ─────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStatusCounts({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      _db.adherenceLogsDao
          .getStatusCounts(patientId: patientId, from: from, to: to);
}
