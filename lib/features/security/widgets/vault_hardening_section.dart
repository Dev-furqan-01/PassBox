import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/security_metrics.dart';

class VaultHardeningSection extends StatelessWidget {
  final List<VaultSetting> settings;

  const VaultHardeningSection({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vault Hardening & Privacy',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: AppBorderRadius.lgRadius,
            boxShadow: AppShadows.cardElevation,
          ),
          child: Column(
            children: settings.map((setting) {
              final isLast = settings.indexOf(setting) == settings.length - 1;
              return Column(
                children: [
                  _VaultSettingItem(setting: setting),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.surfaceContainerHigh,
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

class _VaultSettingItem extends StatelessWidget {
  final VaultSetting setting;

  const _VaultSettingItem({required this.setting});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // TODO: Handle navigation or toggle
      },
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
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                    child: Icon(
                      setting.icon,
                      color: setting.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          setting.title,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          setting.description,
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
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    switch (setting.type) {
      case SettingType.toggle:
        return Switch(
          value: setting.isEnabled,
          onChanged: (value) {
            // TODO: Handle toggle
          },
          activeColor: theme.colorScheme.secondaryContainer,
          activeTrackColor: theme.colorScheme.secondaryContainer,
          inactiveThumbColor: theme.colorScheme.onSurface,
          inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
        );
      case SettingType.navigation:
        return Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
          size: 18,
        );
      case SettingType.status:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.15),
            borderRadius: AppBorderRadius.fullRadius,
          ),
          child: Text(
            setting.statusBadge ?? 'Active',
            style: AppTextStyles.labelBadge.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        );
    }
  }
}
