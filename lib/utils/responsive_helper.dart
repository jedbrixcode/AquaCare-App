import 'package:flutter/material.dart';

class ResponsiveHelper {
  /// Returns true if the device is considered mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Returns true if the device is considered tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  /// Get card width depending on device type
  static double getCardWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = horizontalPadding(context);
    final double available = size.width - (padding * 2);

    if (isMobile(context)) {
      // Use most of the available width on phones, but never exceed available
      final target = size.width * 0.9;
      return target.clamp(0.0, available);
    } else if (isTablet(context)) {
      // Reasonable fixed width for tablet cards, clamped to available
      return 350.0.clamp(0.0, available);
    }
    // Fallback: behave like mobile and clamp to available
    final target = size.width * 0.9;
    return target.clamp(0.0, available);
  }

  /// Get card height depending on device type
  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 180;
    } else if (isTablet(context)) {
      return 200;
    }
    return 180; // fallback for mobile
  }

  /// Screen padding for mobile and tablet
  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }

  /// Horizontal padding depending on device type
  static double horizontalPadding(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    // Narrowest foldables and small phones
    if (w <= 340) return 8.0;
    if (w <= 380) return 10.0;
    if (w <= 420) return 12.0;
    // Typical phones
    if (w < 600) return 16.0;
    // Tablet-ish / large phones
    if (w < 900) return 20.0;
    // Very wide
    return 24.0;
  }

  /// Vertical padding depending on device type
  static double verticalPadding(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    if (h <= 640) return 8.0;
    if (h <= 740) return 10.0;
    if (h < 900) return 12.0;
    return 16.0;
  }

  /// Font size scaling depending on device type
  static double getFontSize(BuildContext context, double baseSize) {
    // Keep base sizes on phones to avoid visual changes.
    // Slight bump on tablets for readability.
    if (isTablet(context)) return baseSize * 1.08;
    return baseSize;
  }
}
