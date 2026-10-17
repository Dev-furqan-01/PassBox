import 'package:flutter/material.dart';

/// App text styles based on Obsidian Vault design system
class AppTextStyles {
  AppTextStyles._();

  // Headline styles
  static const TextStyle headlineXl = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
    letterSpacing: -0.03,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 30 / 24,
    letterSpacing: -0.025,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 26 / 20,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    letterSpacing: -0.015,
  );

  // Body styles
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 21 / 15,
    letterSpacing: -0.01,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: -0.005,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
  );

  // Code/Label styles
  static const TextStyle labelCodeLg = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
    letterSpacing: 0.08,
  );

  static const TextStyle labelCodeXl = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 24 / 20,
    letterSpacing: 0.1,
  );

  static const TextStyle labelCodeMd = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 17 / 13,
    letterSpacing: 0.04,
  );

  static const TextStyle labelBadge = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 12 / 10,
    letterSpacing: 0.05,
  );
}
