import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/email_form.dart';

// Cloud layer model for parallax depth
class CloudLayer {
  final double size;
  final double y;
  final double opacity;
  final double speed;
  final double startX;

  CloudLayer({
    required this.size,
    required this.y,
    required this.opacity,
    required this.speed,
    required this.startX,
  });
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Background gradient animation (circadian rhythm)
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  late Animation<Alignment> _gradientAlignmentAnimation;

  // Logo breathing animation (scale + opacity)
  late AnimationController _breathingController;
  late Animation<double> _breathingScaleAnimation;
  late Animation<double> _breathingOpacityAnimation;

  // Entrance animations
  late AnimationController _entranceController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;

  // Parallax cloud system
  late AnimationController _cloudParallaxController;
  late List<CloudLayer> _cloudLayers;

  // Cloud fade-in controller (delayed start)
  late AnimationController _cloudFadeController;
  late Animation<double> _cloudFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // VISIBLE Circadian gradient animation (12 seconds, SLOW and VISIBLE)
    _gradientController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    // VISIBLE left-right movement
    _gradientAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_gradientController);

    // VISIBLE Logo breathing animation (5 seconds, FELT breathing)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // VISIBLE scale: 0.95 → 1.05 (10% range - you can SEE this)
    _breathingScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // VISIBLE opacity breathing: 0.85 → 1.0 (sleeping/waking)
    _breathingOpacityAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // SLOWER entrance animations (3500ms for calm experience)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Logo fades in first (0-1000ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Title fades and slides in (700-1800ms)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
          ),
        );

    // Buttons fade and slide in (1400-2800ms)
    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
          ),
        );

    // Parallax cloud system - single controller for all clouds
    _cloudParallaxController = AnimationController(
      duration: const Duration(seconds: 120), // Slow drift
      vsync: this,
    ); // Don't start immediately!

    // Cloud fade-in controller (super fast)
    _cloudFadeController = AnimationController(
      duration: const Duration(milliseconds: 200), // Very fast fade-in
      vsync: this,
    );

    _cloudFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cloudFadeController, curve: Curves.easeIn),
    );

    // Define cloud layers with depth (FAR → MID → NEAR)
    _cloudLayers = [
      // FAR clouds (tiny, high, faint, slow)
      CloudLayer(size: 80, y: 60, opacity: 0.08, speed: 0.15, startX: -0.2),
      CloudLayer(size: 100, y: 100, opacity: 0.1, speed: 0.2, startX: -0.4),
      CloudLayer(size: 90, y: 140, opacity: 0.09, speed: 0.18, startX: -0.3),
      // MID clouds (medium size, medium opacity, medium speed)
      CloudLayer(size: 140, y: 200, opacity: 0.12, speed: 0.4, startX: -0.25),
      CloudLayer(size: 160, y: 260, opacity: 0.14, speed: 0.5, startX: -0.35),
      // NEAR clouds (larger, more visible, faster)
      CloudLayer(size: 200, y: 340, opacity: 0.18, speed: 0.8, startX: -0.3),
    ];
  }

  void _startAnimations() {
    _entranceController.forward();

    // Start clouds IMMEDIATELY at a visible position (50% through animation)
    _cloudParallaxController.value = 0.5; // Start halfway so clouds are visible
    _cloudParallaxController.repeat();
    _cloudFadeController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _breathingController.dispose();
    _entranceController.dispose();
    _cloudParallaxController.dispose();
    _cloudFadeController.dispose();
    super.dispose();
  }

  void _showEmailSignupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmailSignupSheet(),
    );
  }

  void _showEmailSigninSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmailSigninSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Go to onboarding after successful login
            context.go(AppRouter.onboarding);
          } else if (state is AuthEmailVerificationRequired) {
            // Skip email verification, go directly to onboarding
            Navigator.of(context).pop();
            context.go(AppRouter.onboarding);
          } else if (state is AuthEmailVerified) {
            // Go to onboarding after email verified
            Navigator.of(context).pop();
            context.go(AppRouter.onboarding);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // VISIBLE Animated Circadian Background (Dark Mode Only)
            if (isDark)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _gradientAnimation,
                  _gradientAlignmentAnimation,
                ]),
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: _gradientAlignmentAnimation.value,
                        end: Alignment.bottomRight,
                        colors: [
                          // VISIBLE color contrast: Deep night → Pre-dawn → Dawn glow
                          Color.lerp(
                            const Color(
                              0xFF020617,
                            ), // Deep night (almost black)
                            const Color(0xFF1D4ED8), // Dawn glow (blue)
                            _gradientAnimation.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF0F172A), // Night sky
                            const Color(0xFF1E293B), // Pre-dawn
                            _gradientAnimation.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF1E293B), // Pre-dawn
                            const Color(0xFF0F172A), // Night sky
                            _gradientAnimation.value * 0.7,
                          )!,
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              // Light mode - clean white
              Container(color: const Color(0xFFF8FAFC)),

            // Parallax cloud layers with depth (both light and dark mode)
            _buildParallaxClouds(isDark: isDark),

            // Content with entrance animations
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 60.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // VISIBLE Animated Logo with Breathing (scale + opacity)
                        FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _breathingScaleAnimation,
                              _breathingOpacityAnimation,
                            ]),
                            builder: (context, child) {
                              return Opacity(
                                opacity: _breathingOpacityAnimation.value,
                                child: Transform.scale(
                                  scale: _breathingScaleAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 20,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Icon(
                                      Icons.airline_seat_flat,
                                      size: 36,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Animated Title
                        FadeTransition(
                          opacity: _titleFadeAnimation,
                          child: SlideTransition(
                            position: _titleSlideAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Cadenca',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -1.5,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aviation Sleep & Fatigue',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Animated Buttons
                        FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: SlideTransition(
                            position: _buttonsSlideAnimation,
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;

                                return Column(
                                  children: [
                                    AuthButton(
                                      text: 'Continue with Apple',
                                      icon: Icons.apple,
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.read<AuthBloc>().add(
                                                AppleSignInEvent(),
                                              );
                                            },
                                      backgroundColor: isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : const Color(0xFF0F172A),
                                      textColor: Colors.white,
                                      borderColor: isDark
                                          ? Colors.white.withOpacity(0.12)
                                          : null,
                                    ),
                                    const SizedBox(height: 16),

                                    AuthButton(
                                      text: 'Continue with Google',
                                      icon: Icons.g_mobiledata,
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.read<AuthBloc>().add(
                                                GoogleSignInEvent(),
                                              );
                                            },
                                      backgroundColor: isDark
                                          ? Colors.white.withOpacity(0.04)
                                          : Colors.white,
                                      textColor: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      borderColor: isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    const SizedBox(height: 40),

                                    // Minimal Divider
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            'or',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white.withOpacity(
                                                      0.3,
                                                    )
                                                  : const Color(0xFF94A3B8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),

                                    // Email Signup Button
                                    AuthButton(
                                      text: 'Sign up with Email',
                                      icon: Icons.email_outlined,
                                      onPressed: isLoading
                                          ? null
                                          : _showEmailSignupSheet,
                                      backgroundColor: isDark
                                          ? const Color(
                                              0xFF3B82F6,
                                            ).withOpacity(0.12)
                                          : const Color(0xFF3B82F6),
                                      textColor: isDark
                                          ? const Color(0xFF60A5FA)
                                          : Colors.white,
                                      borderColor: isDark
                                          ? const Color(
                                              0xFF3B82F6,
                                            ).withOpacity(0.25)
                                          : null,
                                    ),

                                    if (isLoading) ...[
                                      const SizedBox(height: 28),
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isDark
                                                    ? const Color(0xFF60A5FA)
                                                    : const Color(0xFF3B82F6),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Sign In Link
                        FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              TextButton(
                                onPressed: _showEmailSigninSheet,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF60A5FA)
                                        : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Health Badge
                        FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : const Color(0xFFBFDBFE).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.health_and_safety_outlined,
                                  size: 12,
                                  color: isDark
                                      ? const Color(0xFF60A5FA).withOpacity(0.7)
                                      : const Color(0xFF3B82F6),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Syncs with Apple Health',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                    color: isDark
                                        ? const Color(
                                            0xFF60A5FA,
                                          ).withOpacity(0.7)
                                        : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build parallax cloud layers with depth
  Widget _buildParallaxClouds({required bool isDark}) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cloudParallaxController,
        _cloudFadeAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _cloudFadeAnimation.value,
          child: Stack(
            children: _cloudLayers.map((cloud) {
              // Calculate horizontal position with parallax
              final screenWidth = MediaQuery.of(context).size.width;
              final progress = _cloudParallaxController.value;
              final dx =
                  (cloud.startX * screenWidth) +
                  (progress * screenWidth * 1.5 * cloud.speed);
              final wrappedDx = dx % (screenWidth * 1.8) - (screenWidth * 0.4);

              return Positioned(
                left: wrappedDx,
                top: cloud.y,
                child: _buildCloudWithDepth(
                  size: cloud.size,
                  opacity: cloud.opacity,
                  speed: cloud.speed,
                  isDark: isDark,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Build cloud with depth blur
  Widget _buildCloudWithDepth({
    required double size,
    required double opacity,
    required double speed,
    required bool isDark,
  }) {
    // Calculate blur based on distance (slower = farther = more blur)
    final blurAmount = (1 - speed) * 8.0;

    // Cloud colors based on theme
    final cloudColor = isDark
        ? Colors.white
        : const Color(0xFFE0E7FF); // Light blue-ish clouds for light mode
    final borderColor = isDark
        ? Colors.white.withOpacity(0.6)
        : const Color(0xFFBFDBFE).withOpacity(0.8);

    return Opacity(
      opacity: opacity,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: CustomPaint(
          size: Size(size, size * 0.6),
          painter: CloudPainter(
            cloudColor: cloudColor,
            borderColor: borderColor,
          ),
        ),
      ),
    );
  }
}

// Custom painter for cloud shape
class CloudPainter extends CustomPainter {
  final Color cloudColor;
  final Color borderColor;

  CloudPainter({required this.cloudColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cloudColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    // Create cloud shape using bezier curves
    final width = size.width;
    final height = size.height;

    // Start from left
    path.moveTo(width * 0.2, height * 0.7);

    // Left bump (small)
    path.quadraticBezierTo(
      width * 0.1,
      height * 0.4,
      width * 0.25,
      height * 0.35,
    );

    // Top left bump (medium)
    path.quadraticBezierTo(
      width * 0.3,
      height * 0.1,
      width * 0.45,
      height * 0.2,
    );

    // Top middle bump (large - main cloud body)
    path.quadraticBezierTo(
      width * 0.5,
      height * 0.05,
      width * 0.65,
      height * 0.15,
    );

    // Top right bump (medium)
    path.quadraticBezierTo(
      width * 0.75,
      height * 0.1,
      width * 0.8,
      height * 0.3,
    );

    // Right bump (small)
    path.quadraticBezierTo(
      width * 0.9,
      height * 0.5,
      width * 0.8,
      height * 0.7,
    );

    // Bottom (flat-ish)
    path.lineTo(width * 0.2, height * 0.7);
    path.close();

    // Draw filled cloud
    canvas.drawPath(path, paint);

    // Draw white border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => false;
}

// Email Signup Bottom Sheet
class EmailSignupSheet extends StatefulWidget {
  const EmailSignupSheet({super.key});

  @override
  State<EmailSignupSheet> createState() => _EmailSignupSheetState();
}

class _EmailSignupSheetState extends State<EmailSignupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        EmailSignUpEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Start tracking your sleep and fatigue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              // Form
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return EmailForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _handleSignup,
                    isLoading: isLoading,
                    buttonText: 'Create Account',
                  );
                },
              ),

              const SizedBox(height: 24),

              // Switch to Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EmailSigninSheet(),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Email Signin Bottom Sheet
class EmailSigninSheet extends StatefulWidget {
  const EmailSigninSheet({super.key});

  @override
  State<EmailSigninSheet> createState() => _EmailSigninSheetState();
}

class _EmailSigninSheetState extends State<EmailSigninSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        EmailSignInEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Continue tracking your fatigue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              // Form
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return EmailForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _handleSignin,
                    isLoading: isLoading,
                    buttonText: 'Sign In',
                  );
                },
              ),

              const SizedBox(height: 24),

              // Switch to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EmailSignupSheet(),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
