import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/app_settings.dart';

class SettingsItemWidget extends StatelessWidget {
  final SettingsItem item;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  const SettingsItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.description != null)
                          Text(
                            item.description!,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    switch (item.type) {
      case SettingsItemType.toggle:
        return Switch(
          value: item.isEnabled,
          onChanged: onToggle,
          activeThumbColor: AppColors.secondaryContainer,
          activeTrackColor: AppColors.secondaryContainer,
          inactiveThumbColor: AppColors.onSurface,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        );
      case SettingsItemType.navigation:
        return const Icon(
          Icons.chevron_right,
          color: AppColors.onSurfaceVariant,
          size: 18,
        );
      case SettingsItemType.info:
        if (item.value != null) {
          return Text(
            item.value!,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          );
        }
        return const SizedBox.shrink();
      case SettingsItemType.action:
        return const SizedBox.shrink();
    }
  }
}
