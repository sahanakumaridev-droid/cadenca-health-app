import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AppleSignInUseCase {
  final AuthRepository repository;

  AppleSignInUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.signInWithApple();
  }
}
