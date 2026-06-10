import 'package:flutter/foundation.dart';

import '../features/auth/domain/auth_models.dart';

/// Holds the identity of the currently authenticated user.
///
/// Set by the auth flow after PIN verification.
/// Cleared on logout.
class SessionProvider extends ChangeNotifier {
  int? _currentPatientId;
  String? _currentWorkerId;
  String? _workerClinicName;
  String? _workerFullName;
  AuthRole? _role;

  int? get currentPatientId => _currentPatientId;
  String? get currentWorkerId => _currentWorkerId;
  String? get workerClinicName => _workerClinicName;
  String? get workerFullName => _workerFullName;
  AuthRole? get role => _role;
  bool get isAuthenticated => _role != null;
  bool get isPatient => _role == AuthRole.patient;
  bool get isWorker => _role == AuthRole.worker;

  void signInAsPatient(int patientId) {
    _currentPatientId = patientId;
    _currentWorkerId = null;
    _workerClinicName = null;
    _workerFullName = null;
    _role = AuthRole.patient;
    notifyListeners();
  }

  void signInAsWorker(String workerId, {String? clinicName, String? fullName}) {
    _currentPatientId = null;
    _currentWorkerId = workerId;
    _workerClinicName = clinicName;
    _workerFullName = fullName;
    _role = AuthRole.worker;
    notifyListeners();
  }

  void signOut() {
    _currentPatientId = null;
    _currentWorkerId = null;
    _workerClinicName = null;
    _workerFullName = null;
    _role = null;
    notifyListeners();
  }
}
