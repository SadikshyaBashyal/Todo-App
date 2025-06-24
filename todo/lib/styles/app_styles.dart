import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color primaryBlue = Color.fromARGB(255, 28, 70, 238);
  static const Color secondaryBlue = Color.fromARGB(255, 51, 135, 208);
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, secondaryBlue],
  );

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: white,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: white,
  );

  // Input Decoration
  static InputDecoration getAuthInputDecoration({
    required String labelText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: white70),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: white70) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: white.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: white),
      ),
    );
  }

  // Button Styles
  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: white,
      foregroundColor: primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static ButtonStyle getSecondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryBlue,
      foregroundColor: white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Container Styles
  static BoxDecoration getTransparentContainerDecoration() {
    return BoxDecoration(
      color: white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: white.withValues(alpha: 0.3)),
    );
  }

  // Spacing
  static const double defaultPadding = 20.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 32.0;
} 