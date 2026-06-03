import '../../../core/utils/constants.dart';

enum RiskLevel {
  low,
  medium,
  high;

  static RiskLevel fromString(String s) => switch (s) {
        kRiskHigh => RiskLevel.high,
        kRiskMedium => RiskLevel.medium,
        _ => RiskLevel.low,
      };

  String get name => switch (this) {
        RiskLevel.low => kRiskLow,
        RiskLevel.medium => kRiskMedium,
        RiskLevel.high => kRiskHigh,
      };

  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.medium => 'Medium Risk',
        RiskLevel.high => 'High Risk',
      };
}

/// Snapshot of a patient's risk state at a point in time.
class RiskResult {
  final int patientId;
  final RiskLevel level;

  /// Fraction of scheduled doses taken or taken-late over the last 30 days.
  /// Range [0.0, 1.0].  1.0 = perfect adherence.
  final double adherenceRate;

  /// Consecutive calendar days with at least one 'taken' or 'late' dose.
  final int currentStreak;

  /// Number of 'missed' logs in the last 7 days.
  final int missedLast7Days;

  /// Number of 'missed' logs in the last 30 days.
  final int missedLast30Days;

  /// Current run of consecutive calendar days where all doses were missed
  /// (no 'taken' or 'late' logs exist for those days).
  final int consecutiveMisses;

  /// Total dose logs considered in the 30-day window.
  final int totalLogs30Days;

  /// 0–100 numeric score derived from the metrics above (higher = riskier).
  final int riskScore;

  final DateTime calculatedAt;

  const RiskResult({
    required this.patientId,
    required this.level,
    required this.adherenceRate,
    required this.currentStreak,
    required this.missedLast7Days,
    required this.missedLast30Days,
    required this.consecutiveMisses,
    required this.totalLogs30Days,
    required this.riskScore,
    required this.calculatedAt,
  });

  /// Human-readable adherence percentage string.
  String get adherencePercent =>
      '${(adherenceRate * 100).toStringAsFixed(1)}%';

  /// Primary explanation shown on RiskLevelScreen.
  List<String> get reasons {
    if (totalLogs30Days == 0) {
      return ['No dose history recorded yet'];
    }
    final out = <String>[];
    if (consecutiveMisses >= kConsecutiveMissesHighOverride) {
      out.add('Missed doses $consecutiveMisses days in a row');
    }
    if (adherenceRate < kRiskHighThreshold) {
      out.add('Only $adherencePercent of doses taken in the last 30 days');
    } else if (adherenceRate < kRiskMediumThreshold) {
      out.add('$adherencePercent of doses taken — aim for above 80%');
    }
    if (missedLast7Days > 0) {
      out.add('$missedLast7Days missed dose(s) in the last 7 days');
    }
    if (currentStreak >= 7 && level == RiskLevel.low) {
      out.add('$currentStreak-day streak — keep it up!');
    }
    if (out.isEmpty) {
      out.add('$adherencePercent of doses taken in the last 30 days');
    }
    return out;
  }

  /// Actionable recommendation for the patient.
  String get recommendation => switch (level) {
        RiskLevel.low =>
          'Keep taking your medication as scheduled. You are doing well!',
        RiskLevel.medium =>
          'Try not to skip doses. Set a daily reminder if needed.',
        RiskLevel.high =>
          'Contact your clinic immediately. Missing doses can reduce treatment effectiveness.',
      };

  /// Returns a default result used when no logs exist yet.
  factory RiskResult.noData(int patientId) => RiskResult(
        patientId: patientId,
        level: RiskLevel.low,
        adherenceRate: 1.0,
        currentStreak: 0,
        missedLast7Days: 0,
        missedLast30Days: 0,
        consecutiveMisses: 0,
        totalLogs30Days: 0,
        riskScore: 0,
        calculatedAt: DateTime.now(),
      );
}
