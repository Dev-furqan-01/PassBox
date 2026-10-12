import 'package:flutter/material.dart';

/// App font configuration based on Obsidian Vault design system
class AppFonts {
  AppFonts._();

  // Font families
  static const String inter = 'Inter';
  static const String jetbrainsMono = 'JetBrains Mono';

  // Get text style with specific font family
  static TextStyle interFont(TextStyle style) {
    return style.copyWith(fontFamily: inter);
  }

  static TextStyle jetbrainsMonoFont(TextStyle style) {
    return style.copyWith(fontFamily: jetbrainsMono);
  }

  // Font family map for easy access
  static const Map<String, String> fontFamilyMap = {
    'Inter': inter,
    'JetBrains Mono': jetbrainsMono,
  };
}
