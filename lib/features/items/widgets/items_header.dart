import 'package:flutter/material.dart';
import '../../../core/core.dart';

class ItemsHeader extends StatelessWidget {
  final VoidCallback onSyncTap;
  final VoidCallback onProfileTap;

  const ItemsHeader({
    super.key,
    required this.onSyncTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lateralSafeMargin,
        vertical: AppSpacing.spaceXs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PassBox',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: AppBorderRadius.fullRadius,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LOCKED',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Passwords',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Row(
            children: [
              GestureDetector(
                onTap: onSyncTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: const Icon(
                    Icons.sync,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.onPrimary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
