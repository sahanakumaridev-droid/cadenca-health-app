import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/apple_sign_in.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/email_sign_in.dart';
import '../../domain/usecases/facebook_sign_in.dart';
import '../../domain/usecases/google_sign_in.dart';
import '../../domain/usecases/verify_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignInUseCase googleSignIn;
  final AppleSignInUseCase appleSignIn;
  final FacebookSignInUseCase facebookSignIn;
  final EmailSignInUseCase emailSignIn;
  final VerifyEmailUseCase verifyEmail;
  final CheckAuthStatusUseCase checkAuthStatus;

  AuthBloc({
    required this.googleSignIn,
    required this.appleSignIn,
    required this.facebookSignIn,
    required this.emailSignIn,
    required this.verifyEmail,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<AppleSignInEvent>(_onAppleSignIn);
    on<FacebookSignInEvent>(_onFacebookSignIn);
    on<EmailSignInEvent>(_onEmailSignIn);
    on<EmailSignUpEvent>(_onEmailSignUp);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<SignOutEvent>(_onSignOut);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthStatus();

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await googleSignIn();

    result.fold((failure) {
      // Check if it's a cancellation - don't show error, just go back to unauthenticated
      if (failure.message.contains('cancelled') ||
          failure.message.contains('canceled')) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthError(message: failure.message));
      }
    }, (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onAppleSignIn(
    AppleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await appleSignIn();

    result.fold((failure) {
      // Check if it's a cancellation - don't show error, just go back to unauthenticated
      if (failure.message.contains('cancelled') ||
          failure.message.contains('canceled')) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthError(message: failure.message));
      }
    }, (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onFacebookSignIn(
    FacebookSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await facebookSignIn();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onEmailSignIn(
    EmailSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await emailSignIn(event.email, event.password);

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      if (user.isEmailVerified) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthEmailVerificationRequired(user: user));
      }
    });
  }

  Future<void> _onEmailSignUp(
    EmailSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // For now, use the same emailSignIn use case which will create account if it doesn't exist
    // In a real implementation, you would have a separate emailSignUp use case
    final result = await emailSignIn(event.email, event.password);

    result.fold((failure) => emit(AuthError(message: failure.message)), (user) {
      // After signup, always require email verification
      emit(AuthEmailVerificationRequired(user: user));
    });
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthEmailVerificationLoading());

    final result = await verifyEmail(event.email);

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      isVerified,
    ) {
      if (isVerified) {
        // Get the current user from state if available
        if (state is AuthEmailVerificationRequired) {
          final currentUser = (state as AuthEmailVerificationRequired).user;
          final verifiedUser = currentUser.copyWith(isEmailVerified: true);
          emit(AuthEmailVerified(user: verifiedUser));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(const AuthError(message: 'Email verification failed'));
      }
    });
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // In a real implementation, you would call a sign-out use case
    // For now, we'll just emit the unauthenticated state
    emit(AuthSignOutSuccess());
    emit(AuthUnauthenticated());
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // In a real implementation, you would call a delete account use case
    // For now, we'll just emit the account deleted state
    emit(AuthAccountDeleted());
    emit(AuthUnauthenticated());
  }
}
