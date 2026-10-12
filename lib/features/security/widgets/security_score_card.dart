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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
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
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2),
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
                              color: AppColors.secondaryContainer.withOpacity(0.2),
                              borderRadius: AppBorderRadius.fullRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SHIELD GRADE ${metrics.securityGrade}',
                                  style: AppTextStyles.labelBadge.copyWith(
                                    color: AppColors.secondary,
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
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                metrics.securityStatus,
                                style: AppTextStyles.labelCodeMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last automated dark web audit: Today, 14:20',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceMd),
                    _buildScoreCircle(),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.radar,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${metrics.analyzedNodes} Vault Nodes Analyzed',
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: AppColors.onSurfaceVariant,
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

  Widget _buildScoreCircle() {
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
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.verified_user,
              color: AppColors.primary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'RUN AUDIT',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
