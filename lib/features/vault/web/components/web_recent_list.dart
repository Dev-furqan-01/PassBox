import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/vault_item.dart';

/// Compact list view for recently updated items on web/desktop
/// Optimized for scanning and quick access
class WebRecentList extends StatelessWidget {
  final List<VaultItem> recentItems;
  final Function(VaultItem) onCopy;
  final Function(VaultItem) onFavoriteToggle;
  final VoidCallback onReloadData;

  const WebRecentList({
    super.key,
    required this.recentItems,
    required this.onCopy,
    required this.onFavoriteToggle,
    required this.onReloadData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.schedule,
                    color: theme.colorScheme.outline,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.compactSm),
                Text(
                  'Recently Updated',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.compactSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.compactSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${recentItems.length}',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.compactMd),
        if (recentItems.isEmpty)
          _buildEmptyState(context)
        else
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppBorderRadius.mdRadius,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: recentItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == recentItems.length - 1;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _buildCompactListItem(
                    context,
                    item,
                    isLast,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactListItem(
    BuildContext context,
    VaultItem item,
    bool isLast,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onCopy(item),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.compactLg,
          vertical: AppSpacing.compactSm,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getIconForService(item.service),
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.compactSm),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.service,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.username,
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                // Security Indicator
                if (!item.isSecure)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compactSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          size: 12,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Weak',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: AppSpacing.compactSm),
                // Copy Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onCopy(item),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.content_copy,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.compactXs),
                // Favorite Toggle
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onFavoriteToggle(item),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.isFavorite
                            ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        item.isFavorite ? Icons.star : Icons.star_border,
                        color: item.isFavorite
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.compactLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.mdRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.compactSm),
          Text(
            'No Items Yet',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.compactXs),
          Text(
            'Add your first password item to get started',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(String service) {
    final lowerService = service.toLowerCase();
    if (lowerService.contains('google')) return Icons.g_mobiledata;
    if (lowerService.contains('facebook')) return Icons.facebook;
    if (lowerService.contains('twitter') || lowerService.contains('x')) return Icons.flutter_dash;
    if (lowerService.contains('linkedin')) return Icons.work;
    if (lowerService.contains('github')) return Icons.code;
    if (lowerService.contains('amazon')) return Icons.shopping_cart;
    if (lowerService.contains('netflix')) return Icons.play_circle;
    if (lowerService.contains('spotify')) return Icons.music_note;
    if (lowerService.contains('dropbox')) return Icons.cloud;
    if (lowerService.contains('bank') || lowerService.contains('finance')) return Icons.account_balance;
    return Icons.lock;
  }
}
