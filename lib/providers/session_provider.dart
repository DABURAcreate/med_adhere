import 'package:flutter/foundation.dart';

/// Holds the identity of the currently authenticated user.
///
/// Set by the auth flow after PIN verification.
/// Cleared on logout.
///
/// Screens that need the current patient id read:
///   context.read[SessionProvider]().currentPatientId
class SessionProvider extends ChangeNotifier {
  int? _currentPatientId;
  String _role = 'patient'; // 'patient' | 'worker'

  int? get currentPatientId => _currentPatientId;
  String get role => _role;
  bool get isAuthenticated => _currentPatientId != null;

  void signInAsPatient(int patientId) {
    _currentPatientId = patientId;
    _role = 'patient';
    notifyListeners();
  }

  void signInAsWorker() {
    _currentPatientId = null;
    _role = 'worker';
    notifyListeners();
  }

  void signOut() {
    _currentPatientId = null;
    _role = 'patient';
    notifyListeners();
  }
}
