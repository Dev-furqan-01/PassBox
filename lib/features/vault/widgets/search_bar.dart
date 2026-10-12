import 'package:flutter/material.dart';
import '../../../core/core.dart';

class VaultSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const VaultSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppBorderRadius.defaultRadiusBorder,
            ),
            child: TextField(
              onChanged: onChanged,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodySm.copyWith(
                  color: AppColors.outline,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.outline,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceMd,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXs),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppBorderRadius.defaultRadiusBorder,
              boxShadow: AppShadows.cardElevation,
            ),
            child: const Icon(
              Icons.tune,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
