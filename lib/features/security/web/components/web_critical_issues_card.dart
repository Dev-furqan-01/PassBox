import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/security_metrics.dart';

/// Critical Issues Card showing accounts with weak passwords
class WebCriticalIssuesCard extends StatelessWidget {
  final int weakPasswords;
  final Function(UrgentAction) onActionTap;

  const WebCriticalIssuesCard({
    super.key,
    required this.weakPasswords,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.06),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: theme.colorScheme.tertiary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CRITICAL ISSUES',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$weakPasswords',
                  style: TextStyle(
                    color: theme.colorScheme.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List of weak passwords
          if (weakPasswords > 0)
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: weakPasswords > 3 ? 3 : weakPasswords,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _WeakPasswordItem(
                    serviceName: _getSampleService(index),
                    onTap: () {
                      onActionTap(UrgentAction(
                        id: 'weak_passwords',
                        title: 'Weak Passwords Detected',
                        description: '$weakPasswords passwords need strengthening',
                        badge: '$weakPasswords',
                        badgeType: 'error',
                        actionType: 'update',
                      ));
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No weak passwords',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
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

  String _getSampleService(int index) {
    const services = ['Gmail', 'Amazon', 'Netflix', 'Twitter', 'Facebook'];
    return services[index % services.length];
  }
}

class _WeakPasswordItem extends StatefulWidget {
  final String serviceName;
  final VoidCallback onTap;

  const _WeakPasswordItem({
    required this.serviceName,
    required this.onTap,
  });

  @override
  State<_WeakPasswordItem> createState() => _WeakPasswordItemState();
}

class _WeakPasswordItemState extends State<_WeakPasswordItem> {
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.tertiary.withOpacity(0.05)
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.tertiary.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(widget.serviceName),
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Password strength: Weak',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Weak',
                  style: TextStyle(
                    color: theme.colorScheme.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'gmail':
        return Icons.mail;
      case 'amazon':
        return Icons.shopping_cart;
      case 'netflix':
        return Icons.play_circle;
      case 'twitter':
        return Icons.flutter_dash;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.web;
    }
  }
}
