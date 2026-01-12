import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import 'onboarding_basics_page.dart';
import 'onboarding_profession_page.dart';
import 'onboarding_demographics_page.dart';
import 'onboarding_preference_page.dart';
import 'onboarding_timezone_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - go to home
      context.go(AppRouter.home);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              OnboardingBasicsPage(onContinue: _nextPage),
              OnboardingProfessionPage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),
              OnboardingDemographicsPage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),
              OnboardingPreferencePage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),
              OnboardingTimezonePage(
                onContinue: _nextPage,
                onBack: _previousPage,
              ),
            ],
          ),

          // Page indicator at top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 5,
                effect: const WormEffect(
                  dotWidth: 40,
                  dotHeight: 4,
                  activeDotColor: Color(0xFF14B8A6),
                  dotColor: Color(0xFF334155),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
