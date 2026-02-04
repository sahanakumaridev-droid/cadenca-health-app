import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/email_verification_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_flow.dart';
import '../../features/onboarding/presentation/pages/post_login_onboarding_flow.dart';
import '../../features/roster/presentation/pages/modern_roster_upload_page.dart';
import '../../features/roster/presentation/pages/flight_analysis_page.dart';
import '../../features/roster/presentation/pages/single_flight_analysis_page.dart';
import '../../features/roster/presentation/pages/enhanced_single_flight_analysis_page.dart';
import '../../features/roster/presentation/pages/flight_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/signup/presentation/pages/personal_info_page.dart';
import '../../features/signup/presentation/pages/preferences_page.dart';
import '../../features/signup/presentation/pages/demographics_page.dart';
import '../../features/signup/presentation/pages/interests_page.dart';
import '../../features/signup/presentation/pages/account_settings_page.dart';
import '../../features/signup/presentation/pages/review_page.dart';
import '../widgets/main_navigation.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String emailVerification = '/email-verification';
  static const String postLoginTimezone = '/post-login-timezone';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String rosterUpload = '/roster-upload';
  static const String flightList = '/flight-list';
  static const String flightAnalysis = '/flight-analysis';
  static const String singleFlightAnalysis = '/single-flight-analysis';
  static const String enhancedFlightAnalysis = '/enhanced-flight-analysis';
  static const String profile = '/profile';
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
        path: postLoginTimezone,
        name: 'post-login-timezone',
        builder: (context, state) => const PostLoginOnboardingFlow(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: rosterUpload,
        name: 'roster-upload',
        builder: (context, state) => const ModernRosterUploadPage(),
      ),
      GoRoute(
        path: flightList,
        name: 'flight-list',
        builder: (context, state) => const FlightListPage(),
      ),
      GoRoute(
        path: flightAnalysis,
        name: 'flight-analysis',
        builder: (context, state) {
          final flightNumber = state.uri.queryParameters['flightNumber'];
          final departureTime = state.uri.queryParameters['departureTime'];

          return FlightAnalysisPage(
            flightNumber: flightNumber,
            departureTime: departureTime,
          );
        },
      ),
      GoRoute(
        path: singleFlightAnalysis,
        name: 'single-flight-analysis',
        builder: (context, state) {
          final flightNumber = state.uri.queryParameters['flightNumber'];
          final departureTime = state.uri.queryParameters['departureTime'];

          return SingleFlightAnalysisPage(
            flightNumber: flightNumber,
            departureTime: departureTime,
          );
        },
      ),
      GoRoute(
        path: enhancedFlightAnalysis,
        name: 'enhanced-flight-analysis',
        builder: (context, state) {
          final flightNumber = state.uri.queryParameters['flightNumber'];
          final departureTime = state.uri.queryParameters['departureTime'];

          return EnhancedSingleFlightAnalysisPage(
            flightNumber: flightNumber,
            departureTime: departureTime,
          );
        },
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
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
