import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_event.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthEvent>((event, emit) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final email = user.email;
        final name = user.userMetadata?['name'] as String?;
        emit(AuthSuccess(userId: user.id, email: email, name: name));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: event.email,
          password: event.password,
        );
        
        if (response.user != null) {
          final session = response.session;
          if (session != null) {
            emit(AuthSuccess(userId: response.user!.id, email: response.user!.email));
          } else {
            emit(AuthError('Please check your email to confirm your account'));
          }
        } else {
          emit(AuthError('Sign up failed. Please try again.'));
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError('Sign up failed: ${e.toString()}'));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        
        if (response.user != null) {
          final name = response.user!.userMetadata?['name'] as String?;
          emit(AuthSuccess(userId: response.user!.id, email: response.user!.email, name: name));
        } else {
          emit(AuthError('Login failed. Please try again.'));
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError('Login failed: ${e.toString()}'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      try {
        await Supabase.instance.client.auth.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(event.email);
        emit(AuthSuccess(userId: '', email: event.email));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
