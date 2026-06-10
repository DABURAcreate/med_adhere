import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/constants.dart';
import '../presentation/report_export_service.dart';

class _Bucket {
  int taken = 0;
  int missed = 0;
}

class ReportRepository {
  final AppDatabase _db;

  ReportRepository({required AppDatabase db}) : _db = db;

  // ── Patient list ────────────────────────────────────────────────────────────

  Future<List<Patient>> getClinicPatients(String? clinicName) async {
    if (clinicName == null || clinicName.isEmpty) {
      return _db.patientsDao.getAllPatients();
    }
    return _db.patientsDao.getPatientsByClinic(clinicName);
  }

  // ── Per-patient rows: (date × medication) ──────────────────────────────────

  Future<List<ReportRow>> getPatientReportRows({
    required int patientId,
    required DateTime from,
    required DateTime to,
  }) async {
    final logs = await _db.adherenceLogsDao.getLogsInRange(
      patientId: patientId,
      from: from,
      to: to,
    );

    if (logs.isEmpty) return [];

    final meds = await _db.medicationsDao.getMedicationsForPatient(patientId);
    final medNames = {for (final m in meds) m.id: m.name};

    final Map<String, Map<int, _Bucket>> grouped = {};
    for (final log in logs) {
      final dateStr = _fmt(log.scheduledAt);
      grouped.putIfAbsent(dateStr, () => {});
      grouped[dateStr]!.putIfAbsent(log.medicationId, () => _Bucket());
      final b = grouped[dateStr]![log.medicationId]!;
      if (log.status == kStatusTaken || log.status == kStatusLate) {
        b.taken++;
      } else if (log.status == kStatusMissed) {
        b.missed++;
      }
    }

    final rows = <ReportRow>[];
    final sortedDates = grouped.keys.toList()..sort();
    for (final dateStr in sortedDates) {
      final medMap = grouped[dateStr]!;
      for (final medId in medMap.keys) {
        final b = medMap[medId]!;
        final total = b.taken + b.missed;
        final adherence = total == 0 ? 0.0 : b.taken / total * 100;
        rows.add(ReportRow(
          date: dateStr,
          subject: medNames[medId] ?? 'Medication',
          taken: b.taken,
          missed: b.missed,
          adherence: adherence,
        ));
      }
    }

    debugPrint('[Report] Per-patient rows generated: ${rows.length} rows for patientId=$patientId');
    return rows;
  }

  // ── Per-clinic rows: one row per patient ────────────────────────────────────

  Future<List<ReportRow>> getClinicReportRows({
    String? clinicName,
    required DateTime from,
    required DateTime to,
  }) async {
    final patients = await getClinicPatients(clinicName);
    final rows = <ReportRow>[];

    for (final p in patients) {
      final logs = await _db.adherenceLogsDao.getLogsInRange(
        patientId: p.id,
        from: from,
        to: to,
      );
      int taken = 0;
      int missed = 0;
      for (final l in logs) {
        if (l.status == kStatusTaken || l.status == kStatusLate) {
          taken++;
        } else if (l.status == kStatusMissed) {
          missed++;
        }
      }
      final total = taken + missed;
      final adherence = total == 0 ? 0.0 : taken / total * 100;
      rows.add(ReportRow(
        date: '${_fmt(from)} – ${_fmt(to)}',
        subject: p.fullName,
        taken: taken,
        missed: missed,
        adherence: adherence,
      ));
    }

    debugPrint('[Report] Per-clinic rows generated: ${rows.length} patients, clinic=$clinicName');
    return rows;
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
