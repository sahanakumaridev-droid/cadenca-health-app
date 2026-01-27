import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<bool> verifyEmail(String email);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final GoogleSignIn _googleSignIn;

  // Flag to use mock data when Firebase is not configured
  static const bool _useMockGoogleSignIn = true; // Enable mock for testing

  AuthRemoteDataSourceImpl({required this.client, GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  Future<UserModel> signInWithGoogle() async {
    try {
      // Use mock data if Firebase is not configured
      if (_useMockGoogleSignIn) {
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
      }

      // Real Google Sign-In flow (requires Firebase)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled - throw a specific cancellation exception
        throw AuthCancelledException('Google sign-in was cancelled');
      }

      // Create user model from Google account
      final mockUser = UserModel(
        id: 'google_${googleUser.id}',
        email: googleUser.email,
        displayName: googleUser.displayName ?? 'Google User',
        photoUrl: googleUser.photoUrl,
        isEmailVerified: true,
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } on AuthCancelledException {
      // Re-throw cancellation exceptions without wrapping
      rethrow;
    } on PlatformException catch (e) {
      // Handle platform-specific errors from Google Sign-In
      if (e.code == 'sign_in_canceled' ||
          e.code == 'network_error' ||
          e.message?.contains('SIGN_IN_CANCELLED') == true ||
          e.message?.contains('12501') == true) {
        // User cancelled or pressed back
        throw AuthCancelledException('Google sign-in was cancelled');
      } else if (e.code == 'sign_in_failed' ||
          e.message?.contains('DEVELOPER_ERROR') == true ||
          e.message?.contains('10') == true) {
        throw AuthException(
          'Google Sign-In configuration error. Please check your Firebase setup.',
        );
      }
      throw AuthException('Google sign-in failed: ${e.message ?? e.code}');
    } on Exception catch (e) {
      // Check if it's a configuration error
      final errorMessage = e.toString();
      if (errorMessage.contains('DEVELOPER_ERROR') ||
          errorMessage.contains('CLIENT_ID') ||
          errorMessage.contains('GoogleService-Info.plist')) {
        throw AuthException(
          'Google Sign-In is not configured. Please add GoogleService-Info.plist to your iOS project. '
          'See GOOGLE_SIGNIN_SETUP.md for instructions.',
        );
      }
      throw AuthException('Google sign-in failed: ${e.toString()}');
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available on this platform
      if (!await SignInWithApple.isAvailable()) {
        throw AuthException('Apple Sign-In is not available on this device.');
      }

      // Trigger Apple Sign-In flow
      // On iOS: Native Apple Sign-In
      // On Android/Web: Web-based Apple ID login
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Required for Android/Web - provide redirect URI
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.cadenca.app.signin',
          redirectUri: Uri.parse(
            'https://cadenca-e5c04.firebaseapp.com/__/auth/handler',
          ),
        ),
      );

      // Create display name from Apple credential
      String displayName = 'Apple User';
      if (credential.givenName != null || credential.familyName != null) {
        displayName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
      }

      // Create user model from Apple credential
      final mockUser = UserModel(
        id: 'apple_${credential.userIdentifier}',
        email: credential.email ?? 'user@privaterelay.appleid.com',
        displayName: displayName,
        photoUrl: null,
        isEmailVerified: true,
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
      );

      return mockUser;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle specific Apple Sign-In errors
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthCancelledException('Apple sign-in was cancelled');
      } else if (e.code == AuthorizationErrorCode.unknown) {
        // Check if it's error 1001 (user cancelled)
        if (e.message.contains('1001')) {
          throw AuthCancelledException('Apple sign-in was cancelled');
        }
        // Check for invalid account error (Android without Service ID)
        if (e.message.contains('invalid_client') ||
            e.message.contains('Invalid Account')) {
          throw AuthException(
            'Apple Sign-In is not properly configured for Android. Please use Google Sign-In instead.',
          );
        }
        throw AuthException('Apple Sign-In error. Please try again.');
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        throw AuthException('Apple Sign-In is not available on this device.');
      }
      throw AuthException('Apple sign-in failed: ${e.message}');
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      if (e.code == 'not-available') {
        throw AuthException('Apple Sign-In is only available on iOS devices.');
      }
      if (e.code == 'invalid_client') {
        throw AuthException(
          'Apple Sign-In is not properly configured for Android. Please use Google Sign-In instead.',
        );
      }
      throw AuthException('Apple sign-in failed: ${e.message ?? e.code}');
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
      // Sign out from Google if signed in
      await _googleSignIn.signOut();

      // Mock sign-out implementation for other providers
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
