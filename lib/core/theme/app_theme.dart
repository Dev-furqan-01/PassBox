import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/app_border_radius.dart';
import '../constants/app_spacing.dart';
import '../styles/app_shadows.dart';

/// Main app theme configuration based on Obsidian Vault design system
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme,
      appBarTheme: _lightAppBarTheme,
      cardTheme: _lightCardTheme,
      elevatedButtonTheme: _lightElevatedButtonTheme,
      outlinedButtonTheme: _lightOutlinedButtonTheme,
      textButtonTheme: _lightTextButtonTheme,
      inputDecorationTheme: _lightInputDecorationTheme,
      floatingActionButtonTheme: _lightFloatingActionButtonTheme,
      chipTheme: _lightChipTheme,
      dividerTheme: _lightDividerTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
    );
  }

  static ColorScheme get _lightColorScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.lightTertiary,
      onTertiary: AppColors.lightOnTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
      background: AppColors.lightBackground,
      onBackground: AppColors.lightOnBackground,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      shadow: AppColors.lightSurfaceContainerHigh,
      scrim: AppColors.lightSurfaceContainerHighest,
      inverseSurface: AppColors.lightInverseSurface,
      onInverseSurface: AppColors.lightInverseOnSurface,
      inversePrimary: AppColors.lightInversePrimary,
    );
  }

  static ColorScheme get _darkColorScheme {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.surfaceContainerHigh,
      scrim: AppColors.surfaceContainerHighest,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.headlineXl,
      displayMedium: AppTextStyles.headlineLg,
      displaySmall: AppTextStyles.headlineMd,
      headlineLarge: AppTextStyles.headlineLg,
      headlineMedium: AppTextStyles.headlineMd,
      headlineSmall: AppTextStyles.headlineSm,
      titleLarge: AppTextStyles.headlineMd,
      titleMedium: AppTextStyles.headlineSm,
      titleSmall: AppTextStyles.bodyLg,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.bodyLg,
      labelMedium: AppTextStyles.bodyMd,
      labelSmall: AppTextStyles.bodySm,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineMd.copyWith(
        color: AppColors.onSurface,
      ),
      iconTheme: IconThemeData(
        color: AppColors.onSurface,
      ),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.cardLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgRadius,
        side: BorderSide(
          color: AppColors.stroke,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.electricCyan,
        foregroundColor: const Color(0xFF082F49),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        textStyle: AppTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          side: BorderSide(
            color: AppColors.strokeVariant,
            width: 1,
          ),
        ),
        textStyle: AppTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.electricCyan,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        textStyle: AppTextStyles.bodyMd.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceMd,
      ),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.stroke,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.stroke,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.electricCyan,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.breached,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.breached,
          width: 1,
        ),
      ),
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textSecondary,
      ),
      labelStyle: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.electricCyan,
      foregroundColor: const Color(0xFF082F49),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgRadius,
      ),
    );
  }

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceContainer,
      labelStyle: AppTextStyles.labelBadge,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.fullRadius,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
    );
  }

  static DividerThemeData get _dividerTheme {
    return DividerThemeData(
      color: AppColors.stroke,
      thickness: 1,
      space: AppSpacing.sectionBreak,
    );
  }

  // ==========================================
  // LIGHT THEME COMPONENTS
  // ==========================================

  static AppBarTheme get _lightAppBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headlineMd.copyWith(
        color: AppColors.lightOnSurface,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightOnSurface,
      ),
    );
  }

  static CardThemeData get _lightCardTheme {
    return CardThemeData(
      color: AppColors.lightCardLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgRadius,
        side: BorderSide(
          color: AppColors.lightBorder,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData get _lightElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightElectricCyan,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        textStyle: AppTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _lightOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          side: BorderSide(
            color: AppColors.lightStrokeVariant,
            width: 1,
          ),
        ),
        textStyle: AppTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static TextButtonThemeData get _lightTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightElectricCyan,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        textStyle: AppTextStyles.bodyMd.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme get _lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceMd,
      ),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.lightStroke,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.lightStroke,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.lightElectricCyan,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.lightBreached,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        borderSide: BorderSide(
          color: AppColors.lightBreached,
          width: 1,
        ),
      ),
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelStyle: AppTextStyles.bodySm.copyWith(
        color: AppColors.lightTextSecondary,
      ),
    );
  }

  static FloatingActionButtonThemeData get _lightFloatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightElectricCyan,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgRadius,
      ),
    );
  }

  static ChipThemeData get _lightChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.lightSurfaceContainer,
      labelStyle: AppTextStyles.labelBadge,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.fullRadius,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
    );
  }

  static DividerThemeData get _lightDividerTheme {
    return DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: AppSpacing.sectionBreak,
    );
  }
}
