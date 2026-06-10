import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../utils/constants.dart';
import 'conflict_resolver.dart';

/// Summary returned after each sync attempt.
class SyncResult {
  final bool success;
  final int pushed;
  final int pulled;
  final String? error;
  final bool skipped; // true when Firebase is not configured

  const SyncResult._({
    required this.success,
    this.pushed = 0,
    this.pulled = 0,
    this.error,
    this.skipped = false,
  });

  factory SyncResult.notConfigured() =>
      const SyncResult._(success: true, skipped: true);

  factory SyncResult.success({required int pushed, required int pulled}) =>
      SyncResult._(success: true, pushed: pushed, pulled: pulled);

  factory SyncResult.failure(String message) =>
      SyncResult._(success: false, error: message);
}

/// Bidirectional sync between Drift (SQLite) and Cloud Firestore.
///
/// Push: uploads every row flagged isSynced=false to Firestore, then marks
///       those rows as synced.
///
/// Pull: queries Firestore for documents updated after the last successful
///       sync timestamp, applies last-write-wins conflict resolution, and
///       updates the local Drift rows.
///
/// Note: patient PIN hashes are never synced to Firestore for security.
///       The patients collection omits the pinHash field entirely.
class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore? _firestore;

  SyncService({required AppDatabase db})
      : _db = db,
        _firestore = kFirebaseConfigured ? FirebaseFirestore.instance : null;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Runs a full push-then-pull cycle.
  /// Safe to call on every connectivity-restored event — no-ops quickly if
  /// Firebase is not configured.
  Future<SyncResult> sync() async {
    if (!kFirebaseConfigured || _firestore == null) {
      return SyncResult.notConfigured();
    }

    try {
      final pushed = await _push();
      final pulled = await _pull();
      await _saveLastSyncTime(DateTime.now());
      return SyncResult.success(pushed: pushed, pulled: pulled);
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  // ── Push (local → Firestore) ───────────────────────────────────────────────

  Future<int> _push() async {
    int count = 0;
    final fs = _firestore!;

    // Patients (no pinHash)
    final patients = await _db.patientsDao.getUnsyncedPatients();
    for (final p in patients) {
      await fs.collection(kColPatients).doc(p.id.toString()).set(
        {
          'localId': p.id,
          'registrationCode': p.registrationCode,
          'fullName': p.fullName,
          'phoneNumber': p.phoneNumber,
          'dateOfBirth': p.dateOfBirth,
          'gender': p.gender,
          'language': p.language,
          'caregiverPhone': p.caregiverPhone,
          if (p.clinicName != null) 'clinicName': p.clinicName,
          'riskLevel': p.riskLevel,
          'riskScore': p.riskScore,
          'adherencePercentage30Days': p.adherencePercentage30Days,
          'takenDoses30Days': p.takenDoses30Days,
          'missedDoses30Days': p.missedDoses30Days,
          'lastAdherenceLogAt': p.lastAdherenceLogAt != null
              ? Timestamp.fromDate(p.lastAdherenceLogAt!)
              : null,
          'createdAt': Timestamp.fromDate(p.createdAt),
          'updatedAt': Timestamp.fromDate(p.updatedAt),
        },
        SetOptions(merge: true),
      );
      debugPrint('[Sync] Risk summary synced to Firebase for patient ${p.id}.');
      await _db.patientsDao.markAsSynced(p.id);
      count++;
    }

    // Medications
    final meds = await _db.medicationsDao.getUnsyncedMedications();
    for (final m in meds) {
      await fs.collection(kColMedications).doc(m.id.toString()).set(
        {
          'localId': m.id,
          'patientId': m.patientId,
          'name': m.name,
          'dosage': m.dosage,
          'frequency': m.frequency,
          'customTimes': m.customTimes,
          'instructions': m.instructions,
          'startDate': m.startDate,
          'endDate': m.endDate,
          'isActive': m.isActive,
          'stockCount': m.stockCount,
          'refillReminderAt': m.refillReminderAt,
          'createdAt': Timestamp.fromDate(m.createdAt),
          'updatedAt': Timestamp.fromDate(m.updatedAt),
        },
        SetOptions(merge: true),
      );
      await _db.medicationsDao.markAsSynced(m.id);
      count++;
    }

    // Reminders
    final reminders = await _db.remindersDao.getUnsyncedReminders();
    for (final r in reminders) {
      await fs.collection(kColReminders).doc(r.id.toString()).set(
        {
          'localId': r.id,
          'patientId': r.patientId,
          'medicationId': r.medicationId,
          'scheduledTime': r.scheduledTime,
          'activeDays': r.activeDays,
          'deliveryChannel': r.deliveryChannel,
          'isActive': r.isActive,
          'snoozeDurationMinutes': r.snoozeDurationMinutes,
          'lastTriggeredAt': r.lastTriggeredAt != null
              ? Timestamp.fromDate(r.lastTriggeredAt!)
              : null,
          'createdAt': Timestamp.fromDate(r.createdAt),
          'updatedAt': Timestamp.fromDate(r.updatedAt),
        },
        SetOptions(merge: true),
      );
      await _db.remindersDao.markAsSynced(r.id);
      count++;
    }

    // Adherence logs
    final logs = await _db.adherenceLogsDao.getUnsyncedLogs();
    for (final l in logs) {
      await fs.collection(kColAdherenceLogs).doc(l.id.toString()).set(
        {
          'localId': l.id,
          'patientId': l.patientId,
          'medicationId': l.medicationId,
          'reminderId': l.reminderId,
          'status': l.status,
          'scheduledAt': Timestamp.fromDate(l.scheduledAt),
          'takenAt': l.takenAt != null ? Timestamp.fromDate(l.takenAt!) : null,
          'minutesLate': l.minutesLate,
          'note': l.note,
          'isManualEntry': l.isManualEntry,
          'createdAt': Timestamp.fromDate(l.createdAt),
          'updatedAt': Timestamp.fromDate(l.updatedAt),
        },
        SetOptions(merge: true),
      );
      await _db.adherenceLogsDao.markAsSynced(l.id);
      count++;
    }

    return count;
  }

  // ── Pull (Firestore → local) ───────────────────────────────────────────────

  Future<int> _pull() async {
    int count = 0;
    final fs = _firestore!;
    final lastSync = await _getLastSyncTime();
    final since = Timestamp.fromDate(lastSync);

    // Pull patients
    final patientSnap = await fs
        .collection(kColPatients)
        .where('updatedAt', isGreaterThan: since)
        .get();

    for (final doc in patientSnap.docs) {
      final data = doc.data();
      final localId = data['localId'] as int;
      final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();

      final local = await _db.patientsDao.getPatientById(localId);
      if (local == null) continue; // only update existing records; insert is done via auth flow

      if (ConflictResolver.remoteWins(
        localUpdatedAt: local.updatedAt,
        remoteUpdatedAt: remoteUpdatedAt,
        localIsSynced: local.isSynced,
      )) {
        final lastLogTs = data['lastAdherenceLogAt'] as Timestamp?;
        await _db.patientsDao.updatePatientFields(
          localId,
          PatientsCompanion(
            riskLevel: Value(data['riskLevel'] as String? ?? kRiskLow),
            riskScore: Value(data['riskScore'] as int?),
            adherencePercentage30Days:
                Value((data['adherencePercentage30Days'] as num?)?.toDouble()),
            takenDoses30Days: Value(data['takenDoses30Days'] as int?),
            missedDoses30Days: Value(data['missedDoses30Days'] as int?),
            lastAdherenceLogAt: Value(lastLogTs?.toDate()),
            caregiverPhone: Value(data['caregiverPhone'] as String?),
            language: Value(data['language'] as String? ?? 'en'),
            updatedAt: Value(remoteUpdatedAt),
            isSynced: const Value(true),
          ),
        );
        count++;
      }
    }

    // Pull adherence logs — the most critical table to keep in sync
    final logSnap = await fs
        .collection(kColAdherenceLogs)
        .where('updatedAt', isGreaterThan: since)
        .get();

    for (final doc in logSnap.docs) {
      final data = doc.data();
      final localId = data['localId'] as int;
      final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();

      final local = await _db.adherenceLogsDao.getLogById(localId);
      if (local == null) continue;

      if (ConflictResolver.remoteWins(
        localUpdatedAt: local.updatedAt,
        remoteUpdatedAt: remoteUpdatedAt,
        localIsSynced: local.isSynced,
      )) {
        final takenAtTs = data['takenAt'] as Timestamp?;
        await _db.adherenceLogsDao.updateLogFields(
          localId,
          AdherenceLogsCompanion(
            status: Value(data['status'] as String),
            takenAt: Value(takenAtTs?.toDate()),
            minutesLate: Value(data['minutesLate'] as int?),
            note: Value(data['note'] as String?),
            updatedAt: Value(remoteUpdatedAt),
            isSynced: const Value(true),
          ),
        );
        count++;
      }
    }

    return count;
  }

  // ── Last sync timestamp persistence ───────────────────────────────────────

  static const _syncFileName = 'last_sync.json';

  Future<DateTime> _getLastSyncTime() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_syncFileName');
      if (!file.existsSync()) return DateTime(2000);
      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      return DateTime.parse(raw['lastSync'] as String);
    } catch (_) {
      return DateTime(2000);
    }
  }

  Future<void> _saveLastSyncTime(DateTime dt) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_syncFileName');
    file.writeAsStringSync(jsonEncode({'lastSync': dt.toIso8601String()}));
  }
}
