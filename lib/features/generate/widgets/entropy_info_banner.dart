import 'package:flutter/material.dart';
import '../../../core/core.dart';

class EntropyInfoBanner extends StatelessWidget {
  const EntropyInfoBanner({super.key});

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppBorderRadius.defaultRadiusBorder,
            ),
            child: Icon(
              Icons.memory,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSPRNG Node • OS Level',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Entropy drawn via crypto.getRandomValues',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: AppBorderRadius.defaultRadiusBorder,
            ),
            child: Text(
              'ACTIVE',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.secondary,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
