import 'package:flutter/material.dart';

/// Reusable Cadenca Logo Widget
/// Modern design with dark circular background and white "cadenca" text
class CadencaLogo extends StatelessWidget {
  final double size;
  final bool showBackground;
  final Color? backgroundColor;

  const CadencaLogo({
    super.key,
    this.size = 100,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final logo = _buildModernLogo();

    if (!showBackground) {
      return logo;
    }

    return Container(
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: logo,
    );
  }

  Widget _buildModernLogo() {
    return Container(
      width: size,
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark circular logo with "n" symbol
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D), // Dark gray/black
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'n',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
          SizedBox(width: size * 0.05),
          // "cadenca" text
          Text(
            'cadenca',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2D2D2D),
              fontFamily: 'Urbanist',
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact logo for app bars using the modern design
class CadencaLogoCompact extends StatelessWidget {
  final double height;
  final bool useWhiteText;

  const CadencaLogoCompact({
    super.key,
    this.height = 52,
    this.useWhiteText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark circular logo with "n" symbol
          Container(
            width: height * 0.6,
            height: height * 0.6,
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D), // Dark gray/black
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'n',
                style: TextStyle(
                  fontSize: height * 0.3,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
          SizedBox(width: height * 0.1),
          // "cadenca" text
          Text(
            'cadenca',
            style: TextStyle(
              fontSize: height * 0.25,
              fontWeight: FontWeight.w400,
              color: useWhiteText ? Colors.white : const Color(0xFF2D2D2D),
              fontFamily: 'Urbanist',
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
