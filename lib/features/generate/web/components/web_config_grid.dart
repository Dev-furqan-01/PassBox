import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/password_config.dart';

/// Modern Light Mode Character Options Card
/// Clean SaaS-style design with light-gray background (#F8F9FA)
class WebConfigGrid extends StatelessWidget {
  final PasswordConfig config;
  final ValueChanged<PasswordConfig> onConfigChanged;

  const WebConfigGrid({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character Options Grid
          _buildCharacterOptions(context),
          const SizedBox(height: 24),
          // Length Slider Section
          _buildLengthSlider(context),
        ],
      ),
    );
  }

  Widget _buildCharacterOptions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _CircularOptionTile(
          icon: 'A-Z',
          label: 'Uppercase',
          iconColor: const Color(0xFF6366F1),
          isEnabled: config.includeUppercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeUppercase: value));
          },
        ),
        _CircularOptionTile(
          icon: 'a-z',
          label: 'Lowercase',
          iconColor: const Color(0xFF10B981),
          isEnabled: config.includeLowercase,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeLowercase: value));
          },
        ),
        _CircularOptionTile(
          icon: '0-9',
          label: 'Numbers',
          iconColor: const Color(0xFFF59E0B),
          isEnabled: config.includeNumbers,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeNumbers: value));
          },
        ),
        _CircularOptionTile(
          icon: '!#',
          label: 'Symbols',
          iconColor: const Color(0xFFEF4444),
          isEnabled: config.includeSymbols,
          onToggle: (value) {
            onConfigChanged(config.copyWith(includeSymbols: value));
          },
        ),
        _CircularOptionTile(
          icon: 'Ø',
          label: 'No Ambig',
          iconColor: const Color(0xFF6B7280),
          isEnabled: config.excludeAmbiguous,
          onToggle: (value) {
            onConfigChanged(config.copyWith(excludeAmbiguous: value));
          },
        ),
        _CircularOptionTile(
          icon: 'Aa',
          label: 'Readable',
          iconColor: const Color(0xFF8B5CF6),
          isEnabled: config.pronounceable,
          onToggle: (value) {
            onConfigChanged(config.copyWith(pronounceable: value));
          },
        ),
      ],
    );
  }

  Widget _buildLengthSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Length',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            _LengthCounter(
              length: config.length,
              onDecrease: () {
                if (config.length > 8) {
                  onConfigChanged(config.copyWith(length: config.length - 1));
                }
              },
              onIncrease: () {
                if (config.length < 64) {
                  onConfigChanged(config.copyWith(length: config.length + 1));
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFF6366F1),
            overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
          ),
          child: Slider(
            value: config.length.toDouble().clamp(8.0, 64.0),
            min: 8,
            max: 64,
            divisions: 56,
            onChanged: (value) {
              onConfigChanged(config.copyWith(length: value.toInt()));
            },
          ),
        ),
      ],
    );
  }
}

class _CircularOptionTile extends StatefulWidget {
  final String icon;
  final String label;
  final Color iconColor;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _CircularOptionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  State<_CircularOptionTile> createState() => _CircularOptionTileState();
}

class _CircularOptionTileState extends State<_CircularOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onToggle(!widget.isEnabled),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.isEnabled
                    ? widget.iconColor
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isEnabled
                      ? widget.iconColor
                      : const Color(0xFFE5E7EB),
                  width: widget.isEnabled ? 3 : 2,
                ),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : (_isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.isEnabled
                        ? Colors.white
                        : widget.iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: widget.isEnabled ? FontWeight.w700 : FontWeight.w500,
                color: widget.isEnabled
                    ? widget.iconColor
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LengthCounter extends StatelessWidget {
  final int length;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _LengthCounter({
    required this.length,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Decrease Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDecrease,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  Icons.remove,
                  size: 18,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          // Length Display
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              '$length',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          // Increase Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onIncrease,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
