import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../models/credential_item.dart';
import '../widgets/items_search_bar.dart';
import 'components/web_credential_list.dart';
import 'components/web_credential_detail_pane.dart';

/// Desktop/Web Items Screen with Master-Detail split layout
/// Left panel: Search, filters, and credential list
/// Right panel: Full credential details
class ItemsScreenWeb extends StatefulWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilter;
  final List<FilterOption> filters;
  final List<CredentialItem> allItems;
  final List<CredentialItem> recentlyUsedItems;
  final List<CredentialItem> alphabeticalItems;
  final bool isLoading;
  final CredentialItem? selectedItem;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;
  final Future<void> Function(CredentialItem) onCopy;
  final Future<void> Function(CredentialItem) onEdit;
  final Future<void> Function(CredentialItem) onDelete;
  final Future<void> Function(CredentialItem) onFavoriteToggle;
  final Future<void> Function() onAddNewItem;
  final void Function(CredentialItem) onSelectItem;
  final Future<void> Function() onReloadData;

  const ItemsScreenWeb({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filters,
    required this.allItems,
    required this.recentlyUsedItems,
    required this.alphabeticalItems,
    required this.isLoading,
    this.selectedItem,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
    required this.onAddNewItem,
    required this.onSelectItem,
    required this.onReloadData,
  });

  @override
  State<ItemsScreenWeb> createState() => _ItemsScreenWebState();
}

class _ItemsScreenWebState extends State<ItemsScreenWeb> {
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // Note: Keyboard shortcuts will use FocusScope and Shortcuts widget in build method
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMac = Theme.of(context).platform == TargetPlatform.macOS;
      final controlPressed = isMac
          ? HardwareKeyboard.instance.isMetaPressed
          : HardwareKeyboard.instance.isControlPressed;

      // Cmd/Ctrl + K: Focus search
      if (controlPressed && event.logicalKey == LogicalKeyboardKey.keyK) {
        _searchFocusNode.requestFocus();
        return true;
      }

      // Cmd/Ctrl + C: Copy password if item selected
      if (controlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
        if (widget.selectedItem != null) {
          widget.onCopy(widget.selectedItem!);
        }
        return true;
      }

      // Delete/Backspace: Delete selected item
      if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        if (widget.selectedItem != null) {
          widget.onDelete(widget.selectedItem!);
        }
        return true;
      }

      // Up/Down arrows: Navigate list
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _navigateList(1);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _navigateList(-1);
        return true;
      }
    }
    return false;
  }

  void _navigateList(int direction) {
    final allListItems = [
      ...widget.recentlyUsedItems,
      ...widget.alphabeticalItems,
    ];

    if (allListItems.isEmpty) return;

    setState(() {
      _selectedIndex = (_selectedIndex + direction).clamp(0, allListItems.length - 1);
      widget.onSelectItem(allListItems[_selectedIndex]);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
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
        body: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContainerWidth,
                ),
                child: Row(
                  children: [
                    // Left Panel: Credential List (~35-40% width)
                    Container(
                      width: screenWidth * 0.38,
                      constraints: const BoxConstraints(
                        minWidth: 350,
                        maxWidth: 500,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: WebCredentialList(
                        searchController: widget.searchController,
                        searchFocusNode: _searchFocusNode,
                        searchQuery: widget.searchQuery,
                        selectedFilter: widget.selectedFilter,
                        filters: widget.filters,
                        recentlyUsedItems: widget.recentlyUsedItems,
                        alphabeticalItems: widget.alphabeticalItems,
                        selectedItem: widget.selectedItem,
                        onSearchChanged: widget.onSearchChanged,
                        onFilterSelected: widget.onFilterSelected,
                        onItemTap: widget.onSelectItem,
                        onFavoriteToggle: widget.onFavoriteToggle,
                        onAddNewItem: widget.onAddNewItem,
                        onReloadData: widget.onReloadData,
                      ),
                    ),
                    const SizedBox(width: 12), // Tight 12px gap
                    // Right Panel: Credential Detail (~60-65% width)
                    Expanded(
                      child: WebCredentialDetailPane(
                        selectedItem: widget.selectedItem,
                        onCopy: widget.onCopy,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                        onFavoriteToggle: widget.onFavoriteToggle,
                        onAddNewItem: widget.onAddNewItem,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
