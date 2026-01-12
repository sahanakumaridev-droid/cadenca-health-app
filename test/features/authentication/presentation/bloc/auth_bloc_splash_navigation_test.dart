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

  // Property Test: Splash Screen Navigation Based on Authentication State
  // Feature: flutter-auth-app, Property 1: Splash Screen Navigation Based on Authentication State
  group('Property Test: Splash Screen Navigation Based on Authentication State', () {
    test(
      'for any authentication state, splash screen should redirect to appropriate screen',
      () async {
        // Test cases covering all possible authentication states
        final testCases = [
          {
            'description': 'Authenticated user with Google provider',
            'user': User(
              id: '1',
              email: 'google@example.com',
              displayName: 'Google User',
              isEmailVerified: true,
              provider: AuthProvider.google,
              createdAt: DateTime(2024, 1, 1),
            ),
            'expectedState': 'AuthAuthenticated',
            'expectedNavigation': 'Home',
          },
          {
            'description': 'Authenticated user with Apple provider',
            'user': User(
              id: '2',
              email: 'apple@example.com',
              displayName: 'Apple User',
              isEmailVerified: true,
              provider: AuthProvider.apple,
              createdAt: DateTime(2024, 1, 2),
            ),
            'expectedState': 'AuthAuthenticated',
            'expectedNavigation': 'Home',
          },
          {
            'description': 'Authenticated user with Facebook provider',
            'user': User(
              id: '3',
              email: 'facebook@example.com',
              displayName: 'Facebook User',
              isEmailVerified: true,
              provider: AuthProvider.facebook,
              createdAt: DateTime(2024, 1, 3),
            ),
            'expectedState': 'AuthAuthenticated',
            'expectedNavigation': 'Home',
          },
          {
            'description': 'Authenticated user with Email provider',
            'user': User(
              id: '4',
              email: 'email@example.com',
              displayName: 'Email User',
              isEmailVerified: true,
              provider: AuthProvider.email,
              createdAt: DateTime(2024, 1, 4),
            ),
            'expectedState': 'AuthAuthenticated',
            'expectedNavigation': 'Home',
          },
          {
            'description': 'No authenticated user',
            'user': null,
            'expectedState': 'AuthUnauthenticated',
            'expectedNavigation': 'Login',
          },
        ];

        for (final testCase in testCases) {
          final user = testCase['user'] as User?;
          final expectedState = testCase['expectedState'] as String;

          // Mock the check auth status use case
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => Right(user));

          // Create a new bloc for each test case to ensure clean state
          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          // Test the splash screen authentication check
          await expectLater(
            testBloc.stream,
            emitsInOrder([
              AuthLoading(),
              if (expectedState == 'AuthAuthenticated')
                AuthAuthenticated(user: user!)
              else
                AuthUnauthenticated(),
            ]),
          );

          testBloc.add(CheckAuthStatusEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify the correct state is emitted for navigation
          if (expectedState == 'AuthAuthenticated') {
            expect(testBloc.state, isA<AuthAuthenticated>());
            final state = testBloc.state as AuthAuthenticated;
            expect(state.user, equals(user));
            // This state should trigger navigation to Home screen
          } else {
            expect(testBloc.state, isA<AuthUnauthenticated>());
            // This state should trigger navigation to Login screen
          }

          await testBloc.close();
        }
      },
    );

    test(
      'authentication check failures should redirect to login screen',
      () async {
        // Test various failure scenarios that should all redirect to login
        final failureTestCases = [
          const CacheFailure('Cache error'),
          const NetworkFailure('Network error'),
          const AuthFailure('Authentication error'),
          const ServerFailure('Server error'),
        ];

        for (final failure in failureTestCases) {
          // Mock the check auth status to return failure
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => Left(failure));

          // Create a new bloc for each test case
          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          // Test that failure results in error state (which should redirect to login)
          await expectLater(
            testBloc.stream,
            emitsInOrder([AuthLoading(), AuthError(message: failure.message)]),
          );

          testBloc.add(CheckAuthStatusEvent());
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify error state is emitted (should trigger navigation to Login)
          expect(testBloc.state, isA<AuthError>());
          final state = testBloc.state as AuthError;
          expect(state.message, equals(failure.message));

          await testBloc.close();
        }
      },
    );

    test(
      'authentication state should determine navigation consistently',
      () async {
        // Property: The same authentication state should always result in the same navigation
        final authenticatedUser = User(
          id: '1',
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: true,
          provider: AuthProvider.google,
          createdAt: DateTime(2024, 1, 1),
        );

        // Test multiple times with the same authenticated user
        for (int i = 0; i < 5; i++) {
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => Right(authenticatedUser));

          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          testBloc.add(CheckAuthStatusEvent());
          await Future.delayed(const Duration(milliseconds: 50));

          // Should always result in AuthAuthenticated state
          expect(testBloc.state, isA<AuthAuthenticated>());
          final state = testBloc.state as AuthAuthenticated;
          expect(state.user, equals(authenticatedUser));

          await testBloc.close();
        }

        // Test multiple times with no authenticated user
        for (int i = 0; i < 5; i++) {
          when(
            () => mockCheckAuthStatus(),
          ).thenAnswer((_) async => const Right(null));

          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          testBloc.add(CheckAuthStatusEvent());
          await Future.delayed(const Duration(milliseconds: 50));

          // Should always result in AuthUnauthenticated state
          expect(testBloc.state, isA<AuthUnauthenticated>());

          await testBloc.close();
        }
      },
    );

    test('navigation decision should be independent of user details', () async {
      // Property: Navigation should depend only on authentication status, not user details
      final authenticatedUsers = [
        User(
          id: '1',
          email: 'user1@example.com',
          displayName: 'User One',
          isEmailVerified: true,
          provider: AuthProvider.google,
          createdAt: DateTime(2024, 1, 1),
        ),
        User(
          id: '2',
          email: 'user2@different-domain.org',
          displayName: null, // No display name
          isEmailVerified: true,
          provider: AuthProvider.apple,
          createdAt: DateTime(2024, 1, 2),
        ),
        User(
          id: '3',
          email: 'very-long-email-address@some-long-domain-name.com',
          displayName: 'User With Very Long Display Name',
          isEmailVerified: true,
          provider: AuthProvider.facebook,
          createdAt: DateTime(2024, 1, 3),
        ),
      ];

      // All authenticated users should result in the same navigation decision
      for (final user in authenticatedUsers) {
        when(() => mockCheckAuthStatus()).thenAnswer((_) async => Right(user));

        final testBloc = AuthBloc(
          googleSignIn: mockGoogleSignIn,
          appleSignIn: mockAppleSignIn,
          facebookSignIn: mockFacebookSignIn,
          emailSignIn: mockEmailSignIn,
          verifyEmail: mockVerifyEmail,
          checkAuthStatus: mockCheckAuthStatus,
        );

        testBloc.add(CheckAuthStatusEvent());
        await Future.delayed(const Duration(milliseconds: 50));

        // Regardless of user details, should always be AuthAuthenticated (navigate to Home)
        expect(testBloc.state, isA<AuthAuthenticated>());
        final state = testBloc.state as AuthAuthenticated;
        expect(
          state.user.isEmailVerified,
          isTrue,
        ); // All should be verified for home navigation

        await testBloc.close();
      }
    });

    test('splash screen timing should not affect navigation decision', () async {
      // Property: Navigation decision should be based on auth state, not timing
      final authenticatedUser = User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        provider: AuthProvider.google,
        createdAt: DateTime(2024, 1, 1),
      );

      // Test with different response delays
      final delays = [0, 50, 100, 200, 500]; // milliseconds

      for (final delay in delays) {
        when(() => mockCheckAuthStatus()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: delay));
          return Right(authenticatedUser);
        });

        final testBloc = AuthBloc(
          googleSignIn: mockGoogleSignIn,
          appleSignIn: mockAppleSignIn,
          facebookSignIn: mockFacebookSignIn,
          emailSignIn: mockEmailSignIn,
          verifyEmail: mockVerifyEmail,
          checkAuthStatus: mockCheckAuthStatus,
        );

        testBloc.add(CheckAuthStatusEvent());
        await Future.delayed(Duration(milliseconds: delay + 100));

        // Regardless of timing, should always result in same navigation decision
        expect(testBloc.state, isA<AuthAuthenticated>());
        final state = testBloc.state as AuthAuthenticated;
        expect(state.user, equals(authenticatedUser));

        await testBloc.close();
      }
    });
  });
}
