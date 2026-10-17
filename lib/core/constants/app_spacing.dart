/// App spacing constants based on Obsidian Vault design system
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4px sub-grid)
  static const double unit = 4.0;

  // Standard spacing
  static const double gutter = 12.0; // 0.75rem
  static const double margin = 16.0; // 1rem
  static const double spaceXs = 4.0; // 0.25rem
  static const double spaceSm = 8.0; // 0.5rem
  static const double spaceMd = 12.0; // 0.75rem
  static const double spaceLg = 16.0; // 1rem
  static const double spaceXl = 24.0; // 1.5rem

  // Card padding
  static const double cardPaddingSmall = 12.0;
  static const double cardPaddingMedium = 16.0;

  // Section breaks
  static const double sectionBreak = 12.0;

  // Safe zones
  static const double lateralSafeMargin = 16.0;

  // Compact spacing for web/desktop (ultra-dense layouts)
  static const double compactXs = 2.0; // 0.125rem
  static const double compactSm = 4.0; // 0.25rem
  static const double compactMd = 6.0; // 0.375rem
  static const double compactLg = 8.0; // 0.5rem
  static const double compactXl = 10.0; // 0.625rem

  // Compact card padding for web/desktop
  static const double compactCardPadding = 8.0;
  static const double compactCardPaddingMd = 10.0;

  // Max container width for web/desktop
  static const double maxContainerWidth = 1150.0;
  static const double maxContainerWidthMin = 1100.0;
  static const double maxContainerWidthMax = 1200.0;
}
