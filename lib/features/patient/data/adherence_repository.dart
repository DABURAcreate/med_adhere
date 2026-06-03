import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';
import '../../risk_assessment/domain/risk_engine.dart';
import '../../risk_assessment/domain/risk_model.dart';

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
      _db.adherenceLogsDao.getLogsInRange(patientId: patientId, from: from, to: to);

  Stream<List<AdherenceLog>> watchLogsInRange({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      _db.adherenceLogsDao.watchLogsInRange(patientId: patientId, from: from, to: to);

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

    // Decrement stock when a dose is confirmed.
    if (status == kStatusTaken || status == kStatusLate) {
      await _db.medicationsDao.decrementStock(medicationId);
    }

    return _riskEngine.calculate(patientId);
  }

  /// Marks an existing log as taken (e.g. from a notification action).
  Future<RiskResult> markTaken(int logId, int patientId, {DateTime? takenAt}) async {
    await _db.adherenceLogsDao.markAsTaken(logId, takenAt: takenAt);
    return _riskEngine.calculate(patientId);
  }

  /// Marks an existing log as skipped with an optional note.
  Future<RiskResult> markSkipped(int logId, int patientId, {String? note}) async {
    await _db.adherenceLogsDao.markAsSkipped(logId, note: note);
    return _riskEngine.calculate(patientId);
  }

  /// Marks an existing log as missed (called by background job after dose window).
  Future<RiskResult> markMissed(int logId, int patientId) async {
    await _db.adherenceLogsDao.markAsMissed(logId);
    return _riskEngine.calculate(patientId);
  }

  // ── Aggregates ─────────────────────────────────────────────────────────────

  Future<Map<String, int>> getStatusCounts({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) =>
      _db.adherenceLogsDao.getStatusCounts(patientId: patientId, from: from, to: to);
}
