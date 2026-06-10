import 'package:flutter/foundation.dart';

import '../features/auth/domain/auth_models.dart';

/// Holds the identity of the currently authenticated user.
///
/// Set by the auth flow after PIN verification.
/// Cleared on logout.
class SessionProvider extends ChangeNotifier {
  int? _currentPatientId;
  String? _currentWorkerId;
  AuthRole? _role;

  int? get currentPatientId => _currentPatientId;
  String? get currentWorkerId => _currentWorkerId;
  AuthRole? get role => _role;
  bool get isAuthenticated => _role != null;
  bool get isPatient => _role == AuthRole.patient;
  bool get isWorker => _role == AuthRole.worker;

  void signInAsPatient(int patientId) {
    _currentPatientId = patientId;
    _currentWorkerId = null;
    _role = AuthRole.patient;
    notifyListeners();
  }

  void signInAsWorker(String workerId) {
    _currentPatientId = null;
    _currentWorkerId = workerId;
    _role = AuthRole.worker;
    notifyListeners();
  }

  void signOut() {
    _currentPatientId = null;
    _currentWorkerId = null;
    _role = null;
    notifyListeners();
  }
}
