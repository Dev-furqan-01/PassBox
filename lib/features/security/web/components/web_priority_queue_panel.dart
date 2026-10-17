import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/security_metrics.dart';

/// Priority Queue Panel for web/desktop
/// Scrollable list of urgent action cards with inline update buttons
class WebPriorityQueuePanel extends StatelessWidget {
  final List<UrgentAction> urgentActions;
  final Function(UrgentAction) onActionTap;

  const WebPriorityQueuePanel({
    super.key,
    required this.urgentActions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Urgent Actions',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: AppBorderRadius.fullRadius,
                  ),
                  child: Text(
                    urgentActions.length.toString(),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppBorderRadius.smRadius,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PRIORITY QUEUE',
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Scrollable Action List
        Expanded(
          child: urgentActions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.secondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Urgent Actions',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your vault is secure',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: urgentActions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _WebUrgentActionCard(
                      action: urgentActions[index],
                      onActionTap: onActionTap,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WebUrgentActionCard extends StatefulWidget {
  final UrgentAction action;
  final Function(UrgentAction) onActionTap;

  const _WebUrgentActionCard({
    required this.action,
    required this.onActionTap,
  });

  @override
  State<_WebUrgentActionCard> createState() => _WebUrgentActionCardState();
}

class _WebUrgentActionCardState extends State<_WebUrgentActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color iconColor;
    Color badgeColor;

    switch (widget.action.badgeType) {
      case 'error':
        iconColor = theme.colorScheme.error;
        badgeColor = theme.colorScheme.error;
        break;
      case 'tertiary':
        iconColor = theme.colorScheme.tertiary;
        badgeColor = theme.colorScheme.tertiary;
        break;
      case 'primary':
        iconColor = theme.colorScheme.primary;
        badgeColor = theme.colorScheme.primary;
        break;
      default:
        iconColor = theme.colorScheme.onSurface;
        badgeColor = theme.colorScheme.onSurface;
    }

    IconData icon;
    switch (widget.action.actionType) {
      case 'auto-change':
        icon = Icons.warning;
        break;
      case 'update':
        icon = Icons.schedule;
        break;
      case 'enable-2fa':
        icon = Icons.key;
        break;
      default:
        icon = Icons.info;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        decoration: BoxDecoration(
          color: widget.action.badgeType == 'error'
              ? theme.colorScheme.surfaceContainerHigh
              : theme.colorScheme.surfaceContainer,
          borderRadius: AppBorderRadius.lgRadius,
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: widget.action.badgeType == 'error' ? AppShadows.cardElevation : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.action.title,
                              style: AppTextStyles.headlineSm.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: AppBorderRadius.fullRadius,
                            ),
                            child: Text(
                              widget.action.badge,
                              style: AppTextStyles.labelBadge.copyWith(
                                color: badgeColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.action.description,
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Action Button
            _ActionButton(
              icon: null,
              label: 'Update',
              onTap: () {
                widget.onActionTap(widget.action);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: _isHovered
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: AppTextStyles.headlineSm.copyWith(
                  color: _isHovered
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
