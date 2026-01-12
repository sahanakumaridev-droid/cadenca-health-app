import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/signup_data.dart';

abstract class SignupRepository {
  Future<Either<Failure, void>> saveSignupStep(
    String stepId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, SignupData>> getSignupProgress();
  Future<Either<Failure, void>> submitSignupData(SignupData data);
  Future<Either<Failure, void>> clearSignupData();
  Future<Either<Failure, void>> updateCurrentStep(int step);
  Future<Either<Failure, void>> savePersonalInfo(PersonalInfo personalInfo);
  Future<Either<Failure, void>> savePreferences(Preferences preferences);
  Future<Either<Failure, void>> saveDemographics(Demographics demographics);
  Future<Either<Failure, void>> saveInterests(Interests interests);
  Future<Either<Failure, void>> saveAccountSettings(
    AccountSettings accountSettings,
  );
}
