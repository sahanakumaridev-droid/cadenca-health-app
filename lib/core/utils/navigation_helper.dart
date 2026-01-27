import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class NavigationHelper {
  /// Safely navigates back to the previous screen or home if no previous screen exists
  static void safeGoBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.home);
    }
  }

  /// Creates a back button that safely navigates back
  static Widget buildBackButton(BuildContext context, {Color? color}) {
    return GestureDetector(
      onTap: () => safeGoBack(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: color ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
