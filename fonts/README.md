# Fonts Directory

This directory contains the custom fonts for the Obsidian Vault design system.

## Required Fonts

### Inter (Primary Interface Font)
Download from: https://fonts.google.com/specimen/Inter

Required files:
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

### JetBrains Mono (Data & Security Tokens Font)
Download from: https://fonts.google.com/specimen/JetBrains+Mono

Required files:
- JetBrainsMono-Regular.ttf
- JetBrainsMono-Medium.ttf
- JetBrainsMono-SemiBold.ttf

## Installation Instructions

1. Download the font files from the URLs above
2. Place them in this `fonts/` directory
3. Run `flutter pub get` to register the fonts
4. Restart your IDE/Flutter to apply the changes

## Usage

The fonts are configured in `pubspec.yaml` and can be used throughout the app via the theme system:

```dart
// Headline and body text uses Inter
Text('Hello World', style: AppTextStyles.headlineLg)

// Code, passwords, and security tokens use JetBrains Mono
Text('TOTP: 123456', style: AppTextStyles.labelCodeLg)
```
