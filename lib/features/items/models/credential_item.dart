/// Model representing a credential item for the items screen
class CredentialItem {
  final String id;
  final String service;
  final String username;
  final String password;
  final String? icon; // Material icon name
  final bool isFavorite;
  final bool hasTotp;
  final String? totpCode;
  final int? totpSecondsRemaining;
  final PasswordStrength strength;
  final bool isReused;
  final bool isCompromised;
  final bool hasApiKey;
  final DateTime lastUsed;

  CredentialItem({
    required this.id,
    required this.service,
    required this.username,
    required this.password,
    this.icon,
    this.isFavorite = false,
    this.hasTotp = false,
    this.totpCode,
    this.totpSecondsRemaining,
    this.strength = PasswordStrength.strong,
    this.isReused = false,
    this.isCompromised = false,
    this.hasApiKey = false,
    required this.lastUsed,
  });

  CredentialItem copyWith({
    String? id,
    String? service,
    String? username,
    String? password,
    String? icon,
    bool? isFavorite,
    bool? hasTotp,
    String? totpCode,
    int? totpSecondsRemaining,
    PasswordStrength? strength,
    bool? isReused,
    bool? isCompromised,
    bool? hasApiKey,
    DateTime? lastUsed,
  }) {
    return CredentialItem(
      id: id ?? this.id,
      service: service ?? this.service,
      username: username ?? this.username,
      password: password ?? this.password,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      hasTotp: hasTotp ?? this.hasTotp,
      totpCode: totpCode ?? this.totpCode,
      totpSecondsRemaining: totpSecondsRemaining ?? this.totpSecondsRemaining,
      strength: strength ?? this.strength,
      isReused: isReused ?? this.isReused,
      isCompromised: isCompromised ?? this.isCompromised,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  String get passwordLength {
    switch (this) {
      case PasswordStrength.weak:
        return '8 char';
      case PasswordStrength.medium:
        return '12 char';
      case PasswordStrength.strong:
        return '16 char';
      case PasswordStrength.veryStrong:
        return '24 char';
    }
  }
}
