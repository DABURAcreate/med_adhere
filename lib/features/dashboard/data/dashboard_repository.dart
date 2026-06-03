import '../../../core/database/app_database.dart';
import '../domain/clinic_stats_model.dart';

/// Aggregates clinic-wide data for the healthcare worker dashboard.
class DashboardRepository {
  final AppDatabase _db;

  const DashboardRepository({required AppDatabase db}) : _db = db;

  Stream<List<Patient>> watchAllPatients() =>
      _db.patientsDao.watchAllPatients();

  Future<List<Patient>> getAllPatients() => _db.patientsDao.getAllPatients();

  Future<List<Patient>> searchPatients(String query) =>
      _db.patientsDao.searchPatients(query);

  Future<List<Patient>> getPatientsByRisk(String riskLevel) =>
      _db.patientsDao.getPatientsByRiskLevel(riskLevel);

  /// Builds clinic-wide stats for the dashboard stat cards.
  Future<ClinicStats> getClinicStats() async {
    final all = await _db.patientsDao.getAllPatients();

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));

    final counts = await _db.adherenceLogsDao
        .getClinicStatusCounts(from: from, to: now);

    final total = all.length;
    final high = all.where((p) => p.riskLevel == 'high').length;
    final medium = all.where((p) => p.riskLevel == 'medium').length;
    final low = all.where((p) => p.riskLevel == 'low').length;

    final taken = (counts['taken'] ?? 0) + (counts['late'] ?? 0);
    final totalLogs = counts.values.fold(0, (a, b) => a + b);
    final adherenceRate =
        totalLogs > 0 ? taken / totalLogs : 0.0;

    return ClinicStats(
      totalPatients: total,
      highRisk: high,
      mediumRisk: medium,
      lowRisk: low,
      clinicAdherenceRate: adherenceRate,
      statusCounts: counts,
    );
  }

  /// 30-day daily adherence percentages for the trend chart.
  Future<List<double>> getAdherenceTrend() async {
    final now = DateTime.now();
    final results = <double>[];

    for (int i = 29; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final from = DateTime(day.year, day.month, day.day);
      final to = from.add(const Duration(days: 1));

      final counts = await _db.adherenceLogsDao
          .getClinicStatusCounts(from: from, to: to);

      final taken = (counts['taken'] ?? 0) + (counts['late'] ?? 0);
      final total = counts.values.fold(0, (a, b) => a + b);
      results.add(total > 0 ? taken / total : 0.0);
    }

    return results;
  }
}
