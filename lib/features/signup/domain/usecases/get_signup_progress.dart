import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/signup_data.dart';
import '../repositories/signup_repository.dart';

class GetSignupProgressUseCase {
  final SignupRepository repository;

  GetSignupProgressUseCase(this.repository);

  Future<Either<Failure, SignupData>> call() async {
    return await repository.getSignupProgress();
  }
}
