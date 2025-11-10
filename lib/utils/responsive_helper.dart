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
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.8;
    } else if (isTablet(context)) {
      return 350;
    }
    return MediaQuery.of(context).size.width * 0.8; // fallback for mobile
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
    if (isMobile(context) || isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 5);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 5); // fallback
  }

  /// Horizontal padding depending on device type
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 24.0;
    }
    return 16.0; // fallback
  }

  /// Vertical padding depending on device type
  static double verticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    }
    return 12.0; // fallback
  }

  /// Font size scaling depending on device type
  static double getFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    }
    return baseSize; // fallback
  }
}
