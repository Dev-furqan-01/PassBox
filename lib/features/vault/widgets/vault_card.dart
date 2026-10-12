import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/vault_item.dart';

class VaultCard extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onCopy;
  final VoidCallback onFavoriteToggle;

  const VaultCard({
    super.key,
    required this.item,
    required this.onCopy,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ServiceIcon(icon: item.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.service,
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.username,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '••••••••',
                style: AppTextStyles.labelCodeMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onCopy,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppBorderRadius.smRadius,
                      ),
                      child: const Icon(
                        Icons.content_copy,
                        color: AppColors.onSurfaceVariant,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: AppBorderRadius.smRadius,
                      ),
                      child: Icon(
                        item.isFavorite ? Icons.star : Icons.star_border,
                        color: item.isFavorite
                            ? AppColors.tertiary
                            : AppColors.outline,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VaultListItem extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onCopy;
  final VoidCallback onFavoriteToggle;

  const VaultListItem({
    super.key,
    required this.item,
    required this.onCopy,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Row(
        children: [
          _ServiceIcon(
            icon: item.icon,
            size: 36,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.service,
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.isSecure
                            ? AppColors.secondary
                            : AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.username,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Row(
            children: [
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: const Icon(
                    Icons.content_copy,
                    color: AppColors.onSurfaceVariant,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Icon(
                    item.isFavorite ? Icons.star : Icons.star_border,
                    color: item.isFavorite
                        ? AppColors.tertiary
                        : AppColors.outline,
                    size: 16,
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

class _ServiceIcon extends StatelessWidget {
  final String? icon;
  final double size;

  const _ServiceIcon({
    this.icon,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null && icon!.length == 1) {
      // Emoji
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Center(
          child: Text(
            icon!,
            style: TextStyle(
              fontSize: size * 0.5,
            ),
          ),
        ),
      );
    } else if (icon != null) {
      // Material icon name
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Icon(
          _getIconFromString(icon!),
          color: AppColors.onSurface,
          size: size * 0.6,
        ),
      );
    } else {
      // Default
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Icon(
          Icons.dns,
          color: AppColors.onSurface,
          size: size * 0.6,
        ),
      );
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'github':
        return Icons.code;
      case 'chase':
      case 'bank':
        return Icons.account_balance;
      case 'google':
      case 'mail':
        return Icons.mail;
      case 'aws':
      case 'cloud':
        return Icons.cloud;
      case 'figma':
      case 'design':
        return Icons.draw;
      case 'notion':
        return Icons.sticky_note_2;
      case 'stripe':
      case 'payment':
        return Icons.credit_card;
      case 'twitter':
      case 'x':
        return Icons.alternate_email;
      default:
        return Icons.dns;
    }
  }
}
