import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/signup_data_model.dart';

abstract class SignupLocalDataSource {
  Future<SignupDataModel> getSignupProgress();
  Future<void> saveSignupData(SignupDataModel signupData);
  Future<void> clearSignupData();
  Future<void> saveSignupStep(String stepId, Map<String, dynamic> data);
}

class SignupLocalDataSourceImpl implements SignupLocalDataSource {
  final SharedPreferences sharedPreferences;

  SignupLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<SignupDataModel> getSignupProgress() async {
    try {
      final jsonString = sharedPreferences.getString(
        AppConstants.cachedSignupData,
      );
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return SignupDataModel.fromJson(jsonMap);
      } else {
        // Return empty signup data if none exists
        return const SignupDataModel(currentStep: 0, isComplete: false);
      }
    } catch (e) {
      throw CacheException('Failed to get signup progress: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSignupData(SignupDataModel signupData) async {
    try {
      final jsonString = json.encode(signupData.toJson());
      await sharedPreferences.setString(
        AppConstants.cachedSignupData,
        jsonString,
      );
    } catch (e) {
      throw CacheException('Failed to save signup data: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSignupData() async {
    try {
      await sharedPreferences.remove(AppConstants.cachedSignupData);
    } catch (e) {
      throw CacheException('Failed to clear signup data: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSignupStep(String stepId, Map<String, dynamic> data) async {
    try {
      // Get current signup data
      final currentData = await getSignupProgress();

      // Update the specific step data
      SignupDataModel updatedData;

      switch (stepId) {
        case 'personal_info':
          final personalInfo = PersonalInfoModel.fromJson(data);
          updatedData = currentData.copyWith(
            personalInfo: personalInfo,
            currentStep: 1,
          );
          break;
        case 'preferences':
          final preferences = PreferencesModel.fromJson(data);
          updatedData = currentData.copyWith(
            preferences: preferences,
            currentStep: 2,
          );
          break;
        case 'demographics':
          final demographics = DemographicsModel.fromJson(data);
          updatedData = currentData.copyWith(
            demographics: demographics,
            currentStep: 3,
          );
          break;
        case 'interests':
          final interests = InterestsModel.fromJson(data);
          updatedData = currentData.copyWith(
            interests: interests,
            currentStep: 4,
          );
          break;
        case 'account_settings':
          final accountSettings = AccountSettingsModel.fromJson(data);
          updatedData = currentData.copyWith(
            accountSettings: accountSettings,
            currentStep: 5,
            isComplete: true,
          );
          break;
        default:
          throw CacheException('Unknown step ID: $stepId');
      }

      await saveSignupData(updatedData);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to save signup step: ${e.toString()}');
    }
  }
}
