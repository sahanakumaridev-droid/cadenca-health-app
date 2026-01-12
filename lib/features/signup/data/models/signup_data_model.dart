import '../../domain/entities/signup_data.dart';

class PersonalInfoModel extends PersonalInfo {
  const PersonalInfoModel({
    required super.firstName,
    required super.lastName,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  factory PersonalInfoModel.fromEntity(PersonalInfo personalInfo) {
    return PersonalInfoModel(
      firstName: personalInfo.firstName,
      lastName: personalInfo.lastName,
      phoneNumber: personalInfo.phoneNumber,
      dateOfBirth: personalInfo.dateOfBirth,
      gender: personalInfo.gender,
    );
  }
}

class PreferencesModel extends Preferences {
  const PreferencesModel({
    required super.emailNotifications,
    required super.pushNotifications,
    required super.theme,
    required super.language,
    required super.interests,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      emailNotifications: json['emailNotifications'] as bool,
      pushNotifications: json['pushNotifications'] as bool,
      theme: json['theme'] as String,
      language: json['language'] as String,
      interests: List<String>.from(json['interests'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'theme': theme,
      'language': language,
      'interests': interests,
    };
  }

  factory PreferencesModel.fromEntity(Preferences preferences) {
    return PreferencesModel(
      emailNotifications: preferences.emailNotifications,
      pushNotifications: preferences.pushNotifications,
      theme: preferences.theme,
      language: preferences.language,
      interests: preferences.interests,
    );
  }
}

class DemographicsModel extends Demographics {
  const DemographicsModel({
    super.country,
    super.city,
    super.occupation,
    super.education,
    super.ageRange,
  });

  factory DemographicsModel.fromJson(Map<String, dynamic> json) {
    return DemographicsModel(
      country: json['country'] as String?,
      city: json['city'] as String?,
      occupation: json['occupation'] as String?,
      education: json['education'] as String?,
      ageRange: json['ageRange'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'occupation': occupation,
      'education': education,
      'ageRange': ageRange,
    };
  }

  factory DemographicsModel.fromEntity(Demographics demographics) {
    return DemographicsModel(
      country: demographics.country,
      city: demographics.city,
      occupation: demographics.occupation,
      education: demographics.education,
      ageRange: demographics.ageRange,
    );
  }
}

class InterestsModel extends Interests {
  const InterestsModel({
    required super.categories,
    required super.hobbies,
    required super.skills,
  });

  factory InterestsModel.fromJson(Map<String, dynamic> json) {
    return InterestsModel(
      categories: List<String>.from(json['categories'] as List),
      hobbies: List<String>.from(json['hobbies'] as List),
      skills: List<String>.from(json['skills'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {'categories': categories, 'hobbies': hobbies, 'skills': skills};
  }

  factory InterestsModel.fromEntity(Interests interests) {
    return InterestsModel(
      categories: interests.categories,
      hobbies: interests.hobbies,
      skills: interests.skills,
    );
  }
}

class AccountSettingsModel extends AccountSettings {
  const AccountSettingsModel({
    required super.isProfilePublic,
    required super.allowDataCollection,
    required super.enableTwoFactor,
    required super.privacyLevel,
  });

  factory AccountSettingsModel.fromJson(Map<String, dynamic> json) {
    return AccountSettingsModel(
      isProfilePublic: json['isProfilePublic'] as bool,
      allowDataCollection: json['allowDataCollection'] as bool,
      enableTwoFactor: json['enableTwoFactor'] as bool,
      privacyLevel: json['privacyLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isProfilePublic': isProfilePublic,
      'allowDataCollection': allowDataCollection,
      'enableTwoFactor': enableTwoFactor,
      'privacyLevel': privacyLevel,
    };
  }

  factory AccountSettingsModel.fromEntity(AccountSettings accountSettings) {
    return AccountSettingsModel(
      isProfilePublic: accountSettings.isProfilePublic,
      allowDataCollection: accountSettings.allowDataCollection,
      enableTwoFactor: accountSettings.enableTwoFactor,
      privacyLevel: accountSettings.privacyLevel,
    );
  }
}

class SignupDataModel extends SignupData {
  const SignupDataModel({
    super.personalInfo,
    super.preferences,
    super.demographics,
    super.interests,
    super.accountSettings,
    required super.currentStep,
    required super.isComplete,
  });

  factory SignupDataModel.fromJson(Map<String, dynamic> json) {
    return SignupDataModel(
      personalInfo: json['personalInfo'] != null
          ? PersonalInfoModel.fromJson(
              json['personalInfo'] as Map<String, dynamic>,
            )
          : null,
      preferences: json['preferences'] != null
          ? PreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>,
            )
          : null,
      demographics: json['demographics'] != null
          ? DemographicsModel.fromJson(
              json['demographics'] as Map<String, dynamic>,
            )
          : null,
      interests: json['interests'] != null
          ? InterestsModel.fromJson(json['interests'] as Map<String, dynamic>)
          : null,
      accountSettings: json['accountSettings'] != null
          ? AccountSettingsModel.fromJson(
              json['accountSettings'] as Map<String, dynamic>,
            )
          : null,
      currentStep: json['currentStep'] as int,
      isComplete: json['isComplete'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo != null
          ? PersonalInfoModel.fromEntity(personalInfo!).toJson()
          : null,
      'preferences': preferences != null
          ? PreferencesModel.fromEntity(preferences!).toJson()
          : null,
      'demographics': demographics != null
          ? DemographicsModel.fromEntity(demographics!).toJson()
          : null,
      'interests': interests != null
          ? InterestsModel.fromEntity(interests!).toJson()
          : null,
      'accountSettings': accountSettings != null
          ? AccountSettingsModel.fromEntity(accountSettings!).toJson()
          : null,
      'currentStep': currentStep,
      'isComplete': isComplete,
    };
  }

  factory SignupDataModel.fromEntity(SignupData signupData) {
    return SignupDataModel(
      personalInfo: signupData.personalInfo,
      preferences: signupData.preferences,
      demographics: signupData.demographics,
      interests: signupData.interests,
      accountSettings: signupData.accountSettings,
      currentStep: signupData.currentStep,
      isComplete: signupData.isComplete,
    );
  }

  @override
  SignupDataModel copyWith({
    PersonalInfo? personalInfo,
    Preferences? preferences,
    Demographics? demographics,
    Interests? interests,
    AccountSettings? accountSettings,
    int? currentStep,
    bool? isComplete,
  }) {
    return SignupDataModel(
      personalInfo: personalInfo ?? this.personalInfo,
      preferences: preferences ?? this.preferences,
      demographics: demographics ?? this.demographics,
      interests: interests ?? this.interests,
      accountSettings: accountSettings ?? this.accountSettings,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
