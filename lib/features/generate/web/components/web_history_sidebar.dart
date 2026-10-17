import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../models/password_config.dart';

/// History sidebar for web/desktop layout
class WebHistorySidebar extends StatelessWidget {
  final List<PasswordHistoryEntry> history;
  final VoidCallback onClearHistory;
  final Function(String) onCopyFromHistory;

  const WebHistorySidebar({
    super.key,
    required this.history,
    required this.onClearHistory,
    required this.onCopyFromHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secret History',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Audit Log',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (history.isNotEmpty)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onClearHistory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                        borderRadius: AppBorderRadius.mdRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Clear',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // History List
        Expanded(
          child: history.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.spaceSm),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                      child: _HistoryEntryCard(
                        entry: entry,
                        onCopy: () => onCopyFromHistory(entry.password),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            'No History Yet',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            'Generated passwords will appear here',
            style: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntryCard extends StatefulWidget {
  final PasswordHistoryEntry entry;
  final VoidCallback onCopy;

  const _HistoryEntryCard({
    required this.entry,
    required this.onCopy,
  });

  @override
  State<_HistoryEntryCard> createState() => _HistoryEntryCardState();
}

class _HistoryEntryCardState extends State<_HistoryEntryCard> {
  bool _isHovered = false;
  bool _isMasked = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          borderRadius: AppBorderRadius.lgRadius,
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Display
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isMasked ? '•' * widget.entry.password.length : widget.entry.password,
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.onSurface,
                            letterSpacing: _isMasked ? 2 : 0.5,
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
                              _isMasked = !_isMasked;
                            });
                          },
                          child: Icon(
                            _isMasked ? Icons.visibility_off : Icons.visibility,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onCopy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: AppBorderRadius.mdRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.content_copy,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: AppTextStyles.bodySm.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            // Metadata Row
            Row(
              children: [
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
                      Icon(
                        Icons.security,
                        color: theme.colorScheme.secondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.entry.entropy} bits',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.entry.timeAgo,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
