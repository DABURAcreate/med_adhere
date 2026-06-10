import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';
import '../domain/clinic_stats_model.dart';

/// Aggregates clinic-wide data for the healthcare worker dashboard.
class DashboardRepository {
  final AppDatabase _db;

  const DashboardRepository({required AppDatabase db}) : _db = db;

  // ── Clinic-filtered streams ────────────────────────────────────────────────

  /// Live stream of patients for the given clinic (or all patients when null).
  Stream<List<Patient>> watchClinicPatients({String? clinicName}) {
    if (clinicName != null && clinicName.isNotEmpty) {
      return _db.patientsDao.watchPatientsByClinic(clinicName);
    }
    return _db.patientsDao.watchAllPatients();
  }

  /// Live stream of clinic-wide stats, re-emitting whenever any patient row
  /// changes. Filtered to the given clinic (or all patients when null).
  Stream<ClinicStats> watchClinicStats({String? clinicName}) {
    return watchClinicPatients(clinicName: clinicName).map((patients) {
      final total = patients.length;
      final high = patients.where((p) => p.riskLevel == kRiskHigh).length;
      final medium = patients.where((p) => p.riskLevel == kRiskMedium).length;
      final low = patients.where((p) => p.riskLevel == kRiskLow).length;

      final withData =
          patients.where((p) => p.adherencePercentage30Days != null).toList();
      final avgAdherence = withData.isEmpty
          ? 0.0
          : withData.fold<double>(
                0,
                (sum, p) => sum + p.adherencePercentage30Days!,
              ) /
              withData.length;

      debugPrint('[Dashboard] Loaded clinic stats for clinic="${clinicName ?? 'all'}" — '
          'total=$total, high=$high, avgAdherence=${avgAdherence.toStringAsFixed(1)}%');

      return ClinicStats(
        totalPatients: total,
        highRisk: high,
        mediumRisk: medium,
        lowRisk: low,
        clinicAdherenceRate: avgAdherence / 100,
        statusCounts: const {},
      );
    });
  }

  /// Live stream of high-risk patients for the given clinic, sorted by riskScore.
  Stream<List<Patient>> watchHighRiskPatients({String? clinicName}) {
    return watchClinicPatients(clinicName: clinicName).map(
      (patients) => patients
          .where((p) => p.riskLevel == kRiskHigh)
          .toList()
        ..sort((a, b) => (b.riskScore ?? 0).compareTo(a.riskScore ?? 0)),
    );
  }

  // ── Legacy unfiltered streams (kept for backward compat) ──────────────────

  Stream<List<Patient>> watchAllPatients() =>
      _db.patientsDao.watchAllPatients();

  // ── Async helpers ─────────────────────────────────────────────────────────

  Future<List<Patient>> getAllPatients() => _db.patientsDao.getAllPatients();

  Future<List<Patient>> getClinicPatients({String? clinicName}) {
    if (clinicName != null && clinicName.isNotEmpty) {
      return _db.patientsDao.getPatientsByClinic(clinicName);
    }
    return _db.patientsDao.getAllPatients();
  }

  Future<List<Patient>> searchPatients(String query) =>
      _db.patientsDao.searchPatients(query);

  Future<List<Patient>> getPatientsByRisk(String riskLevel) =>
      _db.patientsDao.getPatientsByRiskLevel(riskLevel);

  /// 30-day daily adherence percentages as integers (0–100).
  Future<List<int>> getAdherenceTrendPct({String? clinicName}) async {
    final raw = await getAdherenceTrend(clinicName: clinicName);
    return raw.map((v) => (v * 100).round()).toList();
  }

  Future<List<double>> getAdherenceTrend({String? clinicName}) async {
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
