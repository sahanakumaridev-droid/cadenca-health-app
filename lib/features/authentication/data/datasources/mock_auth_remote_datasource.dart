import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

abstract class MockAuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<bool> verifyEmail(String email);
  Future<void> signOut();
}

class MockAuthRemoteDataSourceImpl implements MockAuthRemoteDataSource {
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Create mock Google user
      final mockUser = UserModel(
        id: 'google_${_generateRandomId()}',
        email: 'user@gmail.com',
        displayName: 'Google User',
        photoUrl: 'https://example.com/google-avatar.jpg',
        isEmailVerified: true,
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Create mock Apple user
      final mockUser = UserModel(
        id: 'apple_${_generateRandomId()}',
        email: 'user@privaterelay.appleid.com',
        displayName: 'Apple User',
        photoUrl: null,
        isEmailVerified: true,
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } catch (e) {
      throw AuthException('Apple sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Mock Facebook Sign-In implementation with realistic flow
      await Future.delayed(
        const Duration(milliseconds: 1200),
      ); // Simulate network delay

      // Simulate random success/failure for more realistic testing
      final random = Random();
      if (random.nextBool() && random.nextBool()) {
        // Occasionally simulate cancellation (25% chance)
        throw AuthCancelledException('Facebook sign-in was cancelled');
      }

      // Simulate successful Facebook sign-in
      final mockUser = UserModel(
        id: 'facebook_${_generateRandomId()}',
        email: 'user@facebook.com',
        displayName: 'Facebook User',
        photoUrl: 'https://example.com/fb-avatar.jpg',
        isEmailVerified: true,
        provider: AuthProvider.facebook,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } on AuthCancelledException {
      rethrow;
    } catch (e) {
      throw AuthException('Facebook sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      // Mock Email Sign-In implementation with better validation
      await Future.delayed(
        const Duration(milliseconds: 1500),
      ); // Simulate network delay

      // Enhanced validation
      if (email.isEmpty || password.isEmpty) {
        throw AuthException('Email and password are required');
      }

      if (!email.contains('@') || !email.contains('.')) {
        throw AuthException('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw AuthException('Password must be at least 6 characters');
      }

      // Simulate some common email/password combinations for testing
      final testCredentials = {
        'test@cadenca.com': 'password123',
        'demo@cadenca.com': 'demo123',
        'user@cadenca.com': 'user123',
      };

      bool isValidCredential =
          testCredentials.containsKey(email.toLowerCase()) &&
          testCredentials[email.toLowerCase()] == password;

      // For demo purposes, also accept any email with password "cadenca123"
      if (!isValidCredential && password == 'cadenca123') {
        isValidCredential = true;
      }

      if (!isValidCredential) {
        throw AuthException(
          'Invalid email or password. Try: test@cadenca.com / password123',
        );
      }

      // Simulate successful email sign-in
      final mockUser = UserModel(
        id: 'email_${_generateRandomId()}',
        email: email,
        displayName: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        photoUrl: null,
        isEmailVerified:
            email.toLowerCase().contains('test') ||
            email.toLowerCase().contains(
              'demo',
            ), // Test accounts are pre-verified
        provider: AuthProvider.email,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Email sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyEmail(String email) async {
    try {
      // Mock email verification
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate verification process

      // Simulate successful verification (always true for demo)
      return true;
    } catch (e) {
      throw AuthException('Email verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Mock sign-out implementation
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw AuthException('Sign-out failed: ${e.toString()}');
    }
  }

  String _generateRandomId() {
    final random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }
}
