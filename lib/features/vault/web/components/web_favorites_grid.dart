import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/vault_item.dart';

/// Responsive grid for pinned favorites on web/desktop
/// Adapts column count based on screen width (3-4 columns)
class WebFavoritesGrid extends StatelessWidget {
  final List<VaultItem> favoriteItems;
  final Function(VaultItem) onCopy;
  final Function(VaultItem) onFavoriteToggle;
  final VoidCallback onReloadData;

  const WebFavoritesGrid({
    super.key,
    required this.favoriteItems,
    required this.onCopy,
    required this.onFavoriteToggle,
    required this.onReloadData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine column count based on screen width (4-5 columns for compact layout)
    int crossAxisCount;
    if (screenWidth >= 1400) {
      crossAxisCount = 5;
    } else if (screenWidth >= 1100) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 3;
    }

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
                    Icons.star,
                    color: theme.colorScheme.tertiary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.compactSm),
                Text(
                  'Pinned Favorites',
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${favoriteItems.length}',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.tune,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  'Manage',
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
        if (favoriteItems.isEmpty)
          _buildEmptyState(context)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.8, // Lower aspect ratio for ~80px height
              crossAxisSpacing: AppSpacing.compactMd,
              mainAxisSpacing: AppSpacing.compactMd,
            ),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: _buildCompactCard(context, item),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context, VaultItem item) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.compactCardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppBorderRadius.mdRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForService(item.service),
              color: theme.colorScheme.primary,
              size: 18,
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
            Icons.star_border,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.compactSm),
          Text(
            'No Favorites Yet',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.compactXs),
          Text(
            'Star items to pin them here for quick access',
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
}
