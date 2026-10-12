import 'package:flutter/material.dart';
import '../../../core/core.dart';

class PasswordHeroCard extends StatelessWidget {
  final String password;
  final int entropy;
  final String strengthLabel;
  final int strengthLevel;
  final bool isMasked;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onSaveToVault;
  final VoidCallback onToggleMask;

  const PasswordHeroCard({
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient cryptographic watermark
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 64,
                    spreadRadius: 32,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -32,
            bottom: -32,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 64,
                    spreadRadius: 32,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildPasswordDisplay(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildStrengthMeter(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.enhanced_encryption,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'EPHEMERAL SECRET BUFFER',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.onSurface,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: AppBorderRadius.fullRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '$entropy bits • Secure',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordDisplay() {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        boxShadow: AppShadows.cardElevation,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Row(
              children: [
                Expanded(
                  child: _buildHighlightedPassword(),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggleMask,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppBorderRadius.smRadius,
                    ),
                    child: Icon(
                      isMasked ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Active Entropy Baseline Strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedPassword() {
    if (isMasked) {
      return Text(
        '•' * password.length,
        style: AppTextStyles.labelCodeLg.copyWith(
          color: AppColors.onSurface,
          letterSpacing: 2,
        ),
      );
    }

    return Wrap(
      children: password.split('').map((char) {
        Color color;
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          color = AppColors.onSurface;
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          color = AppColors.tertiary;
        } else if ('!@#\$%^&*()_+-=[]{}|;:,.<>?'.contains(char)) {
          color = AppColors.primary;
        } else {
          color = AppColors.onSurface;
        }

        return Text(
          char,
          style: AppTextStyles.labelCodeLg.copyWith(
            color: color,
            letterSpacing: 0.5,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStrengthMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Entropy Health Index',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              strengthLabel.toUpperCase(),
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (index) {
            final isActive = index < strengthLevel;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 4 ? 6 : 0,
                ),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.secondary : AppColors.surfaceContainerHighest,
                    borderRadius: AppBorderRadius.fullRadius,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 8,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _ActionButton(
            icon: Icons.content_copy,
            label: 'Copy',
            backgroundColor: AppColors.primaryContainer,
            textColor: AppColors.onPrimaryContainer,
            onTap: onCopy,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: _ActionButton(
            icon: Icons.cached,
            label: '',
            backgroundColor: AppColors.surfaceContainerHigh,
            textColor: AppColors.onSurface,
            iconColor: AppColors.primary,
            onTap: onRegenerate,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: _ActionButton(
            icon: Icons.add_moderator,
            label: '',
            backgroundColor: AppColors.surfaceContainerHigh,
            textColor: AppColors.onSurface,
            iconColor: AppColors.secondary,
            onTap: onSaveToVault,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          boxShadow: AppShadows.cardElevation,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? textColor,
              size: label.isEmpty ? 20 : 19,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.headlineSm.copyWith(
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
