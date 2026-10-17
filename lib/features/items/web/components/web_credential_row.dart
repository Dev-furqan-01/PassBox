import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/credential_item.dart';

/// Desktop-optimized credential row with hover effects and selection state
class WebCredentialRow extends StatefulWidget {
  final CredentialItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const WebCredentialRow({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<WebCredentialRow> createState() => _WebCredentialRowState();
}

class _WebCredentialRowState extends State<WebCredentialRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48, // Fixed height for compact row
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.compactSm,
            vertical: AppSpacing.compactXs,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : (_isHovered
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surface),
            borderRadius: AppBorderRadius.smRadius,
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Service Icon
              _ServiceIcon(
                icon: widget.item.icon,
                color: _getIconColor(theme),
              ),
              const SizedBox(width: AppSpacing.compactSm),
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.service,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.compactXs),
                        _buildStrengthBadge(theme),
                      ],
                    ),
                    Text(
                      widget.item.username,
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.compactXs),
              // Action Buttons
              Row(
                children: [
                  if (widget.item.hasTotp) ...[
                    _buildTotpBadge(theme),
                    const SizedBox(width: AppSpacing.compactXs),
                  ],
                  _buildFavoriteButton(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthBadge(ThemeData theme) {
    Color badgeColor;
    String badgeText;

    if (widget.item.isCompromised) {
      badgeColor = theme.colorScheme.error;
      badgeText = 'Comp';
    } else if (widget.item.isReused) {
      badgeColor = theme.colorScheme.tertiary;
      badgeText = 'Reuse';
    } else {
      switch (widget.item.strength) {
        case PasswordStrength.weak:
          badgeColor = theme.colorScheme.error;
          badgeText = 'Weak';
          break;
        case PasswordStrength.medium:
          badgeColor = theme.colorScheme.tertiary;
          badgeText = 'Med';
          break;
        case PasswordStrength.strong:
          badgeColor = theme.colorScheme.secondary;
          badgeText = 'Str';
          break;
        case PasswordStrength.veryStrong:
          badgeColor = theme.colorScheme.secondary;
          badgeText = 'V.Str';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.smRadius,
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.labelBadge.copyWith(
          color: badgeColor,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildTotpBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.compactSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: AppBorderRadius.smRadius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            size: 10,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 2),
          Text(
            widget.item.totpCode ?? '---',
            style: AppTextStyles.labelBadge.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(ThemeData theme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onFavoriteToggle();
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: widget.item.isFavorite
                ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Icon(
            widget.item.isFavorite ? Icons.star : Icons.star_border,
            color: widget.item.isFavorite
                ? theme.colorScheme.tertiary
                : theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ),
      ),
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
    if (icon != null && _isEmoji(icon!)) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.smRadius,
        ),
        child: Center(
          child: Text(
            icon!,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.smRadius,
      ),
      child: Icon(
        _getIconFromString(icon),
        color: color,
        size: 18,
      ),
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
