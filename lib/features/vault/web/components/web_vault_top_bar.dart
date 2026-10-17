import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Top bar for Web Vault Screen
/// Contains search bar, user greeting, and quick action buttons
class WebVaultTopBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearchChanged;
  final VoidCallback onAddNewItem;
  final VoidCallback onGeneratePassword;
  final Future<String> Function() getUserName;
  final String Function() getSearchHintText;

  const WebVaultTopBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onAddNewItem,
    required this.onGeneratePassword,
    required this.getUserName,
    required this.getSearchHintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.compactMd,
        vertical: AppSpacing.compactSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: _buildSearchBar(context),
          ),
          const SizedBox(width: AppSpacing.compactMd),
          // Quick Actions
          Row(
            children: [
              _buildAddButton(context),
              const SizedBox(width: AppSpacing.compactSm),
              _buildGenerateButton(context),
            ],
          ),
          const SizedBox(width: AppSpacing.compactMd),
          // User Greeting & Notification
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: onSearchChanged,
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: getSearchHintText(),
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Text(
                  '⌘K',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.compactSm,
              vertical: AppSpacing.compactSm,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onAddNewItem,
        icon: const Icon(Icons.add, size: 16),
        label: Text(
          'Add',
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.compactSm,
            vertical: AppSpacing.compactXs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.smRadius,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onGeneratePassword,
        icon: const Icon(Icons.sync, size: 16),
        label: Text(
          'Generate',
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.compactSm,
            vertical: AppSpacing.compactXs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.smRadius,
          ),
          side: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        FutureBuilder<String>(
          future: getUserName(),
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, ${snapshot.data ?? 'User'}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: AppSpacing.compactSm),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 18,
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
