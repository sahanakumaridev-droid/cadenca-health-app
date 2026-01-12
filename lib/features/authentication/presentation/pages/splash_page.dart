import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/constants.dart';
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
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, navigate to onboarding
          context.go(AppRouter.onboarding);
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
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1D2E), // Dark navy background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cadenca Logo - Stylized 'C' with orange dot
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4), // Turquoise
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Stylized 'C' letter
                    const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    // Orange dot indicator (top right)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B), // Orange accent
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              const Text(
                'Cadenca',
                style: TextStyle(
                  fontSize: 36,
                  color: Color(0xFF4ECDC4), // Turquoise
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
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
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
