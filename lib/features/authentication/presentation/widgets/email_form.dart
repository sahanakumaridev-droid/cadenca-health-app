import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class EmailForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String buttonText;

  const EmailForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.isLoading,
    this.buttonText = 'Sign In',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: const Color(0xFF1F2937), // Dark gray text for visibility
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF6B7280),
                fontSize: 14,
              ),
              hintText: 'your.email@example.com',
              hintStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF9CA3AF), // More visible gray border
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF9CA3AF), // More visible gray border
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6),
                  width: 2.0, // Thicker when focused
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFEF4444), // Red border for errors
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFEF4444), // Red border for errors
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: Validators.validateEmail,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: const Color(0xFF1F2937), // Dark gray text for visibility
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF6B7280),
                fontSize: 14,
              ),
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF9CA3AF), // More visible gray border
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF9CA3AF), // More visible gray border
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6),
                  width: 2.0, // Thicker when focused
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFEF4444), // Red border for errors
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFEF4444), // Red border for errors
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: Validators.validatePassword,
            enabled: !isLoading,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Color(0xFF3B82F6).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Color(0xFF2563EB), // Darker blue border
                    width: 1,
                  ),
                ),
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
