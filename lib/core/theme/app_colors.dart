import 'package:flutter/material.dart';

/// App colors based on Obsidian Vault design system
class AppColors {
  AppColors._();

  // ==========================================
  // EYE-FRIENDLY LIGHT MODE (Soft Warm Slate System)
  // ==========================================

  // Surface & Canvas (Soft, low-glare background layer)
  static const Color lightBackground = Color(0xFFF1F3F5); // Warm gray-slate canvas
  static const Color lightSurface = Color(0xFFF8F9FA); // Off-white soft card surface
  static const Color lightSurfaceVariant = Color(0xFFE9ECEF); // Light gray container fill
  static const Color lightContainer = Color(0xFFDEE2E6); // Accent container / input fill
  static const Color lightSurfaceDim = Color(0xFFE9ECEF);
  static const Color lightSurfaceBright = Color(0xFFF8F9FA);
  static const Color lightSurfaceContainerLowest = Color(0xFFF1F3F5);
  static const Color lightSurfaceContainerLow = Color(0xFFF8F9FA);
  static const Color lightSurfaceContainer = Color(0xFFE9ECEF);
  static const Color lightSurfaceContainerHigh = Color(0xFFDEE2E6);
  static const Color lightSurfaceContainerHighest = Color(0xFFCBD5E1);
  static const Color lightOnSurface = Color(0xFF1E293B); // Charcoal Slate
  static const Color lightOnSurfaceVariant = Color(0xFF475569); // Muted Slate
  static const Color lightInverseSurface = Color(0xFF1E293B);
  static const Color lightInverseOnSurface = Color(0xFFF8F9FA);
  static const Color lightOutline = Color(0xFF94A3B8);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);
  static const Color lightSurfaceTint = Color(0xFF0284C7);

  // Accent Colors (Deepened saturation to prevent washed-out text on soft light surfaces)
  static const Color lightPrimary = Color(0xFF0284C7); // Soft Ocean Cyan / Blue
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF0EA5E9);
  static const Color lightOnPrimaryContainer = Color(0xFF001F26);
  static const Color lightInversePrimary = Color(0xFF38BDF8);
  static const Color lightPrimaryFixed = Color(0xFFBAE6FD);
  static const Color lightPrimaryFixedDim = Color(0xFF0284C7);
  static const Color lightOnPrimaryFixed = Color(0xFF001F26);
  static const Color lightOnPrimaryFixedVariant = Color(0xFF004E5C);

  static const Color lightSecondary = Color(0xFF0D9488); // Soothing Forest Emerald Green
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFF14B8A6);
  static const Color lightOnSecondaryContainer = Color(0xFF002113);
  static const Color lightSecondaryFixed = Color(0xFF5EEAD4);
  static const Color lightSecondaryFixedDim = Color(0xFF0D9488);
  static const Color lightOnSecondaryFixed = Color(0xFF002113);
  static const Color lightOnSecondaryFixedVariant = Color(0xFF005236);

  static const Color lightTertiary = Color(0xFFD97706); // Warm Amber Orange
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFF59E0B);
  static const Color lightOnTertiaryContainer = Color(0xFF2A1700);
  static const Color lightTertiaryFixed = Color(0xFFFFDDB8);
  static const Color lightTertiaryFixedDim = Color(0xFFD97706);
  static const Color lightOnTertiaryFixed = Color(0xFF2A1700);
  static const Color lightOnTertiaryFixedVariant = Color(0xFF653E00);

  // Text Colors (Softened off-blacks for low eye strain)
  static const Color lightTextPrimary = Color(0xFF1E293B); // Charcoal Slate (never pure black)
  static const Color lightTextSecondary = Color(0xFF475569); // Muted Slate body text
  static const Color lightTextMuted = Color(0xFF64748B); // Low-priority caption text
  static const Color lightOnBackground = Color(0xFF1E293B);

  // Status Colors (Softened tones)
  static const Color lightSecure = Color(0xFF16A34A); // Safe Green
  static const Color lightCaution = Color(0xFFCA8A04); // Warning Yellow
  static const Color lightBreached = Color(0xFFDC2626); // Alert Red

  // Error Colors
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFECACA);
  static const Color lightOnErrorContainer = Color(0xFF450A0A);

  // Strokes & Separators
  static const Color lightBorder = Color(0xFFCBD5E1); // Subtle divider stroke
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightStroke = Color(0xFFCBD5E1);
  static const Color lightStrokeVariant = Color(0xFF94A3B8);

  // Additional UI Colors
  static const Color lightCanvas = Color(0xFFF1F3F5);
  static const Color lightCardLayer = Color(0xFFF8F9FA);
  static const Color lightElectricCyan = Color(0xFF0284C7);
  static const Color lightElectricCyanVariant = Color(0xFF0EA5E9);

  // ==========================================
  // DARK MODE PALETTE (Existing)
  // ==========================================

  // Surface colors
  static const Color surface = Color(0xFF0D141D);
  static const Color surfaceDim = Color(0xFF0D141D);
  static const Color surfaceBright = Color(0xFF333A44);
  static const Color surfaceContainerLowest = Color(0xFF080F17);
  static const Color surfaceContainerLow = Color(0xFF151C25);
  static const Color surfaceContainer = Color(0xFF192029);
  static const Color surfaceContainerHigh = Color(0xFF232A34);
  static const Color surfaceContainerHighest = Color(0xFF2E353F);
  static const Color onSurface = Color(0xFFDCE3F0);
  static const Color onSurfaceVariant = Color(0xFFBCC9CD);
  static const Color inverseSurface = Color(0xFFDCE3F0);
  static const Color inverseOnSurface = Color(0xFF2A313B);
  static const Color outline = Color(0xFF869397);
  static const Color outlineVariant = Color(0xFF3D494C);
  static const Color surfaceTint = Color(0xFF4CD7F6);

  // Primary colors
  static const Color primary = Color(0xFF4CD7F6);
  static const Color onPrimary = Color(0xFF003640);
  static const Color primaryContainer = Color(0xFF06B6D4);
  static const Color onPrimaryContainer = Color(0xFF00424F);
  static const Color inversePrimary = Color(0xFF00687A);
  static const Color primaryFixed = Color(0xFFACEDFF);
  static const Color primaryFixedDim = Color(0xFF4CD7F6);
  static const Color onPrimaryFixed = Color(0xFF001F26);
  static const Color onPrimaryFixedVariant = Color(0xFF004E5C);

  // Secondary colors
  static const Color secondary = Color(0xFF4EDEA3);
  static const Color onSecondary = Color(0xFF003824);
  static const Color secondaryContainer = Color(0xFF00A572);
  static const Color onSecondaryContainer = Color(0xFF00311F);
  static const Color secondaryFixed = Color(0xFF6FFBBE);
  static const Color secondaryFixedDim = Color(0xFF4EDEA3);
  static const Color onSecondaryFixed = Color(0xFF002113);
  static const Color onSecondaryFixedVariant = Color(0xFF005236);

  // Tertiary colors
  static const Color tertiary = Color(0xFFFFB95F);
  static const Color onTertiary = Color(0xFF472A00);
  static const Color tertiaryContainer = Color(0xFFE79400);
  static const Color onTertiaryContainer = Color(0xFF563400);
  static const Color tertiaryFixed = Color(0xFFFFDDB8);
  static const Color tertiaryFixedDim = Color(0xFFFFB95F);
  static const Color onTertiaryFixed = Color(0xFF2A1700);
  static const Color onTertiaryFixedVariant = Color(0xFF653E00);

  // Error colors
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Background colors
  static const Color background = Color(0xFF0D141D);
  static const Color onBackground = Color(0xFFDCE3F0);
  static const Color surfaceVariant = Color(0xFF2E353F);

  // Status colors
  static const Color secure = Color(0xFF10B981); // Emerald
  static const Color caution = Color(0xFFF59E0B); // Amber
  static const Color breached = Color(0xFFEF4444); // Coral Red

  // Additional UI colors
  static const Color canvas = Color(0xFF0B0F17);
  static const Color cardLayer = Color(0xFF111827);
  static const Color stroke = Color(0xFF1F2937);
  static const Color strokeVariant = Color(0xFF374151);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color electricCyan = Color(0xFF06B6D4);
  static const Color electricCyanVariant = Color(0xFF0EA5E9);
}
