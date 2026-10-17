import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/credential_item.dart';

class CredentialRow extends StatefulWidget {
  final CredentialItem item;
  final VoidCallback onCopy;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onOptions;
  final VoidCallback? onTotpTap;

  const CredentialRow({
    super.key,
    required this.item,
    required this.onCopy,
    required this.onFavoriteToggle,
    required this.onOptions,
    this.onTotpTap,
  });

  @override
  State<CredentialRow> createState() => _CredentialRowState();
}

class _CredentialRowState extends State<CredentialRow> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceIcon(
            icon: widget.item.icon,
            color: _getIconColor(theme),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceName(theme),
                const SizedBox(height: 2),
                Text(
                  widget.item.username,
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildPasswordField(theme),
                if (widget.item.hasTotp) ...[
                  const SizedBox(height: 8),
                  _buildTotpPill(theme),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildServiceName(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.item.service,
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        _buildStrengthBadge(theme),
        if (widget.item.hasApiKey) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.key,
            color: theme.colorScheme.primary,
            size: 13,
          ),
        ],
      ],
    );
  }

  Widget _buildStrengthBadge(ThemeData theme) {
    Color badgeColor;
    String badgeText;

    if (widget.item.isCompromised) {
      badgeColor = theme.colorScheme.error;
      badgeText = 'Compromised';
    } else if (widget.item.isReused) {
      badgeColor = theme.colorScheme.tertiary;
      badgeText = 'Medium (Reused)';
    } else {
      switch (widget.item.strength) {
        case PasswordStrength.weak:
          badgeColor = theme.colorScheme.error;
          badgeText = widget.item.strength.passwordLength;
          break;
        case PasswordStrength.medium:
          badgeColor = theme.colorScheme.tertiary;
          badgeText = widget.item.strength.label;
          break;
        case PasswordStrength.strong:
          badgeColor = theme.colorScheme.secondary;
          badgeText = widget.item.strength.label;
          break;
        case PasswordStrength.veryStrong:
          badgeColor = theme.colorScheme.secondary;
          badgeText = widget.item.strength.label;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: AppBorderRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.item.isCompromised || widget.item.isReused)
            Icon(
              widget.item.isCompromised ? Icons.warning : Icons.info,
              size: 10,
              color: badgeColor,
            ),
          if (widget.item.isCompromised || widget.item.isReused)
            const SizedBox(width: 2),
          Text(
            badgeText,
            style: AppTextStyles.labelBadge.copyWith(
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            _isPasswordVisible ? widget.item.password : '•' * widget.item.password.length,
            style: AppTextStyles.labelCodeMd.copyWith(
              color: _isPasswordVisible ? theme.colorScheme.onSurface : theme.colorScheme.outline,
              letterSpacing: 2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: _isPasswordVisible ? 3 : 1,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.outline,
            size: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTotpPill(ThemeData theme) {
    return GestureDetector(
      onTap: widget.onTotpTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Row(
          children: [
            Text(
              'TOTP',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.outline,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.item.totpCode ?? '--- ---',
              style: AppTextStyles.labelCodeMd.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 8),
            _buildTotpTimer(theme),
            const SizedBox(width: 4),
            Text(
              '${widget.item.totpSecondsRemaining ?? 0}s',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotpTimer(ThemeData theme) {
    final progress = (widget.item.totpSecondsRemaining ?? 0) / 30.0;
    return SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 3,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _ActionButton(
              icon: Icons.content_copy,
              theme: theme,
              onTap: widget.onCopy,
            ),
            const SizedBox(width: 2),
            _ActionButton(
              icon: widget.item.isFavorite ? Icons.star : Icons.star_border,
              iconColor: widget.item.isFavorite ? theme.colorScheme.tertiary : null,
              theme: theme,
              onTap: widget.onFavoriteToggle,
            ),
            const SizedBox(width: 2),
            _ActionButton(
              icon: Icons.more_vert,
              theme: theme,
              onTap: widget.onOptions,
            ),
          ],
        ),
      ],
    );
  }

  Color _getIconColor(ThemeData theme) {
    if (widget.item.isCompromised) return theme.colorScheme.error;
    return theme.colorScheme.primary;
  }
}

class _ServiceIcon extends StatelessWidget {
  final String? icon;
  final Color color;

  const _ServiceIcon({
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Check if icon is an emoji (single character from emoji ranges)
    if (icon != null && _isEmoji(icon!)) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        child: Center(
          child: Text(
            icon!,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    // Fallback to Material Icon
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: Icon(
        _getIconFromString(icon),
        color: color,
        size: 20,
      ),
    );
  }

  bool _isEmoji(String text) {
    // Check if the string is a single emoji character
    if (text.isEmpty) return false;
    if (text.length > 2) return false; // Most emojis are 1-2 chars

    // Check for emoji ranges
    final runes = text.runes.toList();
    if (runes.length != 1 && runes.length != 2) return false;

    final code = runes.first;
    // Basic emoji ranges
    return (code >= 0x1F600 && code <= 0x1F64F) || // Emoticons
           (code >= 0x1F300 && code <= 0x1F5FF) || // Misc Symbols and Pictographs
           (code >= 0x1F680 && code <= 0x1F6FF) || // Transport and Map
           (code >= 0x1F1E0 && code <= 0x1F1FF) || // Flags
           (code >= 0x2600 && code <= 0x26FF) ||   // Misc symbols
           (code >= 0x2700 && code <= 0x27BF) ||   // Dingbats
           (code >= 0x1F900 && code <= 0x1F9FF) || // Supplemental Symbols and Pictographs
           (code >= 0x1FA00 && code <= 0x1FA6F) || // Chess Symbols
           (code >= 0x1FA70 && code <= 0x1FAFF) || // Symbols and Pictographs Extended-A
           (code >= 0x23F0 && code <= 0x23FF) ||   // Time & Clock
           (code >= 0x2B50 && code <= 0x2B55) ||   // Stars
           (code >= 0x2139 && code <= 0x213F);     // Information Source
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
      ),
    );
  }
}
