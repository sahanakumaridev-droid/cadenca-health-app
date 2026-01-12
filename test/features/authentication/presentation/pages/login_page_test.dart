import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_auth_app/features/authentication/domain/entities/user.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:flutter_auth_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:flutter_auth_app/features/authentication/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  final tUnverifiedUser = User(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: false,
    provider: AuthProvider.email,
    createdAt: DateTime(2024, 1, 1),
  );

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Email Verification'))),
        ),
        GoRoute(
          path: '/signup/personal-info',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Personal Info'))),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) =>
          BlocProvider<AuthBloc>(create: (_) => mockAuthBloc, child: child!),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should display all authentication options', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);
      expect(find.text('Continue with Email'), findsOneWidget);
    });

    testWidgets('should show email form when email button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue with Email'));
      await tester.pump();

      // Assert
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and password fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets(
      'should trigger GoogleSignInEvent when Google button is tapped',
      (tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(AuthInitial());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Continue with Google'));
        await tester.pump();

        // Assert
        verify(() => mockAuthBloc.add(GoogleSignInEvent())).called(1);
      },
    );

    testWidgets('should trigger AppleSignInEvent when Apple button is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue with Apple'));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(AppleSignInEvent())).called(1);
    });

    testWidgets(
      'should trigger FacebookSignInEvent when Facebook button is tapped',
      (tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(AuthInitial());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Continue with Facebook'));
        await tester.pump();

        // Assert
        verify(() => mockAuthBloc.add(FacebookSignInEvent())).called(1);
      },
    );

    testWidgets(
      'should validate email field and show error for invalid email',
      (tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(AuthInitial());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
          find.byType(TextFormField).first,
          'invalid-email',
        );
        await tester.enterText(find.byType(TextFormField).last, 'password123');

        // Scroll to make the Sign In button visible
        await tester.ensureVisible(find.text('Sign In'));
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      },
    );

    testWidgets(
      'should validate password field and show error for short password',
      (tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(AuthInitial());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Continue with Email'));
        await tester.pumpAndSettle();

        // Enter valid email but short password
        await tester.enterText(
          find.byType(TextFormField).first,
          'test@example.com',
        );
        await tester.enterText(find.byType(TextFormField).last, '123');

        // Scroll to make the Sign In button visible
        await tester.ensureVisible(find.text('Sign In'));
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Password must be at least 6 characters long'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should trigger EmailSignInEvent with valid credentials', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue with Email'));
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Scroll to make the Sign In button visible
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockAuthBloc.add(
          const EmailSignInEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
      ).called(1);
    });

    testWidgets('should show loading indicator when AuthLoading state', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable buttons when AuthLoading state', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - buttons should be disabled (onPressed should be null)
      final googleButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Continue with Google'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(googleButton.onPressed, isNull);
    });

    testWidgets('should show error snackbar when AuthError state', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          const AuthError(message: 'Authentication failed'),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger the listener

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Authentication failed'), findsOneWidget);
    });

    testWidgets(
      'should navigate to email verification when AuthEmailVerificationRequired',
      (tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(AuthInitial());
        whenListen(
          mockAuthBloc,
          Stream.fromIterable([
            AuthInitial(),
            AuthEmailVerificationRequired(user: tUnverifiedUser),
          ]),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle(); // Wait for all animations and navigation

        // Assert - should navigate to email verification page
        expect(find.text('Email Verification'), findsOneWidget);
      },
    );

    testWidgets('should navigate to personal info when AuthEmailVerified', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          AuthEmailVerified(user: tUnverifiedUser),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations and navigation

      // Assert - should navigate to personal info page
      expect(find.text('Personal Info'), findsOneWidget);
    });

    testWidgets('should hide email form when email button is tapped again', (
      tester,
    ) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Show email form
      await tester.tap(find.text('Continue with Email'));
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Hide email form
      await tester.tap(find.text('Continue with Email'));
      await tester.pump();

      // Assert
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('should show terms and privacy text', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.textContaining('By continuing, you agree to our Terms of Service'),
        findsOneWidget,
      );
    });

    testWidgets('should handle form submission with Enter key', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue with Email'));
      await tester.pump();

      // Enter valid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Submit form with Enter key on password field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      verify(
        () => mockAuthBloc.add(
          const EmailSignInEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
      ).called(1);
    });

    testWidgets('should not submit form with empty fields', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Continue with Email'));
      await tester.pumpAndSettle();

      // Try to submit without entering any data
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - EmailSignInEvent should not be triggered
      verifyNever(() => mockAuthBloc.add(any()));

      // Should show validation errors
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
