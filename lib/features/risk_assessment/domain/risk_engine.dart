import '../../../core/database/daos/adherence_logs_dao.dart';
import '../../../core/database/daos/patients_dao.dart';
import '../../../core/utils/constants.dart';
import 'risk_model.dart';

/// Calculates a patient's current risk level from their adherence history.
///
/// Call [calculate] whenever:
///   - A dose is logged (taken / missed / skipped)
///   - The app resumes from background
///   - A sync completes
///
/// The result is persisted back to patients.risk_level so the worker
/// dashboard can sort/filter without re-running the engine on every row.
class RiskEngine {
  final AdherenceLogsDao _logsDao;
  final PatientsDao _patientsDao;

  const RiskEngine({
    required AdherenceLogsDao logsDao,
    required PatientsDao patientsDao,
  }) : _logsDao = logsDao,
       _patientsDao = patientsDao;

  /// Runs the full risk calculation for [patientId] and persists the result.
  Future<RiskResult> calculate(int patientId) async {
    final now = DateTime.now();
    final window30Start = now.subtract(const Duration(days: kRiskWindowDays));
    final window7Start = now.subtract(const Duration(days: kRiskRecentWindowDays));

    final logs30 = await _logsDao.getLogsInRange(
      patientId: patientId,
      from: window30Start,
      to: now,
    );

    if (logs30.isEmpty) {
      return RiskResult.noData(patientId);
    }

    // ── Status counts ─────────────────────────────────────────────────────────
    int taken30 = 0, missed30 = 0, skipped30 = 0;
    int missed7 = 0;

    for (final log in logs30) {
      switch (log.status) {
        case kStatusTaken:
          taken30++;
        case kStatusMissed:
          missed30++;
          if (log.scheduledAt.isAfter(window7Start)) missed7++;
        case kStatusSkipped:
          skipped30++;
        case kStatusLate:
          taken30++; // late counts as taken for adherence rate
      }
    }

    final total = logs30.length;
    // Adherence = (taken + late) / all scheduled doses.
    // Skipped doses are excluded from the denominator — patient made a
    // deliberate decision; missing did not.
    final denominator = total - skipped30;
    final adherenceRate = denominator > 0 ? taken30 / denominator : 1.0;

    // ── Consecutive missed days ───────────────────────────────────────────────
    final consecutiveMisses = _consecutiveMissedDays(logs30);

    // ── Streak ───────────────────────────────────────────────────────────────
    final streak = await _logsDao.getCurrentStreak(patientId);

    // ── 7-day recency factor ──────────────────────────────────────────────────
    final logs7 = logs30
        .where((l) => l.scheduledAt.isAfter(window7Start))
        .toList();
    final recentAdherence = _adherenceRate(logs7);

    // ── Determine level ───────────────────────────────────────────────────────
    final level = _determineLevel(
      adherenceRate: adherenceRate,
      recentAdherence: recentAdherence,
      consecutiveMisses: consecutiveMisses,
    );

    // ── Compute numeric score (0–100) ─────────────────────────────────────────
    final score = _computeScore(
      adherenceRate: adherenceRate,
      consecutiveMisses: consecutiveMisses,
      recentAdherence: recentAdherence,
      streak: streak,
    );

    // ── Persist to DB ─────────────────────────────────────────────────────────
    // Compute the most-recent log date to store on the patient row.
    final lastLogAt = logs30.isNotEmpty
        ? logs30
            .map((l) => l.scheduledAt)
            .reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    await _patientsDao.updateRiskSummary(
      patientId,
      riskLevel: level.name,
      riskScore: score,
      adherencePercentage30Days: adherenceRate * 100,
      takenDoses30Days: taken30,
      missedDoses30Days: missed30,
      lastAdherenceLogAt: lastLogAt,
    );

    return RiskResult(
      patientId: patientId,
      level: level,
      adherenceRate: adherenceRate,
      currentStreak: streak,
      missedLast7Days: missed7,
      missedLast30Days: missed30,
      consecutiveMisses: consecutiveMisses,
      totalLogs30Days: total,
      riskScore: score,
      calculatedAt: now,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Counts the current run of consecutive calendar days where every
  /// scheduled dose was missed (no taken/late log exists for those days).
  int _consecutiveMissedDays(List<dynamic> logs) {
    // Group logs by calendar day.
    final byDay = <DateTime, List<dynamic>>{};
    for (final log in logs) {
      final day = DateTime(
        log.scheduledAt.year,
        log.scheduledAt.month,
        log.scheduledAt.day,
      );
      byDay.putIfAbsent(day, () => []).add(log);
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    int count = 0;
    for (final day in days) {
      final dayLogs = byDay[day]!;
      final hasTakenOrLate = dayLogs.any(
        (l) => l.status == kStatusTaken || l.status == kStatusLate,
      );
      if (hasTakenOrLate) break; // streak of misses ends at first good day
      if (dayLogs.any((l) => l.status == kStatusMissed)) {
        count++;
      }
    }
    return count;
  }

  double _adherenceRate(List<dynamic> logs) {
    if (logs.isEmpty) return 1.0;
    final skipped = logs.where((l) => l.status == kStatusSkipped).length;
    final denominator = logs.length - skipped;
    if (denominator == 0) return 1.0;
    final taken = logs
        .where((l) => l.status == kStatusTaken || l.status == kStatusLate)
        .length;
    return taken / denominator;
  }

  RiskLevel _determineLevel({
    required double adherenceRate,
    required double recentAdherence,
    required int consecutiveMisses,
  }) {
    // Hard overrides first.
    if (consecutiveMisses >= kConsecutiveMissesHighOverride) return RiskLevel.high;
    if (adherenceRate < kRiskHighThreshold) return RiskLevel.high;

    // Medium escalation.
    if (consecutiveMisses >= kConsecutiveMissesMediumOverride) return RiskLevel.medium;
    if (adherenceRate < kRiskMediumThreshold) return RiskLevel.medium;

    // Recent week worse than 60% even if 30-day average is OK → medium.
    if (recentAdherence < 0.60) return RiskLevel.medium;

    return RiskLevel.low;
  }

  int _computeScore({
    required double adherenceRate,
    required int consecutiveMisses,
    required double recentAdherence,
    required int streak,
  }) {
    // Base: how far below 100% the patient is.
    double score = (1.0 - adherenceRate) * 100;

    // Consecutive miss penalty: up to 30 extra points.
    score += (consecutiveMisses * 8).clamp(0, 30);

    // Recency penalty: recent week below 60% adds 10.
    if (recentAdherence < 0.60) score += 10;

    // Streak bonus: 14+ day streak reduces score by 5.
    if (streak >= 14) score -= 5;

    return score.round().clamp(0, 100);
  }
}
