import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/security_metrics.dart';

/// Horizontal metrics strip for web/desktop
/// 1x4 compact cards displaying Weak, Reused, Breaches, and 2FA metrics
class WebMetricsStrip extends StatelessWidget {
  final SecurityMetrics metrics;

  const WebMetricsStrip({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.lock_reset,
            iconColor: theme.colorScheme.tertiary,
            badge: 'Update',
            badgeColor: theme.colorScheme.tertiary,
            value: metrics.weakPasswords.toString(),
            label: 'Weak',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.content_copy,
            iconColor: theme.colorScheme.tertiary,
            badge: 'Reused',
            badgeColor: theme.colorScheme.tertiary,
            value: metrics.reusedPasswords.toString(),
            label: 'Reused',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.security,
            iconColor: theme.colorScheme.secondary,
            badge: 'Clean',
            badgeColor: theme.colorScheme.secondary,
            value: metrics.breachesDetected.toString(),
            label: 'Breaches',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.phonelink_lock,
            iconColor: theme.colorScheme.primary,
            badge: '5 Avail',
            badgeColor: theme.colorScheme.primary,
            value: metrics.missing2FA.toString(),
            label: '2FA',
          ),
        ),
      ],
    );
  }
}

class _CompactMetricCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String badge;
  final Color badgeColor;
  final String value;
  final String label;

  const _CompactMetricCard({
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.badgeColor,
    required this.value,
    required this.label,
  });

  @override
  State<_CompactMetricCard> createState() => _CompactMetricCardState();
}

class _CompactMetricCardState extends State<_CompactMetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minHeight: 72,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: AppBorderRadius.lgRadius,
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 16,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: widget.badgeColor.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.fullRadius,
                  ),
                  child: Text(
                    widget.badge,
                    style: AppTextStyles.labelBadge.copyWith(
                      color: widget.badgeColor,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.value,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: widget.badgeColor == theme.colorScheme.secondary
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.label,
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
    );
  }
}
