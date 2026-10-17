import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/credential_item.dart';
import '../../widgets/items_search_bar.dart';
import 'web_filter_chip_bar.dart';
import 'web_credential_row.dart';

/// Left panel for web/desktop layout
/// Contains search, filters, add button, and scrollable credential list
class WebCredentialList extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchQuery;
  final String selectedFilter;
  final List<FilterOption> filters;
  final List<CredentialItem> recentlyUsedItems;
  final List<CredentialItem> alphabeticalItems;
  final CredentialItem? selectedItem;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;
  final void Function(CredentialItem) onItemTap;
  final Future<void> Function(CredentialItem) onFavoriteToggle;
  final Future<void> Function() onAddNewItem;
  final Future<void> Function() onReloadData;

  const WebCredentialList({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filters,
    required this.recentlyUsedItems,
    required this.alphabeticalItems,
    this.selectedItem,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.onItemTap,
    required this.onFavoriteToggle,
    required this.onAddNewItem,
    required this.onReloadData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allItems = [...recentlyUsedItems, ...alphabeticalItems];

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.all(AppSpacing.compactMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title
              Row(
                children: [
                  Text(
                    'PassBox',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.compactSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compactSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.compactXs),
                        Text(
                          'LOCKED',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.compactMd),
              // Search Bar
              Container(
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
                    hintText: 'Search (⌘K)',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.outline,
                      size: 18,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.outline,
                              size: 16,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compactMd,
                      vertical: AppSpacing.compactSm,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.compactXs),
              // Filter Chips
              WebFilterChipBar(
                filters: filters,
                selectedFilter: selectedFilter,
                onFilterSelected: onFilterSelected,
              ),
              const SizedBox(height: AppSpacing.compactXs),
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddNewItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'Add Credential',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.compactSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scrollable List Area
        Expanded(
          child: allItems.isEmpty
              ? _buildEmptyState(theme)
              : _buildCredentialList(theme, allItems),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            'No credentials found',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialList(ThemeData theme, List<CredentialItem> allItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.compactSm),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        final isSelected = selectedItem?.id == item.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.compactXs),
          child: WebCredentialRow(
            item: item,
            isSelected: isSelected,
            onTap: () => onItemTap(item),
            onFavoriteToggle: () => onFavoriteToggle(item),
          ),
        );
      },
    );
  }
}
