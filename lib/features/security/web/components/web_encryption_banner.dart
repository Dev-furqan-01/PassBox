import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Encryption info banner for web/desktop
/// Single-line horizontal status bar with encryption standards
class WebEncryptionBanner extends StatelessWidget {
  const WebEncryptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppBorderRadius.lgRadius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AES-256-GCM + XChaCha20',
                  style: AppTextStyles.labelCodeMd.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Zero-knowledge local derivation active',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
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
