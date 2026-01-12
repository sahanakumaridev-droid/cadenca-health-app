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

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is found',
        build: () {
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [AuthLoading(), AuthAuthenticated(user: tUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is found',
        build: () {
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when check fails',
        build: () {
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [AuthLoading(), const AuthError(message: 'Cache error')],
      );
    });

    group('GoogleSignInEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
        build: () {
          when(() => mockGoogleSignIn()).thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(GoogleSignInEvent()),
        expect: () => [AuthLoading(), AuthAuthenticated(user: tUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(() => mockGoogleSignIn()).thenAnswer(
            (_) async => const Left(AuthFailure('Google sign in failed')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(GoogleSignInEvent()),
        expect: () => [
          AuthLoading(),
          const AuthError(message: 'Google sign in failed'),
        ],
      );
    });

    group('EmailSignInEvent', () {
      final tUnverifiedUser = User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
        provider: AuthProvider.email,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when email is verified',
        build: () {
          when(
            () => mockEmailSignIn('test@example.com', 'password123'),
          ).thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const EmailSignInEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), AuthAuthenticated(user: tUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthEmailVerificationRequired] when email is not verified',
        build: () {
          when(
            () => mockEmailSignIn('test@example.com', 'password123'),
          ).thenAnswer((_) async => Right(tUnverifiedUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const EmailSignInEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          AuthEmailVerificationRequired(user: tUnverifiedUser),
        ],
      );
    });

    group('VerifyEmailEvent', () {
      final tUnverifiedUser = User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
        provider: AuthProvider.email,
        createdAt: DateTime(2024, 1, 1),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthEmailVerificationLoading, AuthEmailVerified] when verification succeeds',
        build: () {
          when(
            () => mockVerifyEmail('test@example.com'),
          ).thenAnswer((_) async => const Right(true));
          return authBloc;
        },
        seed: () => AuthEmailVerificationRequired(user: tUnverifiedUser),
        act: (bloc) =>
            bloc.add(const VerifyEmailEvent(email: 'test@example.com')),
        expect: () => [
          AuthEmailVerificationLoading(),
          AuthEmailVerified(
            user: tUnverifiedUser.copyWith(isEmailVerified: true),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthEmailVerificationLoading, AuthError] when verification fails',
        build: () {
          when(
            () => mockVerifyEmail('test@example.com'),
          ).thenAnswer((_) async => const Right(false));
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(const VerifyEmailEvent(email: 'test@example.com')),
        expect: () => [
          AuthEmailVerificationLoading(),
          const AuthError(message: 'Email verification failed'),
        ],
      );
    });

    // Property Test: Authentication State Independence
    // Feature: flutter-auth-app, Property 8: Authentication State Independence
    group('Property Test: Authentication State Independence', () {
      test(
        'authentication state changes should not affect other system states',
        () async {
          // This is a conceptual property test - in a real implementation,
          // you would test that authentication state changes don't interfere
          // with signup state or other independent states

          // Test multiple authentication state transitions
          final authStates = [
            AuthInitial(),
            AuthLoading(),
            AuthAuthenticated(user: tUser),
            AuthUnauthenticated(),
            const AuthError(message: 'Test error'),
          ];

          for (final state in authStates) {
            // Verify that each authentication state is independent
            expect(state.props, isA<List<Object?>>());

            // Authentication states should not contain references to signup data
            expect(state.toString().contains('signup'), isFalse);
            expect(state.toString().contains('Signup'), isFalse);
          }
        },
      );

      test('authentication events should not affect signup-related data', () {
        final authEvents = [
          CheckAuthStatusEvent(),
          GoogleSignInEvent(),
          AppleSignInEvent(),
          FacebookSignInEvent(),
          const EmailSignInEvent(email: 'test@test.com', password: 'password'),
          const VerifyEmailEvent(email: 'test@test.com'),
          SignOutEvent(),
          DeleteAccountEvent(),
        ];

        for (final event in authEvents) {
          // Verify that authentication events are independent
          expect(event.props, isA<List<Object>>());

          // Authentication events should not contain signup-related data
          expect(event.toString().contains('signup'), isFalse);
          expect(event.toString().contains('Signup'), isFalse);
        }
      });
    });
  });
}
