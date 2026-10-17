import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../../../core/services/admob_service.dart';
import 'models/vault_item.dart';
import 'widgets/vault_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/security_status_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/vault_card.dart';
import 'vault_screen.dart';
import 'web/vault_screen_web.dart';
import 'add_item_screen_responsive.dart';
import '../generate/generate_screen.dart';
import '../vault/vault_service.dart';
import '../vault/models/vault.dart' as VaultModel;
import '../auth/auth_service.dart';

/// Responsive wrapper for Vault Screen
/// Uses 3-column dashboard on desktop (>= 1024px), 2-column on tablet (768-1023px),
/// and falls back to mobile layout on small screens (< 768px)
class VaultScreenResponsive extends StatefulWidget {
  const VaultScreenResponsive({super.key});

  @override
  State<VaultScreenResponsive> createState() => _VaultScreenResponsiveState();
}

class _VaultScreenResponsiveState extends State<VaultScreenResponsive> {
  final TextEditingController _searchController = TextEditingController();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();
  final _adMobService = AdMobService();
  Timer? _bannerRefreshTimer;
  Timer? _searchDebounce;

  List<VaultItem> _favoriteItems = [];
  List<VaultItem> _recentItems = [];
  List<VaultItem> _allFavoriteItems = [];
  List<VaultItem> _allRecentItems = [];
  bool _isLoading = true;
  bool _isSearching = false;
  int _weakPasswords = 0;
  int _reusedPasswords = 0;
  int _healthScore = 94;

  @override
  void initState() {
    super.initState();
    _loadData();
    _adMobService.loadBannerAd();
    _startBannerRefreshTimer();
  }

