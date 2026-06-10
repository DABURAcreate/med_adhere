enum AuthRole { patient, worker }

/// Result of an auth operation — avoids throwing exceptions across the UI.
sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  final AuthRole role;
  final String userId; // int string for patients, Firestore doc ID for workers
  const AuthSuccess({required this.role, required this.userId});
}

final class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}
