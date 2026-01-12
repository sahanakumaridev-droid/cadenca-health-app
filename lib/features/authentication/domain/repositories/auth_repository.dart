import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithApple();
  Future<Either<Failure, User>> signInWithFacebook();
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, bool>> verifyEmail(String email);
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, bool>> isUserLoggedIn();
}
