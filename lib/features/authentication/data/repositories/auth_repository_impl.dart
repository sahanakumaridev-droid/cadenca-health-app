import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.signInWithGoogle();
        await localDataSource.cacheUser(user);
        await localDataSource.setUserLoggedIn(true);
        return Right(user);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on AuthCancelledException catch (e) {
      // User cancelled - return as a failure but with cancellation message
      return Left(AuthFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.signInWithApple();
        await localDataSource.cacheUser(user);
        await localDataSource.setUserLoggedIn(true);
        return Right(user);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on AuthCancelledException catch (e) {
      // User cancelled - return as a failure but with cancellation message
      return Left(AuthFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.signInWithFacebook();
        await localDataSource.cacheUser(user);
        await localDataSource.setUserLoggedIn(true);
        return Right(user);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.signInWithEmail(email, password);
        await localDataSource.cacheUser(user);
        await localDataSource.setUserLoggedIn(true);
        return Right(user);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String email) async {
    try {
      if (await networkInfo.isConnected) {
        final isVerified = await remoteDataSource.verifyEmail(email);

        // Update cached user if verification successful
        if (isVerified) {
          final cachedUser = await localDataSource.getCachedUser();
          if (cachedUser != null) {
            final updatedUser = cachedUser.copyWith(isEmailVerified: true);
            await localDataSource.cacheUser(updatedUser);
          }
        }

        return Right(isVerified);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
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
      if (await networkInfo.isConnected) {
        await remoteDataSource.signOut();
      }
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // In a real app, this would call a delete account API
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
