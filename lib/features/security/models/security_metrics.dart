import 'package:flutter/material.dart';

class SecurityMetrics {
  final int securityScore;
  final String securityGrade;
  final String securityStatus;
  final int weakPasswords;
  final int reusedPasswords;
  final int breachesDetected;
  final int missing2FA;
  final int analyzedNodes;
  final DateTime lastAudit;

  SecurityMetrics({
    required this.securityScore,
    required this.securityGrade,
    required this.securityStatus,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.breachesDetected,
    required this.missing2FA,
    required this.analyzedNodes,
    required this.lastAudit,
  });

  SecurityMetrics copyWith({
    int? securityScore,
    String? securityGrade,
    String? securityStatus,
    int? weakPasswords,
    int? reusedPasswords,
    int? breachesDetected,
    int? missing2FA,
    int? analyzedNodes,
    DateTime? lastAudit,
  }) {
    return SecurityMetrics(
      securityScore: securityScore ?? this.securityScore,
      securityGrade: securityGrade ?? this.securityGrade,
      securityStatus: securityStatus ?? this.securityStatus,
      weakPasswords: weakPasswords ?? this.weakPasswords,
      reusedPasswords: reusedPasswords ?? this.reusedPasswords,
      breachesDetected: breachesDetected ?? this.breachesDetected,
      missing2FA: missing2FA ?? this.missing2FA,
      analyzedNodes: analyzedNodes ?? this.analyzedNodes,
      lastAudit: lastAudit ?? this.lastAudit,
    );
  }
}

class UrgentAction {
  final String id;
  final String title;
  final String description;
  final String badge;
  final String badgeType; // 'error', 'tertiary', 'primary'
  final String? keyId;
  final String actionType; // 'auto-change', 'update', 'enable-2fa'

  UrgentAction({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeType,
    this.keyId,
    required this.actionType,
  });
}

class VaultSetting {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final SettingType type;
  final bool isEnabled;
  final String? statusBadge;

  VaultSetting({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.type,
    required this.isEnabled,
    this.statusBadge,
  });
}

enum SettingType {
  toggle,
  navigation,
  status,
}
