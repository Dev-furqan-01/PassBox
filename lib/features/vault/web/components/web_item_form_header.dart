import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/core.dart';
import '../../models/vault.dart';

/// Compact header for web add/edit item form
/// Includes compact Lottie animation, title, and close button
class WebItemFormHeader extends StatelessWidget {
  final Vault? vaultToEdit;
  final VoidCallback onClose;

  const WebItemFormHeader({
    super.key,
    this.vaultToEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Compact Lottie animation
          SizedBox(
            width: 48,
            height: 48,
            child: Lottie.asset(
              'assets/lottie/add item lock.json',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vaultToEdit != null ? 'Edit Item' : 'Add New Item',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (vaultToEdit != null)
                  Text(
                    vaultToEdit!.service,
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Close button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Close (Esc)',
            ),
          ),
        ],
      ),
    );
  }
}
