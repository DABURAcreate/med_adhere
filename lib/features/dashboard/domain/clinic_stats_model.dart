/// Aggregated clinic-wide metrics shown on the worker dashboard.
class ClinicStats {
  final int totalPatients;
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;

  /// Fraction of doses taken clinic-wide over the last 30 days. [0.0, 1.0]
  final double clinicAdherenceRate;

  /// Raw status counts map from AdherenceLogsDao.getClinicStatusCounts.
  final Map<String, int> statusCounts;

  const ClinicStats({
    required this.totalPatients,
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
    required this.clinicAdherenceRate,
    required this.statusCounts,
  });

  String get adherencePercent =>
      '${(clinicAdherenceRate * 100).toStringAsFixed(1)}%';

  static ClinicStats get empty => const ClinicStats(
        totalPatients: 0,
        highRisk: 0,
        mediumRisk: 0,
        lowRisk: 0,
        clinicAdherenceRate: 0,
        statusCounts: {},
      );
}
