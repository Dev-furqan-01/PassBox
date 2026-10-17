import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../models/password_config.dart';
import 'components/web_preset_grid.dart';
import 'components/web_hero_buffer_card.dart';
import 'components/web_config_grid.dart';
import 'components/web_history_sidebar.dart';

/// Desktop/Web Generate Screen with dual-column workbench layout
/// Left column: Generator controls and hero display
/// Right column: Password history and audit log
class GenerateScreenWeb extends StatefulWidget {
  final PasswordConfig config;
  final String currentPassword;
  final bool isMasked;
  final List<PasswordHistoryEntry> history;
  final ValueChanged<PasswordConfig> onConfigChanged;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onToggleMask;
  final VoidCallback onSaveToVault;
  final VoidCallback onClearHistory;
  final Function(String) onCopyFromHistory;

  const GenerateScreenWeb({
    super.key,
    required this.config,
    required this.currentPassword,
    required this.isMasked,
    required this.history,
    required this.onConfigChanged,
    required this.onCopy,
    required this.onRegenerate,
    required this.onToggleMask,
    required this.onSaveToVault,
    required this.onClearHistory,
    required this.onCopyFromHistory,
  });

  @override
  State<GenerateScreenWeb> createState() => _GenerateScreenWebState();
}

class _GenerateScreenWebState extends State<GenerateScreenWeb> {
  String _selectedPreset = 'custom';

  void _handlePresetSelected(String presetId) {
    setState(() {
      _selectedPreset = presetId;
    });

    PasswordConfig newConfig;
    switch (presetId) {
      case 'max_security':
        newConfig = const PasswordConfig(
          length: 24,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: true,
          excludeAmbiguous: true,
        );
        break;
      case 'diceware':
        newConfig = const PasswordConfig(
          length: 32,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: false,
          includeSymbols: false,
          excludeAmbiguous: false,
          pronounceable: true,
        );
        break;
      case 'pin':
        newConfig = const PasswordConfig(
          length: 8,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: true,
          includeSymbols: false,
          excludeAmbiguous: false,
        );
        break;
      case 'wifi':
        newConfig = const PasswordConfig(
          length: 32,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: true,
          excludeAmbiguous: true,
        );
        break;
      default:
        return;
    }

    widget.onConfigChanged(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(event) ? KeyEventResult.handled : KeyEventResult.ignored,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Row(
          children: [
            // Left Column: Generator Controls (~55-60% width)
            Container(
              width: screenWidth * 0.58,
              constraints: const BoxConstraints(
                minWidth: 600,
                maxWidth: 900,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.compactMd),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContainerWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(theme),
                      const SizedBox(height: AppSpacing.compactMd),
                      // Compact Preset Selector
                      _buildCompactPresetSelector(theme),
                      const SizedBox(height: AppSpacing.compactMd),
                      // Hero Buffer Card
                      WebHeroBufferCard(
                        password: widget.currentPassword,
                        entropy: widget.config.entropy,
                        strengthLabel: widget.config.strengthLabel,
                        strengthLevel: widget.config.strengthLevel,
                        isMasked: widget.isMasked,
                        onCopy: widget.onCopy,
                        onRegenerate: widget.onRegenerate,
                        onSaveToVault: widget.onSaveToVault,
                        onToggleMask: widget.onToggleMask,
                      ),
                      // Config Grid
                      WebConfigGrid(
                        config: widget.config,
                        onConfigChanged: widget.onConfigChanged,
                      ),
                      // Entropy Info Banner
                      _buildEntropyBanner(theme),
                      const SizedBox(height: AppSpacing.compactMd),
                    ],
                  ),
                ),
              ),
            ),
            // Right Panel: History Sidebar (~40-45% width)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: WebHistorySidebar(
                  history: widget.history,
                  onClearHistory: widget.onClearHistory,
                  onCopyFromHistory: widget.onCopyFromHistory,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Icon(
            Icons.lock,
            color: theme.colorScheme.onPrimary,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.compactSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PassBox',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.compactSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.compactSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                        'LOCKED',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Cryptographic Generator Studio',
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactPresetSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Architecture Mode',
          style: AppTextStyles.headlineSm.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.compactSm),
        // Compact segment button row
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppBorderRadius.smRadius,
          ),
          child: Row(
            children: [
              _buildPresetButton(
                theme,
                id: 'max_security',
                label: 'Max Security',
                icon: Icons.shield,
              ),
              _buildPresetButton(
                theme,
                id: 'diceware',
                label: 'Diceware',
                icon: Icons.auto_stories,
              ),
              _buildPresetButton(
                theme,
                id: 'pin',
                label: 'PIN',
                icon: Icons.pin,
              ),
              _buildPresetButton(
                theme,
                id: 'wifi',
                label: 'WiFi',
                icon: Icons.wifi,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    ThemeData theme, {
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedPreset == id;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _handlePresetSelected(id),
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: AppBorderRadius.smRadius,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.compactXs),
                Text(
                  label,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntropyBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: AppBorderRadius.lgRadius,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entropy Calculation',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Entropy = length × log₂(charset size). Higher entropy = stronger passwords.',
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

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMac = Theme.of(context).platform == TargetPlatform.macOS;
      final controlPressed = isMac
          ? HardwareKeyboard.instance.isMetaPressed
          : HardwareKeyboard.instance.isControlPressed;

      // Spacebar or Cmd/Ctrl + R: Regenerate
      if (event.logicalKey == LogicalKeyboardKey.space ||
          (controlPressed && event.logicalKey == LogicalKeyboardKey.keyR)) {
        widget.onRegenerate();
        return true;
      }

      // Cmd/Ctrl + C: Copy
      if (controlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
        widget.onCopy();
        return true;
      }

      // Cmd/Ctrl + S: Save to Vault
      if (controlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        widget.onSaveToVault();
        return true;
      }
    }
    return false;
  }
}
