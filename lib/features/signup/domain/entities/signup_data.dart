import 'package:equatable/equatable.dart';

class PersonalInfo extends Equatable {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;

  const PersonalInfo({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phoneNumber,
    dateOfBirth,
    gender,
  ];

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}

class Preferences extends Equatable {
  final bool emailNotifications;
  final bool pushNotifications;
  final String theme; // 'light', 'dark', 'system'
  final String language;
  final List<String> interests;

  const Preferences({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.theme,
    required this.language,
    required this.interests,
  });

  @override
  List<Object> get props => [
    emailNotifications,
    pushNotifications,
    theme,
    language,
    interests,
  ];

  Preferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    String? theme,
    String? language,
    List<String>? interests,
  }) {
    return Preferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      interests: interests ?? this.interests,
    );
  }
}

class Demographics extends Equatable {
  final String? country;
  final String? city;
  final String? occupation;
  final String? education;
  final String? ageRange;

  const Demographics({
    this.country,
    this.city,
    this.occupation,
    this.education,
    this.ageRange,
  });

  @override
  List<Object?> get props => [country, city, occupation, education, ageRange];

  Demographics copyWith({
    String? country,
    String? city,
    String? occupation,
    String? education,
    String? ageRange,
  }) {
    return Demographics(
      country: country ?? this.country,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      ageRange: ageRange ?? this.ageRange,
    );
  }
}

class Interests extends Equatable {
  final List<String> categories;
  final List<String> hobbies;
  final List<String> skills;

  const Interests({
    required this.categories,
    required this.hobbies,
    required this.skills,
  });

  @override
  List<Object> get props => [categories, hobbies, skills];

  Interests copyWith({
    List<String>? categories,
    List<String>? hobbies,
    List<String>? skills,
  }) {
    return Interests(
      categories: categories ?? this.categories,
      hobbies: hobbies ?? this.hobbies,
      skills: skills ?? this.skills,
    );
  }
}

class AccountSettings extends Equatable {
  final bool isProfilePublic;
  final bool allowDataCollection;
  final bool enableTwoFactor;
  final String privacyLevel; // 'public', 'friends', 'private'

  const AccountSettings({
    required this.isProfilePublic,
    required this.allowDataCollection,
    required this.enableTwoFactor,
    required this.privacyLevel,
  });

  @override
  List<Object> get props => [
    isProfilePublic,
    allowDataCollection,
    enableTwoFactor,
    privacyLevel,
  ];

  AccountSettings copyWith({
    bool? isProfilePublic,
    bool? allowDataCollection,
    bool? enableTwoFactor,
    String? privacyLevel,
  }) {
    return AccountSettings(
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      allowDataCollection: allowDataCollection ?? this.allowDataCollection,
      enableTwoFactor: enableTwoFactor ?? this.enableTwoFactor,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }
}

class SignupData extends Equatable {
  final PersonalInfo? personalInfo;
  final Preferences? preferences;
  final Demographics? demographics;
  final Interests? interests;
  final AccountSettings? accountSettings;
  final int currentStep;
  final bool isComplete;

  const SignupData({
    this.personalInfo,
    this.preferences,
    this.demographics,
    this.interests,
    this.accountSettings,
    required this.currentStep,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [
    personalInfo,
    preferences,
    demographics,
    interests,
    accountSettings,
    currentStep,
    isComplete,
  ];

  SignupData copyWith({
    PersonalInfo? personalInfo,
    Preferences? preferences,
    Demographics? demographics,
    Interests? interests,
    AccountSettings? accountSettings,
    int? currentStep,
    bool? isComplete,
  }) {
    return SignupData(
      personalInfo: personalInfo ?? this.personalInfo,
      preferences: preferences ?? this.preferences,
      demographics: demographics ?? this.demographics,
      interests: interests ?? this.interests,
      accountSettings: accountSettings ?? this.accountSettings,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  // Helper method to check if all required data is complete
  bool get hasAllRequiredData {
    return personalInfo != null &&
        preferences != null &&
        demographics != null &&
        interests != null &&
        accountSettings != null;
  }

  // Helper method to get completion percentage
  double get completionPercentage {
    int completedSteps = 0;
    if (personalInfo != null) completedSteps++;
    if (preferences != null) completedSteps++;
    if (demographics != null) completedSteps++;
    if (interests != null) completedSteps++;
    if (accountSettings != null) completedSteps++;

    return completedSteps / 5.0;
  }
}
