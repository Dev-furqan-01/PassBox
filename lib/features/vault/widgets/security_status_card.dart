import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SecurityStatusCard extends StatelessWidget {
  final int healthScore;
  final String healthStatus;
  final int totalItems;
  final int weakPasswords;
  final int reusedPasswords;
  final String lastScanTime;

  const SecurityStatusCard({
    super.key,
    required this.healthScore,
    required this.healthStatus,
    required this.totalItems,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.lastScanTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
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
                color: theme.colorScheme.secondary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
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
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                  borderRadius: AppBorderRadius.fullRadius,
                                ),
                                child: Text(
                                  healthStatus.toUpperCase(),
                                  style: AppTextStyles.labelBadge.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last scanned $lastScanTime ago',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricChip(
                          value: totalItems.toString(),
                          label: 'TOTAL',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                            borderRadius: AppBorderRadius.defaultRadiusBorder,
                          ),
                          child: _MetricChip(
                            value: weakPasswords.toString(),
                            label: 'WEAK',
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MetricChip(
                          value: reusedPasswords.toString(),
                          label: 'REUSED',
                          color: theme.colorScheme.tertiary,
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
    final theme = Theme.of(context);
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
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ),
          Center(
            child: Text(
              score.toString(),
              style: AppTextStyles.labelCodeMd.copyWith(
                color: theme.colorScheme.secondary,
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
    final theme = Theme.of(context);
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
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
