import 'package:flutter/material.dart';

class SettingsItem {
  final String id;
  final String title;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final SettingsItemType type;
  final bool isEnabled;
  final String? value;

  SettingsItem({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.iconColor,
    required this.type,
    this.isEnabled = false,
    this.value,
  });

  SettingsItem copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? iconColor,
    SettingsItemType? type,
    bool? isEnabled,
    String? value,
  }) {
    return SettingsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      value: value ?? this.value,
    );
  }
}

enum SettingsItemType {
  toggle,
  navigation,
  info,
  action,
}
