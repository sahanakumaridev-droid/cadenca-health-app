import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<String?> getUserTimezone();
  Future<void> setUserTimezone(String timezone);
  Future<String?> getUserProfession();
  Future<void> setUserProfession(String profession);
  Future<String?> getUserGender();
  Future<void> setUserGender(String gender);
  Future<String?> getUserAgeGroup();
  Future<void> setUserAgeGroup(String ageGroup);
  Future<Map<String, String?>> getAllOnboardingData();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userTimezoneKey = 'user_timezone';
  static const String _userProfessionKey = 'user_profession';
  static const String _userGenderKey = 'user_gender';
  static const String _userAgeGroupKey = 'user_age_group';

  @override
  Future<bool> isOnboardingCompleted() async {
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await sharedPreferences.setBool(_onboardingCompletedKey, completed);
  }

  @override
  Future<String?> getUserTimezone() async {
    return sharedPreferences.getString(_userTimezoneKey);
  }

  @override
  Future<void> setUserTimezone(String timezone) async {
    await sharedPreferences.setString(_userTimezoneKey, timezone);
  }

  @override
  Future<String?> getUserProfession() async {
    return sharedPreferences.getString(_userProfessionKey);
  }

  @override
  Future<void> setUserProfession(String profession) async {
    await sharedPreferences.setString(_userProfessionKey, profession);
  }

  @override
  Future<String?> getUserGender() async {
    return sharedPreferences.getString(_userGenderKey);
  }

  @override
  Future<void> setUserGender(String gender) async {
    await sharedPreferences.setString(_userGenderKey, gender);
  }

  @override
  Future<String?> getUserAgeGroup() async {
    return sharedPreferences.getString(_userAgeGroupKey);
  }

  @override
  Future<void> setUserAgeGroup(String ageGroup) async {
    await sharedPreferences.setString(_userAgeGroupKey, ageGroup);
  }

  @override
  Future<Map<String, String?>> getAllOnboardingData() async {
    return {
      'timezone': await getUserTimezone(),
      'profession': await getUserProfession(),
      'gender': await getUserGender(),
      'ageGroup': await getUserAgeGroup(),
    };
  }
}
