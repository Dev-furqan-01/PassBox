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
}

enum SettingsItemType {
  toggle,
  navigation,
  info,
  action,
}
