import 'package:flutter/material.dart';
import '../../../core/core.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppBorderRadius.lgRadius,
                ),
                child: const Icon(
                  Icons.lock,
                  color: AppColors.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aegis Vault',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            'Secure password manager with zero-knowledge encryption. Your secrets never leave your device.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AboutButton(
                icon: Icons.privacy_tip,
                label: 'Privacy',
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              _AboutButton(
                icon: Icons.description,
                label: 'Terms',
                onTap: () {
                  // TODO: Open terms of service
                },
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              _AboutButton(
                icon: Icons.info,
                label: 'About',
                onTap: () {
                  // TODO: Open about dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AboutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
