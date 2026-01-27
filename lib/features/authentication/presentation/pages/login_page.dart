import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/email_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Apple Sign-In availability
  bool _isAppleSignInAvailable = false;

  // Email form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAppleSignInAvailability() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = isAvailable;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAppleSignInAvailable = false;
        });
      }
    }
  }

  void _handleEmailSignIn() {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background with stronger beige gradient
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
          // Geometric shapesal interest
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
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Welcome back, ${state.user.displayName ?? 'User'}!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  context.go(AppRouter.postLoginTimezone);
                } else if (state is AuthEmailVerificationRequired) {
                  context.go(
                    '${AppRouter.emailVerification}?email=${state.user.email}',
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.08),

                    // Logo only (removed Cadenca text)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 15,
                            offset: const Offset(-3, -3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/cadenca_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your personal wellness companion for optimized sleep and peak performance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(
                            0xFF5A5A5A,
                          ), // Medium gray that works on beige
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    // Authentication Buttons
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return Column(
                          children: [
                            // Google Sign-In Button
                            _buildSocialButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        GoogleSignInEvent(),
                                      );
                                    },
                              icon: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4285F4), // Google Blue
                                      Color(0xFF34A853), // Google Green
                                      Color(0xFFFBBC05), // Google Yellow
                                      Color(0xFFEA4335), // Google Red
                                    ],
                                    stops: [0.0, 0.33, 0.66, 1.0],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              text: 'Continue with Google',
                            ),

                            const SizedBox(height: 16),

                            // Apple Sn Button (only show if available)
                            if (_isAppleSignInAvailable) ...[
                              _buildSocialButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                          AppleSignInEvent(),
                                        );
                                      },
                                icon: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.apple,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                text: 'Continue with Apple',
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Facebook Sign-In Button
                            _buildSocialButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        FacebookSignInEvent(),
                                      );
                                    },
                              icon: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1877F2),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xFF1877F2,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.facebook,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              text: 'Continue with Meta',
                            ),

                            const SizedBox(height: 32),

                            // "or" divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFF93C5FD),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Color(0xFF93C5FD),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Email Sign-In Button
                            _buildEmailButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _showEmailSignInModal(context, isLoading);
                                    },
                            ),

                            if (isLoading) ...[
                              const SizedBox(height: 32),
                              Column(
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF8B7355),
                                    ),
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Signing you in...',
                                    style: TextStyle(
                                      color: Color(0xFF5A5A5A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    // Terms and Privacy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A7A8A),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          foregroundColor: Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color(0xFFE5E7EB), // Light gray border
              width: 1.5,
            ),
          ),
          elevation: 4,
          shadowColor: Color(0xFF8B7355).withValues(alpha: 0.15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailButton({required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF2C2C2C),
          side: BorderSide(color: Color(0xFF8B7355), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8B7355).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailSignInModal(BuildContext context, bool isLoading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF0E6D2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Sign in with Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to continue',
                style: TextStyle(fontSize: 16, color: Color(0xFF5A5A5A)),
              ),
              const SizedBox(height: 24),

              // Email Form
              EmailForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onSubmit: _handleEmailSignIn,
                isLoading: isLoading,
                buttonText: 'Sign In',
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
