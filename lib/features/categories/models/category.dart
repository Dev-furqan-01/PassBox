class Category {
  final String categoryId;
  final String name;
  final String? icon;
  final String? color;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Category({
    required this.categoryId,
    required this.name,
    this.icon,
    this.color,
    required this.order,
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      icon: data['icon'],
      color: data['color'],
      order: data['order'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'order': order,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
    };
  }

  Category copyWith({
    String? categoryId,
    String? name,
    String? icon,
    String? color,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
