import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/core.dart';
import 'web_emoji_popover_grid.dart';

/// Compact form fields for web add/edit item
/// Includes service name, username, password, emoji picker, and favorite toggle
class WebItemFormFields extends StatelessWidget {
  final TextEditingController serviceController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController iconController;
  final bool obscurePassword;
  final bool showEmojiPicker;
  final bool isFavorite;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onGeneratePassword;
  final VoidCallback onToggleEmojiPicker;
  final Function(String) onEmojiSelected;
  final Function(bool) onFavoriteChanged;

  const WebItemFormFields({
    super.key,
    required this.serviceController,
    required this.usernameController,
    required this.passwordController,
    required this.iconController,
    required this.obscurePassword,
    required this.showEmojiPicker,
    required this.isFavorite,
    required this.onTogglePasswordVisibility,
    required this.onGeneratePassword,
    required this.onToggleEmojiPicker,
    required this.onEmojiSelected,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Service Name & Emoji Picker Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Name field
            Expanded(
              child: _buildCompactField(
                context,
                controller: serviceController,
                label: 'Service Name',
                hintText: 'e.g., Google, GitHub',
                prefixIcon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            // Emoji selector button
            _buildEmojiButton(context),
          ],
        ),
        const SizedBox(height: 12),
        
        // Emoji popover (show when picker is open)
        if (showEmojiPicker)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WebEmojiPopoverGrid(
              onEmojiSelected: onEmojiSelected,
            ),
          ),
        
        // Username/Email field
        _buildCompactField(
          context,
          controller: usernameController,
          label: 'Username / Email',
          hintText: 'Enter username or email',
          prefixIcon: Icons.person_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Password field with inline generator
        _buildPasswordField(context),
        const SizedBox(height: 12),
        
        // Favorite toggle
        _buildFavoriteToggle(context),
      ],
    );
  }

  Widget _buildCompactField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter password',
        prefixIcon: const Icon(Icons.lock_outlined, size: 20),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility toggle
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: onTogglePasswordVisibility,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 4),
            // Copy button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: passwordController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password copied'),
                      backgroundColor: theme.colorScheme.secondary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 4),
            // Generate button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(Icons.casino_outlined, size: 20),
                onPressed: onGeneratePassword,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildEmojiButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggleEmojiPicker,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                iconController.text.isNotEmpty ? iconController.text : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteToggle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Switch(
            value: isFavorite,
            onChanged: onFavoriteChanged,
            activeTrackColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mark as Favorite',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Show in pinned favorites section',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
