import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/credential_item.dart';

/// Right panel for web/desktop layout showing full credential details
class WebCredentialDetailPane extends StatefulWidget {
  final CredentialItem? selectedItem;
  final Future<void> Function(CredentialItem) onCopy;
  final Future<void> Function(CredentialItem) onEdit;
  final Future<void> Function(CredentialItem) onDelete;
  final Future<void> Function(CredentialItem) onFavoriteToggle;
  final Future<void> Function() onAddNewItem;

  const WebCredentialDetailPane({
    super.key,
    this.selectedItem,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
    required this.onAddNewItem,
  });

  @override
  State<WebCredentialDetailPane> createState() => _WebCredentialDetailPaneState();
}

class _WebCredentialDetailPaneState extends State<WebCredentialDetailPane> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.selectedItem == null) {
      return _buildEmptyState(theme);
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Detail Header
          _buildDetailHeader(theme),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Icon & Title
                  _buildServiceHeader(theme),
                  const SizedBox(height: AppSpacing.spaceXl),
                  // Credentials Section
                  _buildCredentialsSection(theme),
                  const SizedBox(height: AppSpacing.spaceXl),
                  // TOTP Section (if enabled)
                  if (widget.selectedItem!.hasTotp) ...[
                    _buildTotpSection(theme),
                    const SizedBox(height: AppSpacing.spaceXl),
                  ],
                  // URL Section (placeholder for future)
                  _buildUrlSection(theme),
                  const SizedBox(height: AppSpacing.spaceXl),
                  // Audit Trail
                  _buildAuditTrail(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 80,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            'Select an item to view details',
            style: AppTextStyles.headlineMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            'or press "+ Add Credential" to create a new one',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXl),
          ElevatedButton.icon(
            onPressed: widget.onAddNewItem,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Credential'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceLg,
                vertical: AppSpacing.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.defaultRadiusBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Copy Password Button
          _buildActionButton(
            theme: theme,
            icon: Icons.content_copy,
            label: 'Copy Password',
            onPressed: () => widget.onCopy(widget.selectedItem!),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          // Favorite Toggle Button
          _buildActionButton(
            theme: theme,
            icon: widget.selectedItem!.isFavorite ? Icons.star : Icons.star_border,
            label: widget.selectedItem!.isFavorite ? 'Unfavorite' : 'Favorite',
            iconColor: widget.selectedItem!.isFavorite
                ? theme.colorScheme.tertiary
                : null,
            onPressed: () => widget.onFavoriteToggle(widget.selectedItem!),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          // Edit Button
          _buildActionButton(
            theme: theme,
            icon: Icons.edit,
            label: 'Edit',
            onPressed: () => widget.onEdit(widget.selectedItem!),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          // Delete Button
          _buildActionButton(
            theme: theme,
            icon: Icons.delete,
            label: 'Delete',
            isDestructive: true,
            onPressed: () => widget.onDelete(widget.selectedItem!),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: iconColor),
        label: Text(
          label,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: isDestructive
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,
            vertical: AppSpacing.spaceSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader(ThemeData theme) {
    return Row(
      children: [
        // Large Service Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.lgRadius,
          ),
          child: Center(
            child: _ServiceIcon(
              icon: widget.selectedItem!.icon,
              color: _getIconColor(theme),
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.selectedItem!.service,
                style: AppTextStyles.headlineLg.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildStrengthBadge(theme),
                  if (widget.selectedItem!.hasApiKey) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.key,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'API Key',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credentials',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        // Username Field
        _buildField(
          theme: theme,
          label: 'Username',
          value: widget.selectedItem!.username,
          icon: Icons.person,
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        // Password Field
        _buildPasswordField(theme),
        const SizedBox(height: AppSpacing.spaceMd),
        // Password Strength Meter
        _buildPasswordStrengthMeter(theme),
      ],
    );
  }

  Widget _buildField({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: theme.colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isPasswordVisible
                            ? widget.selectedItem!.password
                            : '•' * widget.selectedItem!.password.length,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: _isPasswordVisible
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.outline,
                          letterSpacing: 2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthMeter(ThemeData theme) {
    double strengthValue;
    Color strengthColor;
    String strengthLabel;

    switch (widget.selectedItem!.strength) {
      case PasswordStrength.weak:
        strengthValue = 0.25;
        strengthColor = theme.colorScheme.error;
        strengthLabel = 'Weak';
        break;
      case PasswordStrength.medium:
        strengthValue = 0.5;
        strengthColor = theme.colorScheme.tertiary;
        strengthLabel = 'Medium';
        break;
      case PasswordStrength.strong:
        strengthValue = 0.75;
        strengthColor = theme.colorScheme.secondary;
        strengthLabel = 'Strong';
        break;
      case PasswordStrength.veryStrong:
        strengthValue = 1.0;
        strengthColor = theme.colorScheme.secondary;
        strengthLabel = 'Very Strong';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              strengthLabel,
              style: AppTextStyles.labelBadge.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.fullRadius,
          ),
          child: FractionallySizedBox(
            widthFactor: strengthValue,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: AppBorderRadius.fullRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotpSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Two-Factor Authentication',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: AppBorderRadius.defaultRadiusBorder,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTP Code',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.selectedItem!.totpCode ?? '--- ---',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: (widget.selectedItem!.totpSecondsRemaining ?? 0) / 30.0,
                  strokeWidth: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.selectedItem!.totpSecondsRemaining ?? 0}s',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Website',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
          child: Row(
            children: [
              Icon(
                Icons.language,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Text(
                  'https://${widget.selectedItem!.service.toLowerCase()}.com',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Icon(
                Icons.open_in_new,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTrail(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit Trail',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
          child: Column(
            children: [
              _buildAuditItem(
                theme: theme,
                label: 'Created',
                value: _formatDate(widget.selectedItem!.lastUsed),
                icon: Icons.add_circle_outline,
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              _buildAuditItem(
                theme: theme,
                label: 'Last Modified',
                value: _formatDate(widget.selectedItem!.lastUsed),
                icon: Icons.edit,
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              _buildAuditItem(
                theme: theme,
                label: 'Password Age',
                value: _calculatePasswordAge(widget.selectedItem!.lastUsed),
                icon: Icons.schedule,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditItem({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.outline,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelBadge.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthBadge(ThemeData theme) {
    Color badgeColor;
    String badgeText;

    if (widget.selectedItem!.isCompromised) {
      badgeColor = theme.colorScheme.error;
      badgeText = 'Compromised';
    } else if (widget.selectedItem!.isReused) {
      badgeColor = theme.colorScheme.tertiary;
      badgeText = 'Reused';
    } else {
      badgeColor = theme.colorScheme.secondary;
      badgeText = widget.selectedItem!.strength.label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.selectedItem!.isCompromised || widget.selectedItem!.isReused)
            Icon(
              widget.selectedItem!.isCompromised ? Icons.warning : Icons.info,
              size: 12,
              color: badgeColor,
            ),
          if (widget.selectedItem!.isCompromised || widget.selectedItem!.isReused)
            const SizedBox(width: 4),
          Text(
            badgeText,
            style: AppTextStyles.labelBadge.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(ThemeData theme) {
    if (widget.selectedItem!.isCompromised) return theme.colorScheme.error;
    return theme.colorScheme.primary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  String _calculatePasswordAge(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '< 1 month';
    } else if (difference.inDays < 90) {
      return '< 3 months';
    } else if (difference.inDays < 180) {
      return '< 6 months';
    } else {
      return '> 6 months';
    }
  }
}

class _ServiceIcon extends StatelessWidget {
  final String? icon;
  final Color color;
  final double size;

  const _ServiceIcon({
    this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null && _isEmoji(icon!)) {
      return Text(
        icon!,
        style: TextStyle(fontSize: size),
      );
    }

    return Icon(
      _getIconFromString(icon),
      color: color,
      size: size,
    );
  }

  bool _isEmoji(String text) {
    if (text.isEmpty) return false;
    if (text.length > 2) return false;

    final runes = text.runes.toList();
    if (runes.length != 1 && runes.length != 2) return false;

    final code = runes.first;
    return (code >= 0x1F600 && code <= 0x1F64F) ||
           (code >= 0x1F300 && code <= 0x1F5FF) ||
           (code >= 0x1F680 && code <= 0x1F6FF) ||
           (code >= 0x1F1E0 && code <= 0x1F1FF) ||
           (code >= 0x2600 && code <= 0x26FF) ||
           (code >= 0x2700 && code <= 0x27BF) ||
           (code >= 0x1F900 && code <= 0x1F9FF) ||
           (code >= 0x1FA00 && code <= 0x1FA6F) ||
           (code >= 0x1FA70 && code <= 0x1FAFF) ||
           (code >= 0x23F0 && code <= 0x23FF) ||
           (code >= 0x2B50 && code <= 0x2B55) ||
           (code >= 0x2139 && code <= 0x213F);
  }

  IconData _getIconFromString(String? iconName) {
    if (iconName == null) return Icons.dns;
    switch (iconName.toLowerCase()) {
      case 'github':
      case 'terminal':
        return Icons.terminal;
      case 'figma':
      case 'draw':
        return Icons.draw;
      case 'chase':
      case 'account_balance':
        return Icons.account_balance;
      case 'netflix':
      case 'movie':
        return Icons.movie;
      case 'stripe':
      case 'payments':
        return Icons.payments;
      case 'spotify':
      case 'graphic_eq':
        return Icons.graphic_eq;
      default:
        return Icons.dns;
    }
  }
}
