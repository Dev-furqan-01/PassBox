class Device {
  final String deviceId;
  final String name;
  final String platform;
  final String? osVersion;
  final String? appVersion;
  final bool isTrusted;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Device({
    required this.deviceId,
    required this.name,
    required this.platform,
    this.osVersion,
    this.appVersion,
    this.isTrusted = false,
    required this.lastSeen,
    required this.createdAt,
    this.updatedAt,
  });

  factory Device.fromMap(Map<String, dynamic> data) {
    return Device(
      deviceId: data['deviceId'] ?? '',
      name: data['name'] ?? '',
      platform: data['platform'] ?? '',
      osVersion: data['osVersion'],
      appVersion: data['appVersion'],
      isTrusted: data['isTrusted'] ?? false,
      lastSeen: data['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastSeen'])
          : DateTime.now(),
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
      'deviceId': deviceId,
      'name': name,
      'platform': platform,
      if (osVersion != null) 'osVersion': osVersion,
      if (appVersion != null) 'appVersion': appVersion,
      'isTrusted': isTrusted,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
    };
  }

  Device copyWith({
    String? deviceId,
    String? name,
    String? platform,
    String? osVersion,
    String? appVersion,
    bool? isTrusted,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      isTrusted: isTrusted ?? this.isTrusted,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
