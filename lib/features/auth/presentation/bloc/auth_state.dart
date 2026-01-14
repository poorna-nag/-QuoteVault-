abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;
  final String? email;
  final String? name;
  AuthSuccess({required this.userId, this.email, this.name});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {}
