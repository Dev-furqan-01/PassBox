import 'package:flutter/material.dart';
import '../../../core/core.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onNewItem;
  final VoidCallback onGenerate;

  const QuickActions({
    super.key,
    required this.onNewItem,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add,
            label: 'NEW ITEM',
            backgroundColor: AppColors.primaryContainer,
            textColor: AppColors.onPrimaryContainer,
            onTap: onNewItem,
            isFilled: true,
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXs),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.vpn_key,
            label: 'GENERATE',
            backgroundColor: AppColors.surfaceContainer,
            textColor: AppColors.onSurface,
            iconColor: AppColors.primary,
            onTap: onGenerate,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isFilled;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.iconColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          boxShadow: isFilled ? AppShadows.cardElevation : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? textColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelBadge.copyWith(
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
