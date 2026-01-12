import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/signup_data.dart';
import '../../domain/repositories/signup_repository.dart';
import '../datasources/signup_local_datasource.dart';
import '../models/signup_data_model.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupLocalDataSource localDataSource;

  SignupRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> saveSignupStep(
    String stepId,
    Map<String, dynamic> data,
  ) async {
    try {
      await localDataSource.saveSignupStep(stepId, data);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SignupData>> getSignupProgress() async {
    try {
      final signupData = await localDataSource.getSignupProgress();
      return Right(signupData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitSignupData(SignupData data) async {
    try {
      // In a real app, this would submit to a remote API
      // For now, we'll just log the data and mark as complete
      print('Submitting signup data: ${data.toString()}');

      final signupDataModel = SignupDataModel.fromEntity(data);
      final completedData = signupDataModel.copyWith(isComplete: true);

      await localDataSource.saveSignupData(completedData);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to submit signup data: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearSignupData() async {
    try {
      await localDataSource.clearSignupData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCurrentStep(int step) async {
    try {
      final currentData = await localDataSource.getSignupProgress();
      final updatedData = currentData.copyWith(currentStep: step);
      await localDataSource.saveSignupData(updatedData);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> savePersonalInfo(
    PersonalInfo personalInfo,
  ) async {
    try {
      final personalInfoModel = PersonalInfoModel.fromEntity(personalInfo);
      await localDataSource.saveSignupStep(
        'personal_info',
        personalInfoModel.toJson(),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> savePreferences(Preferences preferences) async {
    try {
      final preferencesModel = PreferencesModel.fromEntity(preferences);
      await localDataSource.saveSignupStep(
        'preferences',
        preferencesModel.toJson(),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDemographics(
    Demographics demographics,
  ) async {
    try {
      final demographicsModel = DemographicsModel.fromEntity(demographics);
      await localDataSource.saveSignupStep(
        'demographics',
        demographicsModel.toJson(),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveInterests(Interests interests) async {
    try {
      final interestsModel = InterestsModel.fromEntity(interests);
      await localDataSource.saveSignupStep(
        'interests',
        interestsModel.toJson(),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAccountSettings(
    AccountSettings accountSettings,
  ) async {
    try {
      final accountSettingsModel = AccountSettingsModel.fromEntity(
        accountSettings,
      );
      await localDataSource.saveSignupStep(
        'account_settings',
        accountSettingsModel.toJson(),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
