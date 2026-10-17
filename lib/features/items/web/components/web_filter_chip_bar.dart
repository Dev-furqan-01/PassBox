import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../widgets/items_search_bar.dart';

/// Horizontal row of filter chips for web/desktop layout
class WebFilterChipBar extends StatelessWidget {
  final List<FilterOption> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const WebFilterChipBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // Reduced height for compact layout
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.id == selectedFilter;

          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : AppSpacing.compactXs,
            ),
            child: _WebFilterChip(
              filter: filter,
              isSelected: isSelected,
              onTap: () => onFilterSelected(filter.id),
            ),
          );
        },
      ),
    );
  }
}

class _WebFilterChip extends StatelessWidget {
  final FilterOption filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _WebFilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.compactSm,
            vertical: AppSpacing.compactXs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.smRadius,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter.icon != null) ...[
                Icon(
                  filter.icon,
                  size: 12,
                  color: filter.iconColor,
                ),
                const SizedBox(width: AppSpacing.compactXs),
              ],
              if (filter.showDot && filter.dotColor != null) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: filter.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.compactXs),
              ],
              Text(
                filter.label,
                style: AppTextStyles.labelBadge.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: AppSpacing.compactXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.compactXs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2)
                      : (filter.countColor ?? theme.colorScheme.surface),
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Text(
                  filter.count.toString(),
                  style: AppTextStyles.labelBadge.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : (filter.countTextColor ?? theme.colorScheme.onSurfaceVariant),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
