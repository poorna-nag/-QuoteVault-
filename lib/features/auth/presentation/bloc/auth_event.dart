abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email, password;
  SignUpEvent(this.email, this.password);
}

class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent(this.email, this.password);
}

class LogoutEvent extends AuthEvent {}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  ResetPasswordEvent(this.email);
}