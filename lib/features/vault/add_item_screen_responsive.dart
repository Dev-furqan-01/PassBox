import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'web/add_item_screen_web.dart';
import 'models/vault.dart';

/// Responsive wrapper for Add/Edit Item Screen
/// Uses slide-over drawer on desktop/web (>= 768px)
/// Falls back to full-screen mobile layout on small screens (< 768px)
class AddItemScreenResponsive extends StatelessWidget {
  final Vault? vaultToEdit;

  const AddItemScreenResponsive({super.key, this.vaultToEdit});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile breakpoint: < 768px
        if (constraints.maxWidth < 768) {
          return AddItemScreen(
            key: const ValueKey('mobile_add_item'),
            vaultToEdit: vaultToEdit,
          );
        }
        // Tablet and Desktop: Use web slide-over drawer
        return WebAddItemScreen(
          key: const ValueKey('web_add_item'),
          vaultToEdit: vaultToEdit,
        );
      },
    );
  }

  /// Helper method to show the screen appropriately based on platform
  static Future<void> show(BuildContext context, {Vault? vaultToEdit}) async {
    final mediaQuery = MediaQuery.of(context);
    
    if (mediaQuery.size.width >= 768) {
      // Desktop: Show as dialog
      await showDialog(
        context: context,
        builder: (context) => WebAddItemScreen(vaultToEdit: vaultToEdit),
      );
    } else {
      // Mobile: Navigate as full screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddItemScreen(vaultToEdit: vaultToEdit),
        ),
      );
    }
  }
}
