import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/security_metrics.dart';

class SecurityMetricsGrid extends StatelessWidget {
  final SecurityMetrics metrics;

  const SecurityMetricsGrid({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.spaceXs,
      crossAxisSpacing: AppSpacing.spaceXs,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          icon: Icons.lock_reset,
          iconColor: AppColors.tertiary,
          badge: 'Needs Update',
          badgeColor: AppColors.tertiary,
          value: metrics.weakPasswords.toString(),
          label: 'Weak Passwords',
        ),
        _MetricCard(
          icon: Icons.content_copy,
          iconColor: AppColors.tertiary,
          badge: '2 Sites',
          badgeColor: AppColors.tertiary,
          value: metrics.reusedPasswords.toString(),
          label: 'Reused Across Sites',
        ),
        _MetricCard(
          icon: Icons.security,
          iconColor: AppColors.secondary,
          badge: 'Clean',
          badgeColor: AppColors.secondary,
          value: metrics.breachesDetected.toString(),
          label: 'Breaches Detected',
        ),
        _MetricCard(
          icon: Icons.phonelink_lock,
          iconColor: AppColors.primary,
          badge: '5 Avail',
          badgeColor: AppColors.primary,
          value: metrics.missing2FA.toString(),
          label: 'Missing 2FA',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String badge;
  final Color badgeColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.badgeColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.lgRadius,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: AppBorderRadius.fullRadius,
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineLg.copyWith(
                  color: badgeColor == AppColors.secondary
                      ? AppColors.secondary
                      : AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
