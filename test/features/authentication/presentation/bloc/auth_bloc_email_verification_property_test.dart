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

  // Property Test 9: Email Verification Trigger
  // Feature: flutter-auth-app, Property 9: Email Verification Trigger
  group('Property Test: Email Verification Trigger', () {
    test(
      'for any email sign-in with unverified email, email verification should be triggered',
      () async {
        // Test various unverified email scenarios
        final testCases = [
          {
            'email': 'test@example.com',
            'password': 'password123',
            'displayName': 'Test User',
          },
          {
            'email': 'user@domain.org',
            'password': 'securepass456',
            'displayName': 'Another User',
          },
          {
            'email': 'newuser@company.net',
            'password': 'mypassword789',
            'displayName': null, // Test with null display name
          },
        ];

        for (final testCase in testCases) {
          final email = testCase['email']!;
          final password = testCase['password']!;
          final displayName = testCase['displayName'];

          // Create unverified user
          final unverifiedUser = User(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            displayName: displayName,
            isEmailVerified: false, // Key: email is not verified
            provider: AuthProvider.email,
            createdAt: DateTime.now(),
          );

          // Mock email sign-in to return unverified user
          when(
            () => mockEmailSignIn(email, password),
          ).thenAnswer((_) async => Right(unverifiedUser));

          // Create a new bloc for each test case
          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          // Test that email verification is triggered for unverified users
          testBloc.add(EmailSignInEvent(email: email, password: password));
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify email sign-in was called
          verify(() => mockEmailSignIn(email, password)).called(1);

          // Check that the bloc emitted the correct state
          expect(testBloc.state, isA<AuthEmailVerificationRequired>());
          final state = testBloc.state as AuthEmailVerificationRequired;
          expect(state.user.email, equals(email));
          expect(state.user.isEmailVerified, false);

          await testBloc.close();
        }
      },
    );

    test(
      'verified email users should not trigger email verification',
      () async {
        const email = 'verified@example.com';
        const password = 'password123';

        // Create verified user
        final verifiedUser = User(
          id: 'verified_user',
          email: email,
          displayName: 'Verified User',
          isEmailVerified: true, // Key: email is verified
          provider: AuthProvider.email,
          createdAt: DateTime.now(),
        );

        // Mock email sign-in to return verified user
        when(
          () => mockEmailSignIn(email, password),
        ).thenAnswer((_) async => Right(verifiedUser));

        // Test that verified users go directly to authenticated state
        authBloc.add(const EmailSignInEvent(email: email, password: password));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify email sign-in was called
        verify(() => mockEmailSignIn(email, password)).called(1);

        // Check that the bloc emitted the correct state
        expect(authBloc.state, isA<AuthAuthenticated>());
        final state = authBloc.state as AuthAuthenticated;
        expect(state.user.email, equals(email));
        expect(state.user.isEmailVerified, true);
      },
    );
  });

  // Property Test 10: Verified Email Navigation
  // Feature: flutter-auth-app, Property 10: Verified Email Navigation
  group('Property Test: Verified Email Navigation', () {
    test(
      'for any user with verified email, navigation should proceed to signup flow',
      () async {
        // Test various verified email scenarios
        final testCases = [
          {'email': 'verified1@example.com', 'displayName': 'User One'},
          {'email': 'verified2@domain.org', 'displayName': 'User Two'},
          {
            'email': 'verified3@company.net',
            'displayName': null, // Test with null display name
          },
        ];

        for (final testCase in testCases) {
          final email = testCase['email']!;
          final displayName = testCase['displayName'];

          // Mock email verification to return success
          when(
            () => mockVerifyEmail(email),
          ).thenAnswer((_) async => const Right(true));

          // Create a new bloc for each test case
          final testBloc = AuthBloc(
            googleSignIn: mockGoogleSignIn,
            appleSignIn: mockAppleSignIn,
            facebookSignIn: mockFacebookSignIn,
            emailSignIn: mockEmailSignIn,
            verifyEmail: mockVerifyEmail,
            checkAuthStatus: mockCheckAuthStatus,
          );

          // First, set up the bloc in the email verification required state
          final unverifiedUser = User(
            id: 'unverified_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            displayName: displayName,
            isEmailVerified: false,
            provider: AuthProvider.email,
            createdAt: DateTime.now(),
          );

          // Mock email sign-in to set up the initial state
          when(
            () => mockEmailSignIn(email, 'password'),
          ).thenAnswer((_) async => Right(unverifiedUser));

          // Trigger email sign-in first to get to verification required state
          testBloc.add(EmailSignInEvent(email: email, password: 'password'));
          await Future.delayed(const Duration(milliseconds: 50));

          // Verify we're in the correct state before verification
          expect(testBloc.state, isA<AuthEmailVerificationRequired>());

          // Now test that verified email leads to signup flow navigation
          testBloc.add(VerifyEmailEvent(email: email));
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify email verification was called
          verify(() => mockVerifyEmail(email)).called(1);

          // Check that the bloc emitted the correct state
          expect(testBloc.state, isA<AuthEmailVerified>());
          final state = testBloc.state as AuthEmailVerified;
          expect(state.user.email, equals(email));
          expect(state.user.isEmailVerified, true);

          await testBloc.close();
        }
      },
    );

    test(
      'email verification failure should not proceed to signup flow',
      () async {
        const email = 'failed@example.com';

        // Mock email verification to fail
        when(
          () => mockVerifyEmail(email),
        ).thenAnswer((_) async => const Right(false));

        // Set up the bloc in email verification required state first
        final unverifiedUser = User(
          id: 'failed_user',
          email: email,
          displayName: 'Failed User',
          isEmailVerified: false,
          provider: AuthProvider.email,
          createdAt: DateTime.now(),
        );

        when(
          () => mockEmailSignIn(email, 'password'),
        ).thenAnswer((_) async => Right(unverifiedUser));

        // First get to verification required state
        authBloc.add(EmailSignInEvent(email: email, password: 'password'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Test that verification failure does not lead to signup flow
        authBloc.add(const VerifyEmailEvent(email: email));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify email verification was attempted
        verify(() => mockVerifyEmail(email)).called(1);

        // Check that the bloc emitted an error state
        expect(authBloc.state, isA<AuthError>());
        final state = authBloc.state as AuthError;
        expect(state.message, equals('Email verification failed'));
      },
    );
  });
}
