import 'package:flutter/material.dart';
import '../../../core/core.dart';

class SortToolbar extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onViewToggle;
  final VoidCallback onSelectMode;
  final bool isCompactView;

  const SortToolbar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    required this.onViewToggle,
    required this.onSelectMode,
    this.isCompactView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lateralSafeMargin,
        vertical: AppSpacing.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showSortOptions(context),
            child: Row(
              children: [
                const Icon(
                  Icons.swap_vert,
                  color: AppColors.onSurfaceVariant,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'SORT BY: ',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  currentSort.toUpperCase(),
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  color: AppColors.onSurfaceVariant,
                  size: 14,
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onViewToggle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Icon(
                    isCompactView ? Icons.list : Icons.density_medium,
                    color: AppColors.onSurface,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onSelectMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: AppBorderRadius.smRadius,
                  ),
                  child: Text(
                    'SELECT',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.1,
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SortOption(
                label: 'Recently Used',
                isSelected: currentSort == 'Recently Used',
                onTap: () {
                  onSortChanged('Recently Used');
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Alphabetical',
                isSelected: currentSort == 'Alphabetical',
                onTap: () {
                  onSortChanged('Alphabetical');
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Password Strength',
                isSelected: currentSort == 'Password Strength',
                onTap: () {
                  onSortChanged('Password Strength');
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Date Created',
                isSelected: currentSort == 'Date Created',
                onTap: () {
                  onSortChanged('Date Created');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMd.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
