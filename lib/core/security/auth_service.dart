import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

// Worker credential cache stored locally so workers can log in offline.
// Format: [{"workerId":…,"pinHash":…,"fullName":…,"clinicName":…}]

/// Handles PIN hashing and the on-disk session token.
///
/// PIN storage uses SHA-256. This is acceptable for a 4-digit device PIN
/// because the threat model is device-local; the hash is never transmitted.
/// Upgrade to bcrypt/argon2 if the hash ever leaves the device.
class AuthService {
  AuthService._();

  static const _sessionFileName = 'session.json';

  // ── PIN ───────────────────────────────────────────────────────────────────

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static bool verifyPin(String pin, String storedHash) =>
      hashPin(pin) == storedHash;

  // ── Persisted session ─────────────────────────────────────────────────────

  /// Saves the current session to disk so it survives app restarts.
  /// Pass either [patientId] (for patients) or [workerId] (for workers).
  static Future<void> saveSession({
    int? patientId,
    String? workerId,
    String? workerClinicName,
    String? workerFullName,
  }) async {
    final file = await _sessionFile();
    final data = <String, dynamic>{};
    if (patientId != null) {
      data['patientId'] = patientId;
      data['role'] = 'patient';
    } else if (workerId != null) {
      data['workerId'] = workerId;
      data['role'] = 'worker';
      if (workerClinicName != null) data['workerClinicName'] = workerClinicName;
      if (workerFullName != null) data['workerFullName'] = workerFullName;
    }
    file.writeAsStringSync(jsonEncode(data));
  }

  /// Returns the stored session, or null if no valid session exists.
  /// Handles the legacy format (patient-only, no role field).
  static Future<
      ({
        String role,
        int? patientId,
        String? workerId,
        String? workerClinicName,
        String? workerFullName,
      })?> loadSession() async {
    try {
      final file = await _sessionFile();
      if (!file.existsSync()) return null;
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final role = data['role'] as String? ?? 'patient';
      final patientId = data['patientId'] as int?;
      final workerId = data['workerId'] as String?;
      final workerClinicName = data['workerClinicName'] as String?;
      final workerFullName = data['workerFullName'] as String?;

      if (role == 'patient' && patientId != null) {
        return (
          role: 'patient',
          patientId: patientId,
          workerId: null,
          workerClinicName: null,
          workerFullName: null,
        );
      }
      if (role == 'worker' && workerId != null) {
        return (
          role: 'worker',
          patientId: null,
          workerId: workerId,
          workerClinicName: workerClinicName,
          workerFullName: workerFullName,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Clears the stored session (used on logout).
  static Future<void> clearSession() async {
    final file = await _sessionFile();
    if (file.existsSync()) file.deleteSync();
  }

  static Future<File> _sessionFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_sessionFileName');
  }

  // ── Worker credential cache ───────────────────────────────────────────────

  static const _workerCacheFileName = 'workers_cache.json';

  /// Persists a worker's credentials locally so they can log in without
  /// internet on subsequent sessions.
  static Future<void> cacheWorker({
    required String workerId,
    required String pinHash,
    String? fullName,
    String? clinicName,
  }) async {
    final workers = await _loadWorkerCache();
    final entry = <String, dynamic>{
      'workerId': workerId,
      'pinHash': pinHash,
      'fullName': ?fullName,
      'clinicName': ?clinicName,
    };
    final idx = workers.indexWhere((w) => w['workerId'] == workerId);
    if (idx >= 0) {
      workers[idx] = entry;
    } else {
      workers.add(entry);
    }
    await _saveWorkerCache(workers);
  }

  /// Returns a cached worker whose pinHash matches, or null if not found.
  static Future<Map<String, dynamic>?> lookupCachedWorkerByPinHash(
      String pinHash) async {
    final workers = await _loadWorkerCache();
    for (final w in workers) {
      if (w['pinHash'] == pinHash) return w;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _loadWorkerCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_workerCacheFileName');
      if (!file.existsSync()) return [];
      final raw =
          jsonDecode(file.readAsStringSync()) as List<dynamic>;
      return raw.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveWorkerCache(
      List<Map<String, dynamic>> workers) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_workerCacheFileName');
    file.writeAsStringSync(jsonEncode(workers));
  }
}
