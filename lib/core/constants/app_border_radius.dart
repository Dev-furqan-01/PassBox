import 'package:flutter/material.dart';

/// App border radius constants based on Obsidian Vault design system
class AppBorderRadius {
  AppBorderRadius._();

  static const double sm = 4.0; // 0.25rem
  static const double defaultRadius = 8.0; // 0.5rem
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem
  static const double xl = 24.0; // 1.5rem
  static const double full = 9999.0; // Full pill

  // Pre-defined BorderRadius objects
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius defaultRadiusBorder = BorderRadius.all(Radius.circular(defaultRadius));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));

  // Specific component radii
  static const double buttonRadius = 12.0; // rounded-xl
  static const double inputRadius = 8.0; // rounded-lg
  static const double cardRadius = 16.0; // rounded-2xl
  static const double badgeRadius = 9999.0; // rounded-full
}
