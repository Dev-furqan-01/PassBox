class Vault {
  final String vaultId;
  final String service;
  final String username;
  final String password;
  final String? icon;
  final bool isFavorite;
  final bool isSecure;
  final String category;
  final DateTime lastUpdated;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int passwordStrength; // 0-100
  final bool isPasswordReused;
  final String? passwordHash; // For reuse detection

  Vault({
    required this.vaultId,
    required this.service,
    required this.username,
    required this.password,
    this.icon,
    this.isFavorite = false,
    this.isSecure = true,
    required this.category,
    required this.lastUpdated,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.passwordStrength = 0,
    this.isPasswordReused = false,
    this.passwordHash,
  });

  factory Vault.fromMap(Map<String, dynamic> data) {
    return Vault(
      vaultId: data['vaultId'] ?? '',
      service: data['service'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      icon: data['icon'],
      isFavorite: data['isFavorite'] ?? false,
      isSecure: data['isSecure'] ?? true,
      category: data['category'] ?? 'Other',
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : DateTime.now(),
      version: data['version'] ?? 1,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
      passwordStrength: data['passwordStrength'] ?? 0,
      isPasswordReused: data['isPasswordReused'] ?? false,
      passwordHash: data['passwordHash'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vaultId': vaultId,
      'service': service,
      'username': username,
      'password': password,
      if (icon != null) 'icon': icon,
      'isFavorite': isFavorite,
      'isSecure': isSecure,
      'category': category,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'version': version,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'passwordStrength': passwordStrength,
      'isPasswordReused': isPasswordReused,
      if (passwordHash != null) 'passwordHash': passwordHash,
    };
  }

  Vault copyWith({
    String? vaultId,
    String? service,
    String? username,
    String? password,
    String? icon,
    bool? isFavorite,
    bool? isSecure,
    String? category,
    DateTime? lastUpdated,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? passwordStrength,
    bool? isPasswordReused,
    String? passwordHash,
  }) {
    return Vault(
      vaultId: vaultId ?? this.vaultId,
      service: service ?? this.service,
      username: username ?? this.username,
      password: password ?? this.password,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      isSecure: isSecure ?? this.isSecure,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      isPasswordReused: isPasswordReused ?? this.isPasswordReused,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
