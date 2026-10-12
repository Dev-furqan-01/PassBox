import 'package:flutter/material.dart';
import '../../../core/core.dart';

class CategoryPills extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryPills({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lateralSafeMargin,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : AppSpacing.spaceXs,
            ),
            child: _CategoryPill(
              name: category.name,
              count: category.count,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category.name),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String name;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.name,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: AppBorderRadius.fullRadius,
          boxShadow: isSelected ? AppShadows.cardElevation : null,
        ),
        child: Row(
          children: [
            Text(
              name,
              style: AppTextStyles.labelBadge.copyWith(
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
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
                    ? AppColors.onPrimary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Text(
                count.toString(),
                style: AppTextStyles.labelBadge.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final int count;

  Category({
    required this.name,
    required this.count,
  });
}
