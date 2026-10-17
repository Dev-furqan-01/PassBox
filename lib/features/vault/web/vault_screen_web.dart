import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../models/vault_item.dart';
import 'components/web_vault_top_bar.dart';
import 'components/web_favorites_grid.dart';
import 'components/web_recent_list.dart';

/// Web/Desktop Vault Screen with compact layout
/// Top bar with search and actions, main content with favorites and recent items
class VaultScreenWeb extends StatefulWidget {
  final TextEditingController searchController;
  final List<VaultItem> favoriteItems;
  final List<VaultItem> recentItems;
  final List<VaultItem> allFavoriteItems;
  final List<VaultItem> allRecentItems;
  final bool isLoading;
  final bool isSearching;
  final int weakPasswords;
  final int reusedPasswords;
  final int healthScore;
  final Function(String) onSearchChanged;
  final VoidCallback onAddNewItem;
  final VoidCallback onGeneratePassword;
  final Function(VaultItem) onCopy;
  final Function(VaultItem) onFavoriteToggle;
  final VoidCallback onReloadData;
  final Future<String> Function() getUserName;
  final String Function() getSearchHintText;

  const VaultScreenWeb({
    super.key,
    required this.searchController,
    required this.favoriteItems,
    required this.recentItems,
    required this.allFavoriteItems,
    required this.allRecentItems,
    required this.isLoading,
    required this.isSearching,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.healthScore,
    required this.onSearchChanged,
    required this.onAddNewItem,
    required this.onGeneratePassword,
    required this.onCopy,
    required this.onFavoriteToggle,
    required this.onReloadData,
    required this.getUserName,
    required this.getSearchHintText,
  });

  @override
  State<VaultScreenWeb> createState() => _VaultScreenWebState();
}

class _VaultScreenWebState extends State<VaultScreenWeb> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Cmd/Ctrl + K to focus search
      if ((event.isMetaPressed || event.isControlPressed) &&
          event.logicalKey == LogicalKeyboardKey.keyK) {
        _searchFocusNode.requestFocus();
      }
      // Cmd/Ctrl + N to add new item
      if ((event.isMetaPressed || event.isControlPressed) &&
          event.logicalKey == LogicalKeyboardKey.keyN) {
        widget.onAddNewItem();
      }
    }
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Top Bar
          WebVaultTopBar(
            searchController: widget.searchController,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: widget.onSearchChanged,
            onAddNewItem: widget.onAddNewItem,
            onGeneratePassword: widget.onGeneratePassword,
            getUserName: widget.getUserName,
            getSearchHintText: widget.getSearchHintText,
          ),
          // Content Area
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.compactMd),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContainerWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compact Metric Strip
                          _buildMetricStrip(theme),
                          const SizedBox(height: AppSpacing.compactLg),
                          // Pinned Favorites
                          WebFavoritesGrid(
                            favoriteItems: widget.favoriteItems,
                            onCopy: widget.onCopy,
                            onFavoriteToggle: widget.onFavoriteToggle,
                            onReloadData: widget.onReloadData,
                          ),
                          const SizedBox(height: AppSpacing.compactLg),
                          // Recently Updated
                          WebRecentList(
                            recentItems: widget.recentItems,
                            onCopy: widget.onCopy,
                            onFavoriteToggle: widget.onFavoriteToggle,
                            onReloadData: widget.onReloadData,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStrip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.compactMd,
        vertical: AppSpacing.compactSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.mdRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildMetricItem(
            theme,
            icon: Icons.security,
            label: 'Health Score',
            value: '${widget.healthScore}%',
            color: _getScoreColor(widget.healthScore, theme),
          ),
          const SizedBox(width: AppSpacing.compactMd),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.compactMd),
          _buildMetricItem(
            theme,
            icon: Icons.inventory_2_outlined,
            label: 'Total Items',
            value: '${widget.favoriteItems.length + widget.recentItems.length}',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.compactMd),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.compactMd),
          _buildMetricItem(
            theme,
            icon: Icons.warning_amber_outlined,
            label: 'Weak',
            value: '${widget.weakPasswords}',
            color: widget.weakPasswords > 0 ? theme.colorScheme.tertiary : theme.colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.compactMd),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.compactMd),
          _buildMetricItem(
            theme,
            icon: Icons.content_copy_outlined,
            label: 'Reused',
            value: '${widget.reusedPasswords}',
            color: widget.reusedPasswords > 0 ? theme.colorScheme.tertiary : theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.compactSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(int score, ThemeData theme) {
    if (score >= 80) return theme.colorScheme.secondary;
    if (score >= 60) return theme.colorScheme.primary;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return theme.colorScheme.tertiary;
    return Colors.red;
  }
}
