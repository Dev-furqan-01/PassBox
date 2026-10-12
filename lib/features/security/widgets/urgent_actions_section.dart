import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/security_metrics.dart';

class UrgentActionsSection extends StatelessWidget {
  final List<UrgentAction> actions;
  final Function(UrgentAction)? onActionTap;

  const UrgentActionsSection({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Urgent Actions',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppBorderRadius.fullRadius,
                  ),
                  child: Text(
                    actions.length.toString(),
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'PRIORITY QUEUE',
              style: AppTextStyles.labelCodeMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        ...actions.map((action) => _UrgentActionCard(
          action: action,
          onActionTap: onActionTap,
        )),
      ],
    );
  }
}

class _UrgentActionCard extends StatelessWidget {
  final UrgentAction action;
  final Function(UrgentAction)? onActionTap;

  const _UrgentActionCard({
    required this.action,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color badgeColor;

    switch (action.badgeType) {
      case 'error':
        iconColor = AppColors.error;
        badgeColor = AppColors.error;
        break;
      case 'tertiary':
        iconColor = AppColors.tertiary;
        badgeColor = AppColors.tertiary;
        break;
      case 'primary':
        iconColor = AppColors.primary;
        badgeColor = AppColors.primary;
        break;
      default:
        iconColor = AppColors.onSurface;
        badgeColor = AppColors.onSurface;
    }

    IconData icon;
    switch (action.actionType) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
      decoration: BoxDecoration(
        color: action.badgeType == 'error'
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: action.badgeType == 'error' ? AppShadows.cardElevation : null,
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.title,
                            style: AppTextStyles.headlineSm.copyWith(
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: AppBorderRadius.fullRadius,
                          ),
                          child: Text(
                            action.badge,
                            style: AppTextStyles.labelBadge.copyWith(
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          _buildActionButtons(action),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UrgentAction action) {
    switch (action.actionType) {
      case 'auto-change':
        return Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.bolt,
                label: 'Auto-Change Password',
                onTap: () {
                  // TODO: Implement auto-change
                },
              ),
            ),
            const SizedBox(width: 4),
            _ActionButton(
              icon: Icons.more_vert,
              label: '',
              onTap: () {
                // TODO: Show options
              },
            ),
          ],
        );
      case 'update':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key ID: ${action.keyId}',
              style: AppTextStyles.labelCodeMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            _ActionButton(
              icon: null,
              label: 'Update',
              onTap: () {
                if (onActionTap != null) {
                  onActionTap!(action);
                }
              },
            ),
          ],
        );
      case 'enable-2fa':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                  'Zero-Knowledge',
                  style: AppTextStyles.labelCodeMd.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            _ActionButton(
              icon: null,
              label: 'Enable 2FA',
              onTap: () {
                // TODO: Implement 2FA enable
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: icon != null ? 36 : 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
