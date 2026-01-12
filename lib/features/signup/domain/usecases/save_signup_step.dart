import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/signup_repository.dart';

class SaveSignupStepUseCase {
  final SignupRepository repository;

  SaveSignupStepUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String stepId,
    Map<String, dynamic> data,
  ) async {
    return await repository.saveSignupStep(stepId, data);
  }
}
