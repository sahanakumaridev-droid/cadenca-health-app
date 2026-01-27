import 'package:dartz/dartz.dart';
import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  // Mock mode flag - set to true for testing without real services
  static const bool _useMockMode = true;

  AuthRepositoryImpl({
    required this.localDataSource,
    AuthRemoteDataSource? remoteDataSource,
    NetworkInfo? networkInfo,
  });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      if (_useMockMode) {
        return await _mockGoogleSignIn();
      }
      // Real implementation would go here
      return const Left(AuthFailure('Real Google Sign-In not implemented'));
    } catch (e) {
      return Left(AuthFailure('Google sign-in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      if (_useMockMode) {
        return await _mockAppleSignIn();
      }
      // Real implementation would go here
      return const Left(AuthFailure('Real Apple Sign-In not implemented'));
    } catch (e) {
      return Left(AuthFailure('Apple sign-in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    try {
      if (_useMockMode) {
        return await _mockFacebookSignIn();
      }
      // Real implementation would go here
      return const Left(AuthFailure('Real Facebook Sign-In not implemented'));
    } catch (e) {
      return Left(AuthFailure('Facebook sign-in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (_useMockMode) {
        return await _mockEmailSignIn(email, password);
      }
      // Real implementation would go here
      return const Left(AuthFailure('Real Email Sign-In not implemented'));
    } catch (e) {
      return Left(AuthFailure('Email sign-in failed: ${e.toString()}'));
    }
  }

  // Mock implementations
  Future<Either<Failure, User>> _mockGoogleSignIn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final mockUser = UserModel(
        id: 'google_${_generateRandomId()}',
        email: 'user@gmail.com',
        displayName: 'Google User',
        photoUrl: 'https://example.com/google-avatar.jpg',
        isEmailVerified: true,
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
      );

      await localDataSource.cacheUser(mockUser);
      await localDataSource.setUserLoggedIn(true);
      return Right(mockUser);
    } catch (e) {
      return Left(AuthFailure('Mock Google sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _mockAppleSignIn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final mockUser = UserModel(
        id: 'apple_${_generateRandomId()}',
        email: 'user@privaterelay.appleid.com',
        displayName: 'Apple User',
        photoUrl: null,
        isEmailVerified: true,
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
      );

      await localDataSource.cacheUser(mockUser);
      await localDataSource.setUserLoggedIn(true);
      return Right(mockUser);
    } catch (e) {
      return Left(AuthFailure('Mock Apple sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _mockFacebookSignIn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final mockUser = UserModel(
        id: 'facebook_${_generateRandomId()}',
        email: 'user@facebook.com',
        displayName: 'Facebook User',
        photoUrl: 'https://example.com/fb-avatar.jpg',
        isEmailVerified: true,
        provider: AuthProvider.facebook,
        createdAt: DateTime.now(),
      );

      await localDataSource.cacheUser(mockUser);
      await localDataSource.setUserLoggedIn(true);
      return Right(mockUser);
    } catch (e) {
      return Left(AuthFailure('Mock Facebook sign-in failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, User>> _mockEmailSignIn(
    String email,
    String password,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // Enhanced validation
      if (email.isEmpty || password.isEmpty) {
        return const Left(AuthFailure('Email and password are required'));
      }

      if (!email.contains('@') || !email.contains('.')) {
        return const Left(AuthFailure('Please enter a valid email address'));
      }

      if (password.length < 6) {
        return const Left(
          AuthFailure('Password must be at least 6 characters'),
        );
      }

      // Test credentials
      final testCredentials = {
        'test@cadenca.com': 'password123',
        'demo@cadenca.com': 'demo123',
        'user@cadenca.com': 'user123',
      };

      bool isValidCredential =
          testCredentials.containsKey(email.toLowerCase()) &&
          testCredentials[email.toLowerCase()] == password;

      if (!isValidCredential && password == 'cadenca123') {
        isValidCredential = true;
      }

      if (!isValidCredential) {
        return const Left(
          AuthFailure(
            'Invalid email or password. Try: test@cadenca.com / password123',
          ),
        );
      }

      final mockUser = UserModel(
        id: 'email_${_generateRandomId()}',
        email: email,
        displayName: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        photoUrl: null,
        isEmailVerified:
            email.toLowerCase().contains('test') ||
            email.toLowerCase().contains('demo'),
        provider: AuthProvider.email,
        createdAt: DateTime.now(),
      );

      await localDataSource.cacheUser(mockUser);
      await localDataSource.setUserLoggedIn(true);
      return Right(mockUser);
    } catch (e) {
      return Left(AuthFailure('Mock email sign-in failed: ${e.toString()}'));
    }
  }

  String _generateRandomId() {
    final random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String email) async {
    try {
      if (_useMockMode) {
        // Mock email verification - always successful
        await Future.delayed(const Duration(seconds: 2));

        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          final updatedUser = cachedUser.copyWith(isEmailVerified: true);
          await localDataSource.cacheUser(updatedUser);
        }

        return const Right(true);
      }
      return const Left(AuthFailure('Real email verification not implemented'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final isLoggedIn = await localDataSource.isUserLoggedIn();
      if (isLoggedIn) {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser);
      } else {
        return const Right(null);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
