import 'package:flutter/material.dart';
import '../../../core/core.dart';

class ItemsSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final List<FilterOption> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const ItemsSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lateralSafeMargin,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppBorderRadius.defaultRadiusBorder,
            ),
            child: TextField(
              onChanged: onChanged,
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.outline,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceMd,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filter.id == selectedFilter;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == filters.length - 1 ? 0 : AppSpacing.spaceXs,
                  ),
                  child: _FilterPill(
                    filter: filter,
                    isSelected: isSelected,
                    onTap: () => onFilterSelected(filter.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final FilterOption filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.fullRadius,
        ),
        child: Row(
          children: [
            if (filter.icon != null) ...[
              Icon(
                filter.icon,
                size: 12,
                color: filter.iconColor,
              ),
              const SizedBox(width: 6),
            ],
            if (filter.showDot && filter.dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: filter.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              filter.label,
              style: AppTextStyles.labelBadge.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.2)
                    : (filter.countColor ?? theme.colorScheme.surface),
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Text(
                filter.count.toString(),
                style: AppTextStyles.labelBadge.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : (filter.countTextColor ?? theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String id;
  final String label;
  final int count;
  final IconData? icon;
  final Color? iconColor;
  final bool showDot;
  final Color? dotColor;
  final Color? countColor;
  final Color? countTextColor;

  FilterOption({
    required this.id,
    required this.label,
    required this.count,
    this.icon,
    this.iconColor,
    this.showDot = false,
    this.dotColor,
    this.countColor,
    this.countTextColor,
  });
}
