import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Handles PIN hashing and the on-disk session token (current patient ID).
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

  /// Saves the patient ID to disk so it survives app restarts.
  static Future<void> saveSession(int patientId) async {
    final file = await _sessionFile();
    file.writeAsStringSync(jsonEncode({'patientId': patientId}));
  }

  /// Returns the stored patient ID, or null if no session exists.
  static Future<int?> loadSession() async {
    try {
      final file = await _sessionFile();
      if (!file.existsSync()) return null;
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      return data['patientId'] as int?;
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
