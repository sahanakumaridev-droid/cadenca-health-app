import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class EmailSignInUseCase {
  final AuthRepository repository;

  EmailSignInUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.signInWithEmail(email, password);
  }
}
