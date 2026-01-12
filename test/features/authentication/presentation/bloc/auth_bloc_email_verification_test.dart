import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  // Property Test: Email Verification Blocks Unverified Users
  // Feature: flutter-auth-app, Property 2: Email Verification Blocks Unverified Users
  group('Property Test: Email Verification Blocks Unverified Users', () {
    test(
      'any user with unverified email should be blocked from proceeding',
      () async {
        // Generate test cases with different user data but all with unverified emails
        final unverifiedUsers = [
          User(
            id: '1',
            email: 'user1@example.com',
            displayName: 'User One',
            isEmailVerified: false,
            provider: AuthProvider.email,
            createdAt: DateTime(2024, 1, 1),
          ),
          User(
            id: '2',
            email: 'user2@test.com',
            displayName: 'User Two',
            isEmailVerified: false,
            provider: AuthProvider.email,
            createdAt: DateTime(2024, 1, 2),
          ),
          User(
            id: '3',
            email: 'user3@domain.org',
            displayName: null,
            isEmailVerified: false,
            provider: AuthProvider.email,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];

        for (final user in unverifiedUsers) {
          // Mock email sign-in to return unverified user
          when(
            () => mockEmailSignIn(user.email, 'password123'),
          ).thenAnswer((_) async => Right(user));

          // Create a new bloc for each test to ensure clean state
          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          // Test that unverified user is blocked
          await expectLater(
            testBloc.stream,
            emitsInOrder([
              AuthLoading(),
              AuthEmailVerificationRequired(user: user),
            ]),
          );

          testBloc.add(
            EmailSignInEvent(email: user.email, password: 'password123'),
          );

          await Future.delayed(const Duration(milliseconds: 100));

          // Verify the user is in verification required state (blocked from proceeding)
          expect(testBloc.state, isA<AuthEmailVerificationRequired>());
          final state = testBloc.state as AuthEmailVerificationRequired;
          expect(state.user.isEmailVerified, isFalse);
          expect(state.user.email, equals(user.email));

          await testBloc.close();
        }
      },
    );

    test('verified users should not be blocked', () async {
      // Test that verified users can proceed normally
      final verifiedUsers = [
        User(
          id: '1',
          email: 'verified1@example.com',
          displayName: 'Verified User One',
          isEmailVerified: true,
          provider: AuthProvider.email,
          createdAt: DateTime(2024, 1, 1),
        ),
        User(
          id: '2',
          email: 'verified2@test.com',
          displayName: 'Verified User Two',
          isEmailVerified: true,
          provider: AuthProvider.email,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      for (final user in verifiedUsers) {
        // Mock email sign-in to return verified user
        when(
          () => mockEmailSignIn(user.email, 'password123'),
        ).thenAnswer((_) async => Right(user));

        // Create a new bloc for each test
        final testBloc = AuthBloc(
          googleSignIn: mockGoogleSignIn,
          appleSignIn: mockAppleSignIn,
          facebookSignIn: mockFacebookSignIn,
          emailSignIn: mockEmailSignIn,
          verifyEmail: mockVerifyEmail,
          checkAuthStatus: mockCheckAuthStatus,
        );

        // Test that verified user is not blocked
        await expectLater(
          testBloc.stream,
          emitsInOrder([AuthLoading(), AuthAuthenticated(user: user)]),
        );

        testBloc.add(
          EmailSignInEvent(email: user.email, password: 'password123'),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the user is authenticated (not blocked)
        expect(testBloc.state, isA<AuthAuthenticated>());
        final state = testBloc.state as AuthAuthenticated;
        expect(state.user.isEmailVerified, isTrue);
        expect(state.user.email, equals(user.email));

        await testBloc.close();
      }
    });

    test(
      'email verification state should prevent navigation to signup flow',
      () async {
        final unverifiedUser = User(
          id: '1',
          email: 'unverified@example.com',
          displayName: 'Unverified User',
          isEmailVerified: false,
          provider: AuthProvider.email,
          createdAt: DateTime(2024, 1, 1),
        );

        // Mock email sign-in to return unverified user
        when(
          () => mockEmailSignIn('unverified@example.com', 'password123'),
        ).thenAnswer((_) async => Right(unverifiedUser));

        // Test the blocking behavior
        authBloc.add(
          const EmailSignInEvent(
            email: 'unverified@example.com',
            password: 'password123',
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Verify user is in verification required state
        expect(authBloc.state, isA<AuthEmailVerificationRequired>());

        // The state should indicate that progress is blocked
        final state = authBloc.state as AuthEmailVerificationRequired;
        expect(state.user.isEmailVerified, isFalse);

        // User should not be in authenticated state (which would allow signup flow)
        expect(authBloc.state, isNot(isA<AuthAuthenticated>()));
      },
    );

    test(
      'verification process should unblock user after successful verification',
      () async {
        final unverifiedUser = User(
          id: '1',
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: false,
          provider: AuthProvider.email,
          createdAt: DateTime(2024, 1, 1),
        );

        // Mock successful email verification
        when(
          () => mockVerifyEmail('test@example.com'),
        ).thenAnswer((_) async => const Right(true));

        // Start with user in verification required state
        authBloc.emit(AuthEmailVerificationRequired(user: unverifiedUser));

        // Verify email
        authBloc.add(const VerifyEmailEvent(email: 'test@example.com'));

        await Future.delayed(const Duration(milliseconds: 100));

        // User should now be unblocked (in verified state)
        expect(authBloc.state, isA<AuthEmailVerified>());
        final state = authBloc.state as AuthEmailVerified;
        expect(state.user.isEmailVerified, isTrue);
      },
    );
  });
}
