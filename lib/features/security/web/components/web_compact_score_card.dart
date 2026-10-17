import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/security_metrics.dart';

/// Compact horizontal score card for web/desktop
/// Dense layout with circular gauge, grade badge, status label, and embedded audit button
class WebCompactScoreCard extends StatelessWidget {
  final SecurityMetrics metrics;
  final VoidCallback onRunAudit;

  const WebCompactScoreCard({
    super.key,
    required this.metrics,
    required this.onRunAudit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Row(
        children: [
          // Circular Score Gauge
          _buildScoreGauge(context),
          const SizedBox(width: 12),
          // Score Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grade Badge and Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
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
                            'GRADE ${metrics.securityGrade}',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: theme.colorScheme.secondary,
                              letterSpacing: 0.1,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${metrics.securityScore}%',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      metrics.securityStatus,
                      style: AppTextStyles.labelCodeMd.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Metadata
                Row(
                  children: [
                    Icon(
                      Icons.radar,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${metrics.analyzedNodes} nodes',
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last audit: Today',
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Run Audit Button
          _AuditButton(onTap: onRunAudit),
        ],
      ),
    );
  }

  Widget _buildScoreGauge(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Transform.rotate(
            angle: -1.5708, // -90 degrees in radians
            child: CircularProgressIndicator(
              value: metrics.securityScore / 100,
              strokeWidth: 4,
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
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AuditButton({required this.onTap});

  @override
  State<_AuditButton> createState() => _AuditButtonState();
}

class _AuditButtonState extends State<_AuditButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.9)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.defaultRadiusBorder,
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: _isHovered
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'RUN AUDIT',
                style: AppTextStyles.labelBadge.copyWith(
                  color: _isHovered
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
