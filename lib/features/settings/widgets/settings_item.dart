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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
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
                      color: theme.colorScheme.surfaceContainerHighest,
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
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.description != null)
                          Text(
                            item.description!,
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildTrailing(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    switch (item.type) {
      case SettingsItemType.toggle:
        return Transform.scale(
          scale: 1.1,
          child: Switch(
            value: item.isEnabled,
            onChanged: onToggle,
            activeColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
            inactiveThumbColor: theme.colorScheme.outline,
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      case SettingsItemType.navigation:
        return Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
          size: 18,
        );
      case SettingsItemType.info:
        if (item.value != null) {
          return Text(
            item.value!,
            style: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }
        return const SizedBox.shrink();
      case SettingsItemType.action:
        return const SizedBox.shrink();
    }
  }
}
