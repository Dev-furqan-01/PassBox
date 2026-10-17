import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Expanded password hero card for web/desktop layout
class WebHeroBufferCard extends StatelessWidget {
  final String password;
  final int entropy;
  final String strengthLabel;
  final int strengthLevel;
  final bool isMasked;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onSaveToVault;
  final VoidCallback onToggleMask;

  const WebHeroBufferCard({
    super.key,
    required this.password,
    required this.entropy,
    required this.strengthLabel,
    required this.strengthLevel,
    required this.isMasked,
    required this.onCopy,
    required this.onRegenerate,
    required this.onSaveToVault,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.compactCardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.compactSm),
          // Password Display
          _buildPasswordDisplay(theme),
          const SizedBox(height: AppSpacing.compactSm),
          // Strength Meter
          _buildStrengthMeter(theme),
          const SizedBox(height: AppSpacing.compactSm),
          // Action Buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.enhanced_encryption,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.compactXs),
            Text(
              'EPHEMERAL SECRET BUFFER',
              style: AppTextStyles.headlineSm.copyWith(
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.1,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.compactSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.compactXs),
              Text(
                '$entropy bits • Secure',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordDisplay(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(AppSpacing.compactSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppBorderRadius.mdRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHighlightedPassword(theme),
          ),
          const SizedBox(width: AppSpacing.compactXs),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onToggleMask,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppBorderRadius.smRadius,
                ),
                child: Icon(
                  isMasked ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedPassword(ThemeData theme) {
    if (isMasked) {
      return Text(
        '•' * password.length,
        style: AppTextStyles.labelCodeXl.copyWith(
          color: theme.colorScheme.onSurface,
          letterSpacing: 2,
          fontSize: 18,
        ),
      );
    }

    return Wrap(
      spacing: 1,
      runSpacing: 1,
      children: password.split('').map((char) {
        Color color;
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          color = theme.colorScheme.onSurface;
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          color = theme.colorScheme.tertiary;
        } else if ('!@#\$%^&*()_+-=[]{}|;:,.<>?'.contains(char)) {
          color = theme.colorScheme.primary;
        } else {
          color = theme.colorScheme.onSurface;
        }

        return Text(
          char,
          style: AppTextStyles.labelCodeXl.copyWith(
            color: color,
            letterSpacing: 0.3,
            fontSize: 18,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStrengthMeter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Entropy Health Index',
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              strengthLabel.toUpperCase(),
              style: AppTextStyles.headlineSm.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.compactXs),
        Row(
          children: List.generate(5, (index) {
            final isActive = index < strengthLevel;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 4 ? AppSpacing.compactXs : 0,
                ),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppBorderRadius.fullRadius,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _ActionButton(
            icon: Icons.content_copy,
            label: 'Copy',
            backgroundColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onPrimary,
            onTap: onCopy,
          ),
        ),
        const SizedBox(width: AppSpacing.compactXs),
        Expanded(
          flex: 3,
          child: _ActionButton(
            icon: Icons.add_moderator,
            label: 'Save',
            backgroundColor: theme.colorScheme.secondary,
            textColor: theme.colorScheme.onSecondary,
            onTap: onSaveToVault,
          ),
        ),
        const SizedBox(width: AppSpacing.compactXs),
        Expanded(
          flex: 2,
          child: _ActionButton(
            icon: Icons.cached,
            label: 'Regen',
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            textColor: theme.colorScheme.onSurface,
            iconColor: theme.colorScheme.primary,
            onTap: onRegenerate,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: AppBorderRadius.smRadius,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor ?? widget.textColor,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.compactXs),
              Text(
                widget.label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
