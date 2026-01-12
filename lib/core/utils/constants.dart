class AppConstants {
  // Splash screen duration
  static const int splashDurationSeconds = 1;

  // Shared preferences keys
  static const String cachedUser = 'CACHED_USER';
  static const String cachedSignupData = 'CACHED_SIGNUP_DATA';
  static const String isUserLoggedIn = 'IS_USER_LOGGED_IN';

  // API endpoints (for future use)
  static const String baseUrl = 'https://api.example.com';
  static const String authEndpoint = '/auth';
  static const String signupEndpoint = '/signup';

  // Error messages
  static const String serverFailureMessage = 'Server Failure';
  static const String cacheFailureMessage = 'Cache Failure';
  static const String networkFailureMessage = 'Network Failure';
  static const String authFailureMessage = 'Authentication Failure';
  static const String validationFailureMessage = 'Validation Failure';

  // Signup steps
  static const int totalSignupSteps = 6;
  static const List<String> signupStepIds = [
    'personal_info',
    'preferences',
    'demographics',
    'interests',
    'account_settings',
    'review',
  ];
}
