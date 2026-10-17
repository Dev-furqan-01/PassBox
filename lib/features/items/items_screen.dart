import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import 'models/credential_item.dart';
import 'widgets/items_header.dart';
import 'widgets/items_search_bar.dart';
import 'widgets/credential_row.dart';
import '../vault/vault_service.dart';
import '../vault/models/vault.dart' as VaultModel;
import '../vault/add_item_screen_responsive.dart';
import '../auth/auth_service.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();

  List<CredentialItem> _recentlyUsedItems = [];
  List<CredentialItem> _alphabeticalItems = [];
  List<CredentialItem> _allItems = [];
  List<FilterOption> _filters = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final totalItems = vaults.length;

      // Calculate weak password count
      final weakVaults = vaults.where((v) => v.passwordStrength < 40).toList();

      // Convert VaultModel.Vault objects to CredentialItem objects for display
      _allItems = vaults.map((vault) {
        PasswordStrength strength;
        // Handle case where passwordStrength might be 0 (for old data)
        final strengthScore = vault.passwordStrength > 0 ? vault.passwordStrength : 50;

        if (strengthScore >= 80) {
          strength = PasswordStrength.veryStrong;
        } else if (strengthScore >= 60) {
          strength = PasswordStrength.strong;
        } else if (strengthScore >= 40) {
          strength = PasswordStrength.medium;
        } else {
          strength = PasswordStrength.weak;
        }

        return CredentialItem(
          id: vault.vaultId,
          service: vault.service,
          username: vault.username,
          password: vault.password,
          icon: vault.icon,
          isFavorite: vault.isFavorite,
          strength: strength,
          lastUsed: vault.lastUpdated,
        );
      }).toList();

      // Apply current filter before setState (don't trigger setState here)
      _applyFilter(updateState: false);

      setState(() {
        _filters = [
          FilterOption(
            id: 'all',
            label: 'All',
            count: totalItems,
          ),
          FilterOption(
            id: 'favorites',
            label: 'Favorites',
            count: vaults.where((v) => v.isFavorite).length,
            icon: Icons.star,
            iconColor: Theme.of(context).colorScheme.tertiary,
          ),
          FilterOption(
            id: 'weak',
            label: 'Weak',
            count: weakVaults.length,
            showDot: true,
            dotColor: Theme.of(context).colorScheme.tertiary,
            countColor: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
            countTextColor: Theme.of(context).colorScheme.tertiary,
          ),
          FilterOption(
            id: 'compromised',
            label: 'Compromised',
            count: 0,
            showDot: true,
            dotColor: Theme.of(context).colorScheme.secondary,
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter({bool updateState = true}) {
    List<CredentialItem> filteredItems;

    switch (_selectedFilter) {
      case 'all':
        filteredItems = _allItems;
        break;
      case 'favorites':
        filteredItems = _allItems.where((v) => v.isFavorite).toList();
        break;
      case 'weak':
        filteredItems = _allItems.where((v) => v.strength == PasswordStrength.weak).toList();
        break;
      case 'compromised':
        filteredItems = _allItems.where((v) => v.isCompromised).toList();
        break;
      default:
        filteredItems = _allItems;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        return item.service.toLowerCase().contains(query) ||
            item.username.toLowerCase().contains(query);
      }).toList();
    }

    // Split filtered items into favorites and others
    final favoriteVaults = filteredItems.where((v) => v.isFavorite).toList();
    final otherVaults = filteredItems.where((v) => !v.isFavorite).toList();

    _recentlyUsedItems = favoriteVaults;
    _alphabeticalItems = otherVaults;

    if (updateState) {
      setState(() {});
    }
  }

  Future<void> _handleCopy(CredentialItem item) async {
    try {
      // Get the actual password from the vault service
      final vault = await _vaultService.getVault(item.id);
      if (vault != null) {
        await Clipboard.setData(ClipboardData(text: vault.password));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password copied to clipboard'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error copying password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy password'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showOptionsMenu(CredentialItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.lg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: AppBorderRadius.fullRadius,
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              title: Text(
                'Edit',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleEdit(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleDelete(item);
              },
            ),
            SizedBox(height: AppSpacing.spaceSm),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEdit(CredentialItem item) async {
    try {
      final vault = await _vaultService.getVault(item.id);
      if (vault != null && mounted) {
        await AddItemScreenResponsive.show(
          context,
          vaultToEdit: vault,
        );
        _loadData();
      }
    } catch (e) {
      print('Error loading vault for edit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load item for editing'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(CredentialItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(
          'Delete ${item.service}?',
          style: AppTextStyles.headlineSm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete this credential?',
          style: AppTextStyles.bodyMd.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMd.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.bodyMd.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _vaultService.deleteVault(item.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.service} deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      } catch (e) {
        print('Error deleting item: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete item'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleFavoriteToggle(CredentialItem item) async {
    try {
      final newFavoriteStatus = !item.isFavorite;

      // Update local state immediately
      setState(() {
        // Update in all items list
        _allItems = _allItems.map((it) {
          if (it.id == item.id) {
            return CredentialItem(
              id: it.id,
              service: it.service,
              username: it.username,
              password: it.password,
              icon: it.icon,
              isFavorite: newFavoriteStatus,
              hasTotp: it.hasTotp,
              totpCode: it.totpCode,
              totpSecondsRemaining: it.totpSecondsRemaining,
              strength: it.strength,
              isReused: it.isReused,
              isCompromised: it.isCompromised,
              hasApiKey: it.hasApiKey,
              lastUsed: it.lastUsed,
            );
          }
          return it;
        }).toList();

        // Update in favorites list
        _recentlyUsedItems = _recentlyUsedItems.map((it) {
          if (it.id == item.id) {
            return CredentialItem(
              id: it.id,
              service: it.service,
              username: it.username,
              password: it.password,
              icon: it.icon,
              isFavorite: newFavoriteStatus,
              hasTotp: it.hasTotp,
              totpCode: it.totpCode,
              totpSecondsRemaining: it.totpSecondsRemaining,
              strength: it.strength,
              isReused: it.isReused,
              isCompromised: it.isCompromised,
              hasApiKey: it.hasApiKey,
              lastUsed: it.lastUsed,
            );
          }
          return it;
        }).toList();

        // Update in alphabetical list
        _alphabeticalItems = _alphabeticalItems.map((it) {
          if (it.id == item.id) {
            return CredentialItem(
              id: it.id,
              service: it.service,
              username: it.username,
              password: it.password,
              icon: it.icon,
              isFavorite: newFavoriteStatus,
              hasTotp: it.hasTotp,
              totpCode: it.totpCode,
              totpSecondsRemaining: it.totpSecondsRemaining,
              strength: it.strength,
              isReused: it.isReused,
              isCompromised: it.isCompromised,
              hasApiKey: it.hasApiKey,
              lastUsed: it.lastUsed,
            );
          }
          return it;
        }).toList();

        // Move item between lists based on new favorite status
        if (newFavoriteStatus) {
          // Move from alphabetical to recently used
          final itemToMove = _alphabeticalItems.firstWhere((i) => i.id == item.id);
          _alphabeticalItems.removeWhere((i) => i.id == item.id);
          _recentlyUsedItems.add(itemToMove);
        } else {
          // Move from recently used to alphabetical
          final itemToMove = _recentlyUsedItems.firstWhere((i) => i.id == item.id);
          _recentlyUsedItems.removeWhere((i) => i.id == item.id);
          _alphabeticalItems.add(itemToMove);
        }

        // Update filter counts
        _filters = _filters.map((filter) {
          if (filter.id == 'favorites') {
            return FilterOption(
              id: filter.id,
              label: filter.label,
              count: _allItems.where((v) => v.isFavorite).length,
              icon: filter.icon,
              iconColor: filter.iconColor,
              showDot: filter.showDot,
              dotColor: filter.dotColor,
              countColor: filter.countColor,
              countTextColor: filter.countTextColor,
            );
          }
          return filter;
        }).toList();
      });

      // Update backend
      await _vaultService.updateVault(
        vaultId: item.id,
        isFavorite: newFavoriteStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.isFavorite ? 'Removed from favorites' : 'Added to favorites'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert on error
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ItemsHeader(
                          onSyncTap: () {},
                          onProfileTap: () {},
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        ItemsSearchBar(
                          hintText: 'Search ${_allItems.length} credentials, tags, domains...',
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _applyFilter();
                            });
                          },
                          filters: _filters,
                          selectedFilter: _selectedFilter,
                          onFilterSelected: (filter) {
                            setState(() {
                              _selectedFilter = filter;
                              _applyFilter();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lateralSafeMargin,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.spaceXs),
                          ..._recentlyUsedItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: CredentialRow(
                                item: item,
                                onCopy: () => _handleCopy(item),
                                onFavoriteToggle: () => _handleFavoriteToggle(item),
                                onOptions: () => _showOptionsMenu(item),
                                onTotpTap: item.hasTotp ? () {} : null,
                              ),
                            );
                          }),
                          ..._alphabeticalItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: CredentialRow(
                                item: item,
                                onCopy: () => _handleCopy(item),
                                onFavoriteToggle: () => _handleFavoriteToggle(item),
                                onOptions: () => _showOptionsMenu(item),
                                onTotpTap: item.hasTotp ? () {} : null,
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.spaceXl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AddItemScreenResponsive.show(context);
          _loadData();
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}
