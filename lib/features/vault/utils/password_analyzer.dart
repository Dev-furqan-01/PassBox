import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordAnalyzer {
  /// Calculates password strength score (0-100)
  static int calculateStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length check (up to 40 points)
    if (password.length >= 8) score += 10;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    if (password.length >= 20) score += 10;

    // Character variety (up to 40 points)
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasLower) score += 10;
    if (hasUpper) score += 10;
    if (hasNumber) score += 10;
    if (hasSpecial) score += 10;

    // Complexity bonus (up to 20 points)
    int varietyCount = [hasLower, hasUpper, hasNumber, hasSpecial].where((v) => v).length;
    if (varietyCount >= 3) score += 10;
    if (varietyCount == 4) score += 10;

    return score.clamp(0, 100);
  }

  /// Generates a SHA-256 hash of the password for reuse detection
  static String generatePasswordHash(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Gets strength label based on score
  static String getStrengthLabel(int score) {
    if (score >= 80) return 'Strong';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Very Weak';
  }

  /// Gets strength color based on score
  static String getStrengthColor(int score) {
    if (score >= 80) return '#4CAF50'; // Green
    if (score >= 60) return '#8BC34A'; // Light Green
    if (score >= 40) return '#FFC107'; // Amber
    if (score >= 20) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }
}
