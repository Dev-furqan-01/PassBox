import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/security_metrics.dart';

/// Reused Passwords Card showing domains with reused passwords
class WebReusedPasswordsCard extends StatelessWidget {
  final int reusedPasswords;
  final Function(UrgentAction) onActionTap;

  const WebReusedPasswordsCard({
    super.key,
    required this.reusedPasswords,
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
                      color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.content_copy,
                      color: theme.colorScheme.secondaryContainer,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'REUSED PASSWORDS',
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
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$reusedPasswords',
                  style: TextStyle(
                    color: theme.colorScheme.secondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List of reused passwords
          if (reusedPasswords > 0)
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: reusedPasswords > 3 ? 3 : reusedPasswords,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _ReusedPasswordItem(
                    domainName: _getSampleDomain(index),
                    onTap: () {
                      onActionTap(UrgentAction(
                        id: 'reused_passwords',
                        title: 'Password Reuse Detected',
                        description: '$reusedPasswords passwords are reused across accounts',
                        badge: '$reusedPasswords',
                        badgeType: 'tertiary',
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
                      'No reused passwords',
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

  String _getSampleDomain(int index) {
    const domains = ['Reddit', 'Netflix', 'Twitter', 'Instagram', 'LinkedIn'];
    return domains[index % domains.length];
  }
}

class _ReusedPasswordItem extends StatefulWidget {
  final String domainName;
  final VoidCallback onTap;

  const _ReusedPasswordItem({
    required this.domainName,
    required this.onTap,
  });

  @override
  State<_ReusedPasswordItem> createState() => _ReusedPasswordItemState();
}

class _ReusedPasswordItemState extends State<_ReusedPasswordItem> {
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
                ? theme.colorScheme.secondaryContainer.withOpacity(0.05)
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
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
                  _getDomainIcon(widget.domainName),
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
                      widget.domainName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Password reused across 2 sites',
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
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Strong',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
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

  IconData _getDomainIcon(String domain) {
    switch (domain.toLowerCase()) {
      case 'reddit':
        return Icons.chat_bubble;
      case 'netflix':
        return Icons.play_circle;
      case 'twitter':
        return Icons.flutter_dash;
      case 'instagram':
        return Icons.camera_alt;
      case 'linkedin':
        return Icons.work;
      default:
        return Icons.web;
    }
  }
}
