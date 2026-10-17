import 'package:flutter/material.dart';
import '../../../core/core.dart';

class VaultSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const VaultSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodySm.copyWith(
            color: theme.colorScheme.outline,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.outline,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,
            vertical: AppSpacing.spaceMd,
          ),
        ),
      ),
    );
  }
}
