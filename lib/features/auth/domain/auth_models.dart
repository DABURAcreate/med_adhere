/// Result of an auth operation — avoids throwing exceptions across the UI.
sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  final int patientId;
  const AuthSuccess(this.patientId);
}

final class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}
