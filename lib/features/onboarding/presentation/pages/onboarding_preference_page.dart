import 'dart:ui';
import 'package:flutter/material.dart';

class OnboardingPreferencePage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const OnboardingPreferencePage({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<OnboardingPreferencePage> createState() =>
      _OnboardingPreferencePageState();
}

class _OnboardingPreferencePageState extends State<OnboardingPreferencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  String? _selectedStrategy;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with beige gradient
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
          // Geometric shapes for visual interest
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Your preference',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose your default time adaptation strategy. You can change this for individual trips.',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildStrategyCard(
                    id: 'home_time',
                    icon: Icons.access_time,
                    title: 'Stay on Home Time (HT)',
                    subtitle:
                        'Keep your body clock aligned with home. Best for short trips.',
                    badge: 'Recommended for <3 days',
                    badgeColor: const Color(0xFFFBBF24),
                  ),
                  const SizedBox(height: 16),
                  _buildStrategyCard(
                    id: 'local_time',
                    icon: Icons.public,
                    title: 'Adapt to Local Time (LT)',
                    subtitle:
                        'Shift your rhythm to the destination. Best for longer stays.',
                    badge: 'Recommended for 3+ days',
                    badgeColor: const Color(0xFFFBBF24),
                  ),
                  const SizedBox(height: 16),
                  _buildStrategyCard(
                    id: 'cadenca_decide',
                    icon: Icons.auto_awesome,
                    title: 'Let Cadenca Decide (CD)',
                    subtitle:
                        'We\'ll analyze your trip and optimize automatically.',
                    badge: 'AI-Powered',
                    badgeColor: const Color(0xFF14B8A6),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7355).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B7355).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF8B7355),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pro Tip\nMost airline crews find "Let Cadenca Decide" works best for complex rosters with multiple destinations.',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFF2C2C2C,
                              ).withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF2C2C2C),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selectedStrategy != null
                                ? widget.onContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B7355),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF8B7355,
                              ).withValues(alpha: 0.4),
                              disabledForegroundColor: Colors.white.withValues(
                                alpha: 0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    final isSelected = _selectedStrategy == id;

    return InkWell(
      onTap: () {
        setState(() => _selectedStrategy = id);
        // Auto-advance after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onContinue();
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B7355).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B7355)
                : const Color(0xFF8B7355).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF8B7355), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClouds() {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }

  Widget _buildCloud(double speed, double top, double opacity) {
    return const SizedBox.shrink(); // Remove clouds for beige theme
  }
}
