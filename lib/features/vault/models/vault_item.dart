/// Model representing a vault credential item
class VaultItem {
  final String id;
  final String service;
  final String username;
  final String password;
  final String? icon; // Could be an emoji or icon name
  final bool isFavorite;
  final bool isSecure;
  final DateTime lastUpdated;
  final String category;

  VaultItem({
    required this.id,
    required this.service,
    required this.username,
    required this.password,
    this.icon,
    this.isFavorite = false,
    this.isSecure = true,
    required this.lastUpdated,
    this.category = 'Other',
  });

  VaultItem copyWith({
    String? id,
    String? service,
    String? username,
    String? password,
    String? icon,
    bool? isFavorite,
    bool? isSecure,
    DateTime? lastUpdated,
    String? category,
  }) {
    return VaultItem(
      id: id ?? this.id,
      service: service ?? this.service,
      username: username ?? this.username,
      password: password ?? this.password,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      isSecure: isSecure ?? this.isSecure,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
    );
  }
}
