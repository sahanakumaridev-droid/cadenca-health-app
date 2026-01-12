import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/signup_data.dart';
import '../repositories/signup_repository.dart';

class SubmitSignupDataUseCase {
  final SignupRepository repository;

  SubmitSignupDataUseCase(this.repository);

  Future<Either<Failure, void>> call(SignupData signupData) async {
    return await repository.submitSignupData(signupData);
  }
}
