import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/onboarding_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Start animation
    _animationController.forward();

    // Navigate after 15 seconds
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Reduced from 15 to 3 seconds

    if (mounted) {
      // Check if onboarding is completed
      final isOnboardingCompleted =
          await OnboardingService.isOnboardingCompleted();

      if (isOnboardingCompleted) {
        // Go directly to login if onboarding is completed
        context.go('/login');
      } else {
        // Go to onboarding if not completed
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0E6D2), // Stronger beige
                  Color(0xFFEADDC4), // Deeper beige
                  Color(0xFFF0E6D2), // Back to stronger beige
                  Color(0xFFF5EBD8), // Lighter but more visible beige
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // Geometric shapes
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFF8B7355).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2C2C2C).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cadenca Logo - Smaller size
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 15,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/images/cadenca_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // App tagline with colors that work on beige background
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(
                                0xFF2C2C2C,
                              ), // Dark charcoal (matches logo text)
                              Color(0xFF4A4A4A), // Medium gray
                              Color(0xFF6B6B6B), // Light gray
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Welcome to Cadenca',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtle tagline
                        Text(
                          'Your Health Journey Starts Here',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(
                              0xFF5A5A5A,
                            ), // Medium gray that works on beige
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Enhanced loading indicator with health-focused gradient
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF3B82F6), // Medium blue
                                Color(0xFF60A5FA), // Light blue
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
