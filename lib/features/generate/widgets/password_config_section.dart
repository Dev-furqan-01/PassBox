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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: AppShadows.cardElevation,
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLengthControl(),
          const SizedBox(height: AppSpacing.spaceMd),
          _buildRuleToggles(),
        ],
      ),
    );
  }

  Widget _buildLengthControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sequence Length',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
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
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Row(
                children: [
                  Text(
                    config.length.toString(),
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    ' Chars',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.onSurfaceVariant,
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
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceContainerLowest,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
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
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '32 RECOMMENDED',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '64 MAX',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLEXITY PARAMETERS',
          style: AppTextStyles.labelBadge.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        _RuleToggle(
          icon: 'AZ',
          label: 'Uppercase Letters',
          description: 'A-Z character set',
          iconColor: AppColors.secondary,
          isEnabled: config.includeUppercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeUppercase: value));
          },
        ),
        _RuleToggle(
          icon: 'az',
          label: 'Lowercase Letters',
          description: 'a-z character set',
          iconColor: AppColors.primary,
          isEnabled: config.includeLowercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeLowercase: value));
          },
        ),
        _RuleToggle(
          icon: '09',
          label: 'Numbers',
          description: '0-9 numerical digits',
          iconColor: AppColors.tertiary,
          isEnabled: config.includeNumbers,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeNumbers: value));
          },
        ),
        _RuleToggle(
          icon: '!#',
          label: 'Special Symbols',
          description: '!@#\$%^&*()_+-=',
          iconColor: AppColors.error,
          isEnabled: config.includeSymbols,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeSymbols: value));
          },
        ),
        _RuleToggle(
          icon: 'l1',
          label: 'Exclude Ambiguous',
          description: 'Omit l, 1, I, O, 0 to avoid typo',
          iconColor: AppColors.outline,
          isEnabled: config.excludeAmbiguous,
          onToggle: (value) {
            onConfigChanged(config.copyWith(excludeAmbiguous: value));
          },
        ),
        _RuleToggle(
          icon: 'Aa',
          label: 'Pronounceable',
          description: 'Easy to phonetically dictate',
          iconColor: AppColors.onSurfaceVariant,
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
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? iconColor.withOpacity(0.15) : AppColors.surfaceContainerLow,
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
                    color: isEnabled ? iconColor : AppColors.surfaceContainerHighest,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: AppTextStyles.labelCodeMd.copyWith(
                        color: isEnabled ? AppColors.onPrimary : iconColor,
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
                        color: isEnabled ? iconColor : AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isEnabled ? iconColor.withOpacity(0.7) : AppColors.onSurfaceVariant,
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
              inactiveThumbColor: AppColors.onSurface,
              inactiveTrackColor: AppColors.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}
