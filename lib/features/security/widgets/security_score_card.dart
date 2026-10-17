import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/security_metrics.dart';

class SecurityScoreCard extends StatelessWidget {
  final SecurityMetrics metrics;
  final VoidCallback onRunAudit;

  const SecurityScoreCard({
    super.key,
    required this.metrics,
    required this.onRunAudit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Stack(
        children: [
          // Ambient watermark effects
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 128,
                    spreadRadius: 64,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    blurRadius: 128,
                    spreadRadius: 64,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                              borderRadius: AppBorderRadius.fullRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SHIELD GRADE ${metrics.securityGrade}',
                                  style: AppTextStyles.labelBadge.copyWith(
                                    color: theme.colorScheme.secondary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${metrics.securityScore}%',
                                style: AppTextStyles.headlineXl.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                metrics.securityStatus,
                                style: AppTextStyles.labelCodeMd.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last automated dark web audit: Today, 14:20',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceMd),
                    _buildScoreCircle(context),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.radar,
                          color: theme.colorScheme.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${metrics.analyzedNodes} Vault Nodes Analyzed',
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    _AuditButton(onTap: onRunAudit),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Transform.rotate(
            angle: -1.5708, // -90 degrees in radians
            child: CircularProgressIndicator(
              value: metrics.securityScore / 100,
              strokeWidth: 5.5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.verified_user,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AuditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: theme.colorScheme.primary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'RUN AUDIT',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
