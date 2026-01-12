import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_auth_app/core/error/failures.dart';
import 'package:flutter_auth_app/features/authentication/domain/entities/user.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/apple_sign_in.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/check_auth_status.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/email_sign_in.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/facebook_sign_in.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/google_sign_in.dart';
import 'package:flutter_auth_app/features/authentication/domain/usecases/verify_email.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_state.dart';

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockAppleSignInUseCase extends Mock implements AppleSignInUseCase {}

class MockFacebookSignInUseCase extends Mock implements FacebookSignInUseCase {}

class MockEmailSignInUseCase extends Mock implements EmailSignInUseCase {}

class MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockGoogleSignInUseCase mockGoogleSignIn;
  late MockAppleSignInUseCase mockAppleSignIn;
  late MockFacebookSignInUseCase mockFacebookSignIn;
  late MockEmailSignInUseCase mockEmailSignIn;
  late MockVerifyEmailUseCase mockVerifyEmail;
  late MockCheckAuthStatusUseCase mockCheckAuthStatus;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignInUseCase();
    mockAppleSignIn = MockAppleSignInUseCase();
    mockFacebookSignIn = MockFacebookSignInUseCase();
    mockEmailSignIn = MockEmailSignInUseCase();
    mockVerifyEmail = MockVerifyEmailUseCase();
    mockCheckAuthStatus = MockCheckAuthStatusUseCase();

    authBloc = AuthBloc(
      googleSignIn: mockGoogleSignIn,
      appleSignIn: mockAppleSignIn,
      facebookSignIn: mockFacebookSignIn,
      emailSignIn: mockEmailSignIn,
      verifyEmail: mockVerifyEmail,
      checkAuthStatus: mockCheckAuthStatus,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = User(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: true,
    provider: AuthProvider.google,
    createdAt: DateTime(2024, 1, 1),
  );

  group('AuthBloc Unit Tests', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AppleSignInEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when Apple sign in succeeds',
        build: () {
          when(() => mockAppleSignIn()).thenAnswer(
            (_) async => Right(tUser.copyWith(provider: AuthProvider.apple)),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(AppleSignInEvent()),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(user: tUser.copyWith(provider: AuthProvider.apple)),
        ],
        verify: (_) {
          verify(() => mockAppleSignIn()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Apple sign in fails',
        build: () {
          when(() => mockAppleSignIn()).thenAnswer(
            (_) async => const Left(AuthFailure('Apple sign in failed')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(AppleSignInEvent()),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Apple sign in failed'),
        ],
        verify: (_) {
          verify(() => mockAppleSignIn()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Apple sign in throws network failure',
        build: () {
          when(() => mockAppleSignIn()).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet connection')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(AppleSignInEvent()),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'No internet connection'),
        ],
      );
    });

    group('FacebookSignInEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when Facebook sign in succeeds',
        build: () {
          when(() => mockFacebookSignIn()).thenAnswer(
            (_) async => Right(tUser.copyWith(provider: AuthProvider.facebook)),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(FacebookSignInEvent()),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(
            user: tUser.copyWith(provider: AuthProvider.facebook),
          ),
        ],
        verify: (_) {
          verify(() => mockFacebookSignIn()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when Facebook sign in fails',
        build: () {
          when(() => mockFacebookSignIn()).thenAnswer(
            (_) async => const Left(AuthFailure('Facebook sign in failed')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(FacebookSignInEvent()),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Facebook sign in failed'),
        ],
        verify: (_) {
          verify(() => mockFacebookSignIn()).called(1);
        },
      );
    });

    group('EmailSignInEvent - Edge Cases', () {
      blocTest<AuthBloc, AuthState>(
        'handles empty email gracefully',
        build: () {
          when(() => mockEmailSignIn('', 'password123')).thenAnswer(
            (_) async => const Left(ValidationFailure('Email is required')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const EmailSignInEvent(email: '', password: 'password123'),
        ),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Email is required'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles empty password gracefully',
        build: () {
          when(() => mockEmailSignIn('test@example.com', '')).thenAnswer(
            (_) async => const Left(ValidationFailure('Password is required')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const EmailSignInEvent(email: 'test@example.com', password: ''),
        ),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Password is required'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles invalid email format',
        build: () {
          when(
            () => mockEmailSignIn('invalid-email', 'password123'),
          ).thenAnswer(
            (_) async => const Left(ValidationFailure('Invalid email format')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const EmailSignInEvent(
            email: 'invalid-email',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Invalid email format'),
        ],
      );
    });

    group('VerifyEmailEvent - Edge Cases', () {
      blocTest<AuthBloc, AuthState>(
        'handles verification failure gracefully',
        build: () {
          when(() => mockVerifyEmail('test@example.com')).thenAnswer(
            (_) async =>
                const Left(NetworkFailure('Verification service unavailable')),
          );
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(const VerifyEmailEvent(email: 'test@example.com')),
        expect: () => [
          AuthEmailVerificationLoading(),
          const AuthError(message: 'Verification service unavailable'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles verification timeout',
        build: () {
          when(() => mockVerifyEmail('test@example.com')).thenAnswer(
            (_) async => const Left(NetworkFailure('Verification timeout')),
          );
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(const VerifyEmailEvent(email: 'test@example.com')),
        expect: () => [
          AuthEmailVerificationLoading(),
          const AuthError(message: 'Verification timeout'),
        ],
      );
    });

    group('SignOutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSignOutSuccess, AuthUnauthenticated] when sign out succeeds',
        build: () => authBloc,
        act: (bloc) => bloc.add(SignOutEvent()),
        expect: () => [
          AuthLoading(),
          AuthSignOutSuccess(),
          AuthUnauthenticated(),
        ],
      );
    });

    group('DeleteAccountEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAccountDeleted, AuthUnauthenticated] when account deletion succeeds',
        build: () => authBloc,
        act: (bloc) => bloc.add(DeleteAccountEvent()),
        expect: () => [
          AuthLoading(),
          AuthAccountDeleted(),
          AuthUnauthenticated(),
        ],
      );
    });

    group('State Transitions', () {
      test('AuthState equality works correctly', () {
        final state1 = AuthAuthenticated(user: tUser);
        final state2 = AuthAuthenticated(user: tUser);
        const state3 = AuthError(message: 'Error');

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('AuthEvent equality works correctly', () {
        const event1 = EmailSignInEvent(
          email: 'test@test.com',
          password: 'password',
        );
        const event2 = EmailSignInEvent(
          email: 'test@test.com',
          password: 'password',
        );
        const event3 = EmailSignInEvent(
          email: 'different@test.com',
          password: 'password',
        );

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('Error Handling', () {
      blocTest<AuthBloc, AuthState>(
        'handles multiple consecutive failures gracefully',
        build: () {
          when(
            () => mockGoogleSignIn(),
          ).thenAnswer((_) async => const Left(AuthFailure('Google failed')));
          when(
            () => mockAppleSignIn(),
          ).thenAnswer((_) async => const Left(AuthFailure('Apple failed')));
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(GoogleSignInEvent());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(AppleSignInEvent());
        },
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Google failed'),
          AuthLoading(),
          const AuthError(message: 'Apple failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'recovers from error state when successful authentication occurs',
        build: () {
          when(
            () => mockGoogleSignIn(),
          ).thenAnswer((_) async => const Left(AuthFailure('Google failed')));
          when(() => mockAppleSignIn()).thenAnswer(
            (_) async => Right(tUser.copyWith(provider: AuthProvider.apple)),
          );
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(GoogleSignInEvent());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(AppleSignInEvent());
        },
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Google failed'),
          AuthLoading(),
          AuthAuthenticated(user: tUser.copyWith(provider: AuthProvider.apple)),
        ],
      );
    });
  });
}
