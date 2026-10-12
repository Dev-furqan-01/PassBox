import 'dart:math';

/// Configuration model for password generation
class PasswordConfig {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final bool excludeAmbiguous;
  final bool pronounceable;

  const PasswordConfig({
    this.length = 20,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
    this.excludeAmbiguous = true,
    this.pronounceable = false,
  });

  PasswordConfig copyWith({
    int? length,
    bool? includeUppercase,
    bool? includeLowercase,
    bool? includeNumbers,
    bool? includeSymbols,
    bool? excludeAmbiguous,
    bool? pronounceable,
  }) {
    return PasswordConfig(
      length: length ?? this.length,
      includeUppercase: includeUppercase ?? this.includeUppercase,
      includeLowercase: includeLowercase ?? this.includeLowercase,
      includeNumbers: includeNumbers ?? this.includeNumbers,
      includeSymbols: includeSymbols ?? this.includeSymbols,
      excludeAmbiguous: excludeAmbiguous ?? this.excludeAmbiguous,
      pronounceable: pronounceable ?? this.pronounceable,
    );
  }

  /// Calculate entropy in bits
  int get entropy {
    int charsetSize = 0;
    if (includeUppercase) charsetSize += 26;
    if (includeLowercase) charsetSize += 26;
    if (includeNumbers) charsetSize += 10;
    if (includeSymbols) charsetSize += 32;
    if (excludeAmbiguous) charsetSize -= 8; // Remove ambiguous chars

    if (charsetSize <= 0) return 0;
    // Simple entropy approximation: length * log2(charsetSize)
    // Using bit length as approximation
    int bits = 0;
    int temp = charsetSize;
    while (temp > 0) {
      bits++;
      temp >>= 1;
    }
    return length * bits;
  }

  /// Get strength level (1-5)
  int get strengthLevel {
    if (entropy < 40) return 1;
    if (entropy < 60) return 2;
    if (entropy < 80) return 3;
    if (entropy < 100) return 4;
    return 5;
  }

  /// Get strength label
  String get strengthLabel {
    switch (strengthLevel) {
      case 1:
        return 'Weak (1/5)';
      case 2:
        return 'Fair (2/5)';
      case 3:
        return 'Good (3/5)';
      case 4:
        return 'Strong (4/5)';
      case 5:
        return 'Excellent (5/5)';
      default:
        return 'Unknown';
    }
  }
}

/// Model for password history entry
class PasswordHistoryEntry {
  final String password;
  final DateTime generatedAt;
  final int entropy;

  PasswordHistoryEntry({
    required this.password,
    required this.generatedAt,
    required this.entropy,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
