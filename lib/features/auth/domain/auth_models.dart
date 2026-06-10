/// Result of an auth operation — avoids throwing exceptions across the UI.
sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  final int patientId;

  /// True  → new registration, send to PIN setup.
  /// False → existing account restored on a new device, send to login.
  final bool needsPinSetup;

  const AuthSuccess(this.patientId, {this.needsPinSetup = true});
}

final class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}
