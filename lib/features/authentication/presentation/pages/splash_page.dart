import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Wait for the splash duration
    await Future.delayed(
      const Duration(seconds: AppConstants.splashDurationSeconds),
    );

    // Check authentication status
    if (mounted) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // Check if onboarding is completed
          final onboardingDataSource = di.sl<OnboardingLocalDataSource>();
          final isOnboardingCompleted = await onboardingDataSource
              .isOnboardingCompleted();

          if (isOnboardingCompleted) {
            // User has completed onboarding, go to home
            context.go(AppRouter.home);
          } else {
            // User needs to complete onboarding
            context.go(AppRouter.postLoginTimezone);
          }
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, navigate to login
          context.go(AppRouter.login);
        } else if (state is AuthEmailVerificationRequired) {
          // Email verification required, navigate to signup flow
          context.go(AppRouter.personalInfo);
        } else if (state is AuthError) {
          // Error occurred, navigate to login
          context.go(AppRouter.login);
        }
        // Note: AuthLoading state is handled by showing the splash screen
      },
      child: Scaffold(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cadenca Logo with health-focused design
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

                  // App Name with health-focused gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF1B4B66), // Deep teal blue
                        Color(0xFF2E7D8A), // Teal
                        Color(0xFF52A085), // Sage green
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'Cadenca',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your personal wellness companion for optimized sleep and peak performance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A6B7C), // Muted teal-gray
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading Indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8B7355),
                    ), // Warm brown
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
