import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../models/password_config.dart';

class PasswordHistory extends StatefulWidget {
  final List<PasswordHistoryEntry> history;
  final ValueChanged<String> onCopyFromHistory;

  const PasswordHistory({
    super.key,
    required this.history,
    required this.onCopyFromHistory,
  });

  @override
  State<PasswordHistory> createState() => _PasswordHistoryState();
}

class _PasswordHistoryState extends State<PasswordHistory> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.lgRadius,
        boxShadow: AppShadows.cardElevation,
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Generated History',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${widget.history.length} ITEMS',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Column(
              children: widget.history.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HistoryItem(
                    entry: entry,
                    onCopy: () => widget.onCopyFromHistory(entry.password),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final PasswordHistoryEntry entry;
  final VoidCallback onCopy;

  const _HistoryItem({
    required this.entry,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedPassword(entry.password),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      entry.timeAgo,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.entropy} bits',
                      style: AppTextStyles.labelBadge.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppBorderRadius.smRadius,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.content_copy,
                    color: AppColors.onSurface,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: AppColors.onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedPassword(String password) {
    return Wrap(
      children: password.split('').map((char) {
        Color color;
        if (RegExp(r'[A-Z]').hasMatch(char)) {
          color = AppColors.onSurface;
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          color = AppColors.tertiary;
        } else if (RegExp(r'[!@#$%^&*()_+\-=\[\]{};:|,.<>/?]').hasMatch(char)) {
          color = AppColors.primary;
        } else {
          color = AppColors.onSurface;
        }

        return Text(
          char,
          style: AppTextStyles.labelCodeMd.copyWith(
            color: color,
            letterSpacing: 0.5,
          ),
        );
      }).toList(),
    );
  }
}