  void _startBannerRefreshTimer() {
    _bannerRefreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _adMobService.loadBannerAd();
    });
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  void _filterItems(String query) {
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _favoriteItems = _allFavoriteItems;
        _recentItems = _allRecentItems;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final vaults = await _vaultService.searchVaults(query);

        final favoriteVaults = vaults.where((v) => v.isFavorite).toList();
        final recentVaults = vaults.where((v) => !v.isFavorite).toList();

        final favoriteItems = favoriteVaults.map((vault) {
          return VaultItem(
            id: vault.vaultId,
            service: vault.service,
            username: vault.username,
            password: '••••••••',
            icon: vault.icon,
            isFavorite: vault.isFavorite,
            isSecure: vault.isSecure,
            lastUpdated: vault.lastUpdated,
            category: vault.category,
          );
        }).toList();

        final recentItems = recentVaults.map((vault) {
          return VaultItem(
            id: vault.vaultId,
            service: vault.service,
            username: vault.username,
            password: '••••••••',
            icon: vault.icon,
            isFavorite: vault.isFavorite,
            isSecure: vault.isSecure,
            lastUpdated: vault.lastUpdated,
            category: vault.category,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _favoriteItems = favoriteItems;
            _recentItems = recentItems;
            _isSearching = false;
          });
        }
      } catch (e) {
        print('Error searching vaults: $e');
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  String _getSearchHintText() {
    final totalItems = _allFavoriteItems.length + _allRecentItems.length;
    return 'Search $totalItems items, logins, notes...';
  }

  Future<void> _loadData() async {
    try {
      final vaults = await _vaultService.getAllVaults();

      _weakPasswords = vaults.where((v) => v.passwordStrength < 40).length;
      _reusedPasswords = vaults.where((v) => v.isPasswordReused).length;

      int totalStrength = vaults.fold(0, (sum, v) => sum + v.passwordStrength);
      int averageStrength = vaults.isNotEmpty ? (totalStrength / vaults.length).round() : 0;
      _healthScore = averageStrength;

      final favoriteVaults = vaults.where((v) => v.isFavorite).toList();
      final recentVaults = vaults.where((v) => !v.isFavorite).toList();

      final favoriteItems = favoriteVaults.map((vault) {
        return VaultItem(
          id: vault.vaultId,
          service: vault.service,
          username: vault.username,
          password: '••••••••',
          icon: vault.icon,
          isFavorite: vault.isFavorite,
          isSecure: vault.isSecure,
          lastUpdated: vault.lastUpdated,
          category: vault.category,
        );
      }).toList();

      final recentItems = recentVaults.map((vault) {
        return VaultItem(
          id: vault.vaultId,
          service: vault.service,
          username: vault.username,
          password: '••••••••',
          icon: vault.icon,
          isFavorite: vault.isFavorite,
          isSecure: vault.isSecure,
          lastUpdated: vault.lastUpdated,
          category: vault.category,
        );
      }).toList();

      setState(() {
        _allFavoriteItems = favoriteItems;
        _allRecentItems = recentItems;
        _favoriteItems = favoriteItems;
        _recentItems = recentItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerRefreshTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _adMobService.dispose();
    super.dispose();
  }

  Future<String> _getUserName() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        return userData?.name ?? 'User';
      }
    } catch (e) {
      print('Error getting user name: $e');
    }
    return 'User';
  }

  Future<void> _handleCopy(VaultItem item) async {
    try {
      final vault = await _vaultService.getVault(item.id);
      if (vault != null) {
        await Clipboard.setData(ClipboardData(text: vault.password));
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password copied to clipboard'),
              backgroundColor: theme.colorScheme.secondary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error copying password: $e');
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy password'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFavoriteToggle(VaultItem item) async {
    try {
      final newFavoriteStatus = !item.isFavorite;

      setState(() {
        _favoriteItems = _favoriteItems.map((favItem) {
          if (favItem.id == item.id) {
            return VaultItem(
              id: favItem.id,
              service: favItem.service,
              username: favItem.username,
              password: favItem.password,
              icon: favItem.icon,
              isFavorite: newFavoriteStatus,
              isSecure: favItem.isSecure,
              lastUpdated: favItem.lastUpdated,
              category: favItem.category,
            );
          }
          return favItem;
        }).toList();

        _recentItems = _recentItems.map((recentItem) {
          if (recentItem.id == item.id) {
            return VaultItem(
              id: recentItem.id,
              service: recentItem.service,
              username: recentItem.username,
              password: recentItem.password,
              icon: recentItem.icon,
              isFavorite: newFavoriteStatus,
              isSecure: recentItem.isSecure,
              lastUpdated: recentItem.lastUpdated,
              category: recentItem.category,
            );
          }
          return recentItem;
        }).toList();

        if (newFavoriteStatus) {
          final itemToMove = _recentItems.firstWhere((i) => i.id == item.id);
          _recentItems.removeWhere((i) => i.id == item.id);
          _favoriteItems.add(itemToMove);
        } else {
          final itemToMove = _favoriteItems.firstWhere((i) => i.id == item.id);
          _favoriteItems.removeWhere((i) => i.id == item.id);
          _recentItems.add(itemToMove);
        }
      });

      await _vaultService.updateVault(
        vaultId: item.id,
        isFavorite: newFavoriteStatus,
      );

      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.isFavorite ? 'Removed from favorites' : 'Added to favorites'),
            backgroundColor: theme.colorScheme.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      await _reloadData();
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  String _getHealthStatus(int score) {
    if (score >= 80) return 'Optimum';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Critical';
  }

  Future<void> _handleAddNewItem() async {
    await AddItemScreenResponsive.show(context);
    _reloadData();
  }

  void _handleGeneratePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenerateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile breakpoint: < 768px
        if (constraints.maxWidth < 768) {
          return VaultScreen(
            key: const ValueKey('mobile_vault'),
          );
        }
        // Tablet and Desktop: Use web layout
        return VaultScreenWeb(
          key: const ValueKey('web_vault'),
          searchController: _searchController,
          favoriteItems: _favoriteItems,
          recentItems: _recentItems,
          allFavoriteItems: _allFavoriteItems,
          allRecentItems: _allRecentItems,
          isLoading: _isLoading,
          isSearching: _isSearching,
          weakPasswords: _weakPasswords,
          reusedPasswords: _reusedPasswords,
          healthScore: _healthScore,
          onSearchChanged: _filterItems,
          onAddNewItem: _handleAddNewItem,
          onGeneratePassword: _handleGeneratePassword,
          onCopy: _handleCopy,
          onFavoriteToggle: _handleFavoriteToggle,
          onReloadData: _reloadData,
          getUserName: _getUserName,
          getSearchHintText: _getSearchHintText,
        );
      },
    );
  }
}
