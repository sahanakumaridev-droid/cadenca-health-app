import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/di/injection.dart' as di;
import '../../data/datasources/onboarding_local_datasource.dart';
import 'post_login_timezone_page.dart';
import 'onboarding_profession_page.dart';
import 'onboarding_demographics_page.dart';
import 'onboarding_preference_page.dart';
import 'sleep_fatigue_basics_page.dart';

class PostLoginOnboardingFlow extends StatefulWidget {
  const PostLoginOnboardingFlow({super.key});

  @override
  State<PostLoginOnboardingFlow> createState() =>
      _PostLoginOnboardingFlowState();
}

class _PostLoginOnboardingFlowState extends State<PostLoginOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < 4) {
      // 5 pages total (0-4)
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - complete onboarding and go to home
      final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
      await onboardingDataSource.setOnboardingCompleted(true);

      if (mounted) {
        context.go(AppRouter.home);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Disable swiping by using NeverScrollableScrollPhysics
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping
            children: [
              // Page 1: Post-login timezone selection
              PostLoginTimezonePage(onContinue: _nextPage),

              // Page 2: Profession selection
              OnboardingProfessionPage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),

              // Page 3: Demographics
              OnboardingDemographicsPage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),

              // Page 4: Time adaptation preferences
              OnboardingPreferencePage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),

              // Page 5: Sleep & Fatigue Basics (Final screen)
              SleepFatigueBasicsPage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),
            ],
          ),

          // Page indicator at top - optimized for iPhone 12
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 5, // 5 pages total
                effect: WormEffect(
                  dotWidth: screenWidth * 0.07, // Optimized for iPhone 12
                  dotHeight: 3.5,
                  activeDotColor: const Color(0xFF14B8A6),
                  dotColor: const Color(0xFF334155),
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
