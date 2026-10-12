import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SecurityStatusCard extends StatelessWidget {
  final int healthScore;
  final String healthStatus;
  final int totalItems;
  final int weakPasswords;
  final int reusedPasswords;
  final String lastScanTime;
  final VoidCallback onScanTap;

  const SecurityStatusCard({
    super.key,
    required this.healthScore,
    required this.healthStatus,
    required this.totalItems,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.lastScanTime,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 64,
                    spreadRadius: 32,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              children: [
                Row(
                  children: [
                    _HealthScoreCircle(score: healthScore),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Vault Health',
                                style: AppTextStyles.headlineSm.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer.withOpacity(0.2),
                                  borderRadius: AppBorderRadius.fullRadius,
                                ),
                                child: Text(
                                  healthStatus.toUpperCase(),
                                  style: AppTextStyles.labelBadge.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last scanned $lastScanTime ago',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onScanTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: AppBorderRadius.defaultRadiusBorder,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SCAN',
                              style: AppTextStyles.labelBadge.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricChip(
                          value: totalItems.toString(),
                          label: 'TOTAL',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest.withOpacity(0.4),
                            borderRadius: AppBorderRadius.defaultRadiusBorder,
                          ),
                          child: _MetricChip(
                            value: weakPasswords.toString(),
                            label: 'WEAK',
                            color: AppColors.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MetricChip(
                          value: reusedPasswords.toString(),
                          label: 'REUSED',
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
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

class _HealthScoreCircle extends StatelessWidget {
  final int score;

  const _HealthScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 3,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          Center(
            child: Text(
              score.toString(),
              style: AppTextStyles.labelCodeMd.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.labelCodeMd.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelBadge.copyWith(
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}
