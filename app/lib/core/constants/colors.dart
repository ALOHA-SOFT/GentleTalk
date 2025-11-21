import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00ADB5);
  static const Color primaryDark = Color(0xFF00576A);
  static const Color darkBackground = Color(0xFF282B35);

  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF888888);

  // UI colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFEEEEEE);
  static const Color indicatorActive = Color(0xFF282B35);
  static const Color indicatorInactive = Color(0xFFC7C7C7);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00ADB5), Color(0xFF00576A)],
  );
}
