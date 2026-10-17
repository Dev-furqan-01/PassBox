import 'package:flutter/material.dart';
import '../../models/security_metrics.dart';

/// Recommended Actions Card with actionable rows
class WebRecommendedActionsCard extends StatelessWidget {
  final List<UrgentAction> urgentActions;
  final Function(UrgentAction) onActionTap;

  const WebRecommendedActionsCard({
    super.key,
    required this.urgentActions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D7377).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: Color(0xFF0D7377),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'RECOMMENDED ACTIONS',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action List
          if (urgentActions.isNotEmpty)
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: urgentActions.length > 4 ? 4 : urgentActions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _RecommendedActionItem(
                    action: urgentActions[index],
                    onTap: () => onActionTap(urgentActions[index]),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All actions completed',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendedActionItem extends StatefulWidget {
  final UrgentAction action;
  final VoidCallback onTap;

  const _RecommendedActionItem({
    required this.action,
    required this.onTap,
  });

  @override
  State<_RecommendedActionItem> createState() => _RecommendedActionItemState();
}

class _RecommendedActionItemState extends State<_RecommendedActionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    switch (widget.action.badgeType) {
      case 'error':
        iconColor = const Color(0xFFF59E0B);
        break;
      case 'tertiary':
        iconColor = const Color(0xFF6366F1);
        break;
      case 'primary':
        iconColor = const Color(0xFF0D7377);
        break;
      default:
        iconColor = const Color(0xFF64748B);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF0D7377).withOpacity(0.05)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF0D7377).withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActionIcon(widget.action.actionType),
                  color: iconColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.action.title,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.action.description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _isHovered
                    ? const Color(0xFF0D7377)
                    : const Color(0xFF64748B),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'auto-change':
        return Icons.bolt;
      case 'update':
        return Icons.update;
      case 'enable-2fa':
        return Icons.key;
      default:
        return Icons.info;
    }
  }
}
