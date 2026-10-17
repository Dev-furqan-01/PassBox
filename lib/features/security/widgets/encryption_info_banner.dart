import 'package:flutter/material.dart';
import '../../../core/core.dart';

class EncryptionInfoBanner extends StatelessWidget {
  const EncryptionInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppBorderRadius.lgRadius,
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AES-256-GCM + XChaCha20',
                  style: AppTextStyles.labelCodeMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Zero-knowledge local derivation active.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
