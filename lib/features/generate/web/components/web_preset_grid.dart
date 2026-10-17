import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Grid-based preset selector for web/desktop layout
class WebPresetGrid extends StatelessWidget {
  final String selectedPreset;
  final ValueChanged<String> onPresetSelected;

  const WebPresetGrid({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Security Architecture Mode',
              style: AppTextStyles.headlineSm.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PRNG ACTIVE',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.secondary,
                ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.spaceSm,
          crossAxisSpacing: AppSpacing.spaceSm,
          childAspectRatio: 2.2,
          children: [
            _PresetCard(
              id: 'max_security',
              icon: Icons.shield,
              label: 'Maximum Security',
              description: '24 chars • All types • No ambiguous',
              isSelected: selectedPreset == 'max_security',
              onTap: () => onPresetSelected('max_security'),
            ),
            _PresetCard(
              id: 'diceware',
              icon: Icons.auto_stories,
              label: 'Passphrase (Diceware)',
              description: '32 chars • Letters only • Pronounceable',
              isSelected: selectedPreset == 'diceware',
              onTap: () => onPresetSelected('diceware'),
            ),
            _PresetCard(
              id: 'pin',
              icon: Icons.pin,
              label: 'PIN Code',
              description: '8 digits • Numeric only',
              isSelected: selectedPreset == 'pin',
              onTap: () => onPresetSelected('pin'),
            ),
            _PresetCard(
              id: 'wifi',
              icon: Icons.wifi,
              label: 'WiFi Key',
              description: '32 chars • All types • No ambiguous',
              isSelected: selectedPreset == 'wifi',
              onTap: () => onPresetSelected('wifi'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetCard extends StatefulWidget {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetCard({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.spaceSm),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : (_isHovered
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surface),
            borderRadius: AppBorderRadius.lgRadius,
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: widget.isSelected || _isHovered
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppBorderRadius.mdRadius,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
