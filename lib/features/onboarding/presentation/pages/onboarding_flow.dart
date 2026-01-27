import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/onboarding_service.dart';
import 'onboarding_basics_page.dart';

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

  void _nextPage() async {
    // Mark onboarding as completed
    await OnboardingService.setOnboardingCompleted(true);

    // Only 1 page now (basics intro) - go directly to login
    if (mounted) {
      context.go(AppRouter.login);
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
            children: [OnboardingBasicsPage(onContinue: _nextPage)],
          ),

          // Page indicator at top - optimized for iPhone 12
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 1,
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
