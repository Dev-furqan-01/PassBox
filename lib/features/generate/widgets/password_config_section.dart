import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/password_config.dart';

class PasswordConfigSection extends StatelessWidget {
  final PasswordConfig config;
  final ValueChanged<PasswordConfig> onConfigChanged;

  const PasswordConfigSection({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: AppShadows.cardElevation,
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLengthControl(context),
          const SizedBox(height: AppSpacing.spaceMd),
          _buildRuleToggles(context),
        ],
      ),
    );
  }

  Widget _buildLengthControl(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sequence Length',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Row(
                children: [
                  Text(
                    config.length.toString(),
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    ' Chars',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: config.length.toDouble(),
            min: 8,
            max: 64,
            divisions: 56,
            onChanged: (value) {
              onConfigChanged(config.copyWith(length: value.toInt()));
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '08 MIN',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '32 RECOMMENDED',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '64 MAX',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleToggles(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLEXITY PARAMETERS',
          style: AppTextStyles.labelBadge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        _RuleToggle(
          icon: 'AZ',
          label: 'Uppercase Letters',
          description: 'A-Z character set',
          iconColor: theme.colorScheme.secondary,
          isEnabled: config.includeUppercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeUppercase: value));
          },
        ),
        _RuleToggle(
          icon: 'az',
          label: 'Lowercase Letters',
          description: 'a-z character set',
          iconColor: theme.colorScheme.primary,
          isEnabled: config.includeLowercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeLowercase: value));
          },
        ),
        _RuleToggle(
          icon: '09',
          label: 'Numbers',
          description: '0-9 numerical digits',
          iconColor: theme.colorScheme.tertiary,
          isEnabled: config.includeNumbers,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeNumbers: value));
          },
        ),
        _RuleToggle(
          icon: '!#',
          label: 'Special Symbols',
          description: '!@#\$%^&*()_+-=',
          iconColor: theme.colorScheme.error,
          isEnabled: config.includeSymbols,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeSymbols: value));
          },
        ),
        _RuleToggle(
          icon: 'l1',
          label: 'Exclude Ambiguous',
          description: 'Omit l, 1, I, O, 0 to avoid typo',
          iconColor: theme.colorScheme.outline,
          isEnabled: config.excludeAmbiguous,
          onToggle: (value) {
            onConfigChanged(config.copyWith(excludeAmbiguous: value));
          },
        ),
        _RuleToggle(
          icon: 'Aa',
          label: 'Pronounceable',
          description: 'Easy to phonetically dictate',
          iconColor: theme.colorScheme.onSurfaceVariant,
          isEnabled: config.pronounceable,
          onToggle: (value) {
            onConfigChanged(config.copyWith(pronounceable: value));
          },
        ),
      ],
    );
  }
}

class _RuleToggle extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final Color iconColor;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _RuleToggle({
    required this.icon,
    required this.label,
    required this.description,
    required this.iconColor,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? iconColor.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          border: isEnabled ? Border.all(color: iconColor.withOpacity(0.3), width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isEnabled ? iconColor : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: AppTextStyles.labelCodeMd.copyWith(
                        color: isEnabled ? theme.colorScheme.onPrimary : iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isEnabled ? iconColor : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isEnabled ? iconColor.withOpacity(0.7) : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: iconColor,
              activeTrackColor: iconColor.withOpacity(0.3),
              inactiveThumbColor: theme.colorScheme.onSurface,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}
