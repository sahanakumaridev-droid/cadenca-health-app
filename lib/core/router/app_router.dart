import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/email_verification_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_flow.dart';
import '../../features/signup/presentation/pages/personal_info_page.dart';
import '../../features/signup/presentation/pages/preferences_page.dart';
import '../../features/signup/presentation/pages/demographics_page.dart';
import '../../features/signup/presentation/pages/interests_page.dart';
import '../../features/signup/presentation/pages/account_settings_page.dart';
import '../../features/signup/presentation/pages/review_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String emailVerification = '/email-verification';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String personalInfo = '/signup/personal-info';
  static const String preferences = '/signup/preferences';
  static const String demographics = '/signup/demographics';
  static const String interests = '/signup/interests';
  static const String accountSettings = '/signup/account-settings';
  static const String review = '/signup/review';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: emailVerification,
        name: 'email-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: personalInfo,
        name: 'personal-info',
        builder: (context, state) => const PersonalInfoPage(),
      ),
      GoRoute(
        path: preferences,
        name: 'preferences',
        builder: (context, state) => const PreferencesPage(),
      ),
      GoRoute(
        path: demographics,
        name: 'demographics',
        builder: (context, state) => const DemographicsPage(),
      ),
      GoRoute(
        path: interests,
        name: 'interests',
        builder: (context, state) => const InterestsPage(),
      ),
      GoRoute(
        path: accountSettings,
        name: 'account-settings',
        builder: (context, state) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: review,
        name: 'review',
        builder: (context, state) => const ReviewPage(),
      ),
    ],
  );
}
