import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

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
}
