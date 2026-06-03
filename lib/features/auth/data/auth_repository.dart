import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/security/auth_service.dart';
import '../domain/auth_models.dart';

/// All authentication operations — registration, PIN setup, and login.
class AuthRepository {
  final AppDatabase _db;

  const AuthRepository({required AppDatabase db}) : _db = db;

  /// True when at least one patient record exists on this device.
  /// Used by LanguageScreen to decide login vs registration flow.
  Future<bool> isExistingUser() async {
    final all = await _db.patientsDao.getAllPatients();
    return all.isNotEmpty;
  }

  /// Looks up the patient by registration code.
  /// If none exists locally, creates a placeholder record so the patient
  /// can set their PIN before the worker fills in full details.
  Future<AuthResult> lookupOrCreateByCode(String code) async {
    try {
      var patient = await _db.patientsDao.getPatientByRegistrationCode(code);

      if (patient == null) {
        final id = await _db.patientsDao.insertPatient(
          PatientsCompanion(
            registrationCode: Value(code),
            fullName: const Value(''),
            phoneNumber: const Value(''),
            dateOfBirth: const Value(''),
            gender: const Value('other'),
            pinHash: const Value(''),
          ),
        );
        patient = await _db.patientsDao.getPatientById(id);
      }

      return AuthSuccess(patient!.id);
    } catch (e) {
      return AuthFailure('Could not process registration code: $e');
    }
  }

  /// Hashes [pin], stores it on the patient record, and saves the session.
  Future<AuthResult> setupPin(int patientId, String pin) async {
    try {
      final hash = AuthService.hashPin(pin);
      await _db.patientsDao.updatePinHash(patientId, hash);
      await _db.patientsDao.updatePatientFields(
        patientId,
        PatientsCompanion(isSynced: const Value(false)),
      );
      await AuthService.saveSession(patientId);
      return AuthSuccess(patientId);
    } catch (e) {
      return AuthFailure('Could not save PIN: $e');
    }
  }

  /// Finds the single patient on this device and verifies their PIN.
  /// Returns [AuthSuccess] with the patient ID on match.
  Future<AuthResult> login(String pin) async {
    try {
      final all = await _db.patientsDao.getAllPatients();
      if (all.isEmpty) {
        return const AuthFailure('No account found. Please register first.');
      }
      // Single-device assumption: one patient per install.
      final patient = all.first;
      if (patient.pinHash.isEmpty) {
        return const AuthFailure('PIN not set. Please complete registration.');
      }
      if (!AuthService.verifyPin(pin, patient.pinHash)) {
        return const AuthFailure('Incorrect PIN. Please try again.');
      }
      await AuthService.saveSession(patient.id);
      return AuthSuccess(patient.id);
    } catch (e) {
      return AuthFailure('Login failed: $e');
    }
  }
}
