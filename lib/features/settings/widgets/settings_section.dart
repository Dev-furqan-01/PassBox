import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/app_settings.dart';
import 'settings_item.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;
  final Function(String)? onItemTap;
  final Function(String, bool)? onToggle;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: AppBorderRadius.lgRadius,
            boxShadow: AppShadows.cardElevation,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  SettingsItemWidget(
                    item: item,
                    onTap: () => onItemTap?.call(item.id),
                    onToggle: (value) => onToggle?.call(item.id, value),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.surfaceContainerHigh,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
