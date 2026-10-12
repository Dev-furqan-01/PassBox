import 'package:flutter/material.dart';

/// App shadow styles based on Obsidian Vault design system
/// Uses ambient luminescence and tonal layering instead of traditional drop shadows
class AppShadows {
  AppShadows._();

  // Layer 2 (Floating Action/Modals) glow
  static const List<BoxShadow> floatingGlow = [
    BoxShadow(
      color: Color(0x1F06B6D4), // rgba(6, 182, 212, 0.12)
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  // Active state glow for sensitive fields
  static const List<BoxShadow> activeGlow = [
    BoxShadow(
      color: Color(0x4006B6D4), // rgba(6, 182, 212, 0.25)
      offset: Offset(0, 0),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Subtle card elevation
  static const List<BoxShadow> cardElevation = [
    BoxShadow(
      color: Color(0x0D000000), // Very subtle shadow
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  // Modal/sheet elevation
  static const List<BoxShadow> modalElevation = [
    BoxShadow(
      color: Color(0x15000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];
}
