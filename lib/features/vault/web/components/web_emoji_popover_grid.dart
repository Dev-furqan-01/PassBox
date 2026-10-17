import 'package:flutter/material.dart';

/// Compact emoji popover grid for web add/edit item
/// 8x8 grid with tight 4px spacing for desktop popover
class WebEmojiPopoverGrid extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const WebEmojiPopoverGrid({
    super.key,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emojis = [
      '🔒', '🔐', '🔑', '🗝️', '🔓', '🔏', '🔎', '🔍',
      '💼', '🏢', '🏠', '🏦', '💳', '💰', '💸', '💎',
      '🌐', '📱', '💻', '⌨️', '🖥️', '📧', '📬', '📮',
      '🔴', '🟠', '🟡', '🟢', '🔵', '🟣', '⚫', '⚪',
      '😀', '😎', '🤔', '👍', '👎', '🔥', '⭐', '💡',
      '🚀', '✈️', '🚗', '🏃', '⚡', '🎯', '🎮', '🎨',
      '📚', '📝', '✏️', '📊', '📈', '🔧', '⚙️', '🛠️',
      '🌟', '💫', '✨', '🌈', '☀️', '🌙', '⭐', '🌍',
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onEmojiSelected(emojis[index]),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
