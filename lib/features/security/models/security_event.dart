enum SecurityEventType {
  login,
  logout,
  passwordChange,
  passwordReset,
  vaultAccess,
  vaultCreate,
  vaultUpdate,
  vaultDelete,
  suspiciousActivity,
  deviceAdded,
  deviceRemoved,
  verificationSuccess,
  verificationFailed,
}

class SecurityEvent {
  final String eventId;
  final SecurityEventType type;
  final String? description;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  SecurityEvent({
    required this.eventId,
    required this.type,
    this.description,
    this.ipAddress,
    this.userAgent,
    this.metadata,
    required this.createdAt,
  });

  factory SecurityEvent.fromMap(Map<String, dynamic> data) {
    return SecurityEvent(
      eventId: data['eventId'] ?? '',
      type: _parseEventType(data['type']),
      description: data['description'],
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'type': type.name,
      if (description != null) 'description': description,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static SecurityEventType _parseEventType(String? type) {
    if (type == null) return SecurityEventType.login;
    return SecurityEventType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => SecurityEventType.login,
    );
  }

  SecurityEvent copyWith({
    String? eventId,
    SecurityEventType? type,
    String? description,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return SecurityEvent(
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      description: description ?? this.description,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
