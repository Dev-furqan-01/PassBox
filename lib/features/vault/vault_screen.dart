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
import 'add_item_screen.dart';
import '../generate/generate_screen.dart';
import '../vault/vault_service.dart';
import '../vault/models/vault.dart' as VaultModel;
import '../auth/auth_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();
  final _adMobService = AdMobService();
  Timer? _bannerRefreshTimer;

  List<VaultItem> _favoriteItems = [];
  List<VaultItem> _recentItems = [];
  bool _isLoading = true;
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

  Future<void> _loadData() async {
    try {
      final vaults = await _vaultService.getAllVaults();

      // Calculate security metrics
      _weakPasswords = vaults.where((v) => v.passwordStrength < 40).length;
      _reusedPasswords = vaults.where((v) => v.isPasswordReused).length;

      // Calculate health score (0-100)
      int totalStrength = vaults.fold(0, (sum, v) => sum + v.passwordStrength);
      int averageStrength = vaults.isNotEmpty ? (totalStrength / vaults.length).round() : 0;
      _healthScore = averageStrength;

      // Convert VaultModel.Vault objects to VaultItem objects for display
      final favoriteVaults = vaults.where((v) => v.isFavorite).toList();
      final recentVaults = vaults.where((v) => !v.isFavorite).toList();

      setState(() {
        _favoriteItems = favoriteVaults.map((vault) {
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

        _recentItems = recentVaults.map((vault) {
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
      // Get the actual password from the vault service
      final vault = await _vaultService.getVault(item.id);
      if (vault != null) {
        await Clipboard.setData(ClipboardData(text: vault.password));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password copied to clipboard'),
              backgroundColor: AppColors.secondary,
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFavoriteToggle(VaultItem item) async {
    try {
      final newFavoriteStatus = !item.isFavorite;

      // Update local state immediately
      setState(() {
        // Update in favorites list
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

        // Update in recent items list
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

        // Move item between lists based on new favorite status
        if (newFavoriteStatus) {
          // Move from recent to favorites
          final itemToMove = _recentItems.firstWhere((i) => i.id == item.id);
          _recentItems.removeWhere((i) => i.id == item.id);
          _favoriteItems.add(itemToMove);
        } else {
          // Move from favorites to recent
          final itemToMove = _favoriteItems.firstWhere((i) => i.id == item.id);
          _favoriteItems.removeWhere((i) => i.id == item.id);
          _recentItems.add(itemToMove);
        }
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
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert on error
      await _reloadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status'),
            backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lateralSafeMargin,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.spaceSm),
                          FutureBuilder<String>(
                            future: _getUserName(),
                            builder: (context, snapshot) {
                              return VaultHeader(
                                userName: snapshot.data ?? 'User',
                                onLockTap: () {},
                                onNotificationTap: () {},
                                hasUnreadNotifications: true,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          VaultSearchBar(
                            hintText: 'Search ${_favoriteItems.length + _recentItems.length} items, logins, notes...',
                            onChanged: (value) {},
                            onFilterTap: () {},
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          SecurityStatusCard(
                            healthScore: _healthScore,
                            healthStatus: _getHealthStatus(_healthScore),
                            totalItems: _favoriteItems.length + _recentItems.length,
                            weakPasswords: _weakPasswords,
                            reusedPasswords: _reusedPasswords,
                            lastScanTime: 'Just now',
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          QuickActions(
                            onNewItem: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddItemScreen(),
                                ),
                              );
                              _reloadData();
                            },
                            onGenerate: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GenerateScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          // Banner Ad
                          if (_adMobService.isBannerLoaded)
                            Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: _adMobService.getBannerAdWidget(),
                            ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          _buildPinnedFavorites(),
                          const SizedBox(height: AppSpacing.spaceMd),
                          _buildRecentlyUpdated(),
                          const SizedBox(height: AppSpacing.spaceXl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPinnedFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.tertiary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pinned Favorites',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'MANAGE',
                style: AppTextStyles.labelBadge.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: AppSpacing.spaceXs,
            mainAxisSpacing: AppSpacing.spaceXs,
          ),
          itemCount: _favoriteItems.length,
          itemBuilder: (context, index) {
            final item = _favoriteItems[index];
            return VaultCard(
              item: item,
              onCopy: () => _handleCopy(item),
              onFavoriteToggle: () => _handleFavoriteToggle(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentlyUpdated() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: AppColors.outline,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recently Updated',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '4 ITEMS',
              style: AppTextStyles.labelBadge.copyWith(
                color: AppColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Column(
          children: _recentItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: VaultListItem(
                item: item,
                onCopy: () => _handleCopy(item),
                onFavoriteToggle: () => _handleFavoriteToggle(item),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
