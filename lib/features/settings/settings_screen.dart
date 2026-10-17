import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/services/admob_service.dart';
import '../auth/auth_service.dart';
import '../vault/vault_service.dart';
import 'models/app_settings.dart';
import 'widgets/settings_section.dart';
import 'widgets/about_section.dart';
import 'services/biometric_service.dart';
import 'services/credential_storage_service.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _biometricService = BiometricService();
  final _credentialStorage = CredentialStorageService();
  final _adMobService = AdMobService();
  final _vaultService = VaultService();
  final List<SettingsItem> _accountItems = [];
  final List<SettingsItem> _securityItems = [];
  final List<SettingsItem> _appearanceItems = [];
  final List<SettingsItem> _dataItems = [];
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isProcessingSubscription = false;
  bool _colorsInitialized = false;

  String? get currentUserId => _authService.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _initializeSettings();
  }

  Future<void> _checkBiometricAvailability() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final isEnrolled = await _biometricService.areBiometricsEnrolled();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final isAvailable = isSupported && isEnrolled;

    setState(() {
      _isBiometricAvailable = isAvailable;
      _isBiometricEnabled = isEnabled;
    });

    // Update biometric item description after checking availability
    await _updateBiometricItem();
  }

  Future<void> _updateBiometricItem() async {
    String description;

    if (!_isBiometricAvailable) {
      description = 'Not available on this device';
    } else if (_isBiometricEnabled) {
      description = await _biometricService.getBiometricDescription();
    } else {
      description = 'Enable quick login with your fingerprint';
    }

    if (!mounted) return;
    final theme = Theme.of(context);
    setState(() {
      final biometricIndex = _securityItems.indexWhere((item) => item.id == 'biometric');
      if (biometricIndex != -1) {
        _securityItems[biometricIndex] = SettingsItem(
          id: 'biometric',
          title: 'Biometric Unlock',
          description: description,
          icon: Icons.fingerprint,
          iconColor: theme.colorScheme.primary,
          type: SettingsItemType.toggle,
          isEnabled: _isBiometricEnabled,
        );
      }
    });
  }

  void _updateThemeItem() {
    if (!mounted) return;
    final theme = Theme.of(context);
    setState(() {
      final themeIndex = _appearanceItems.indexWhere((item) => item.id == 'theme');
      if (themeIndex != -1) {
        _appearanceItems[themeIndex] = SettingsItem(
          id: 'theme',
          title: 'Theme',
          description: _getThemeDescription(),
          icon: Icons.brightness_6,
          iconColor: theme.colorScheme.tertiary,
          type: SettingsItemType.navigation,
        );
      }
    });
  }

  void _initializeSettings() {
    _accountItems.addAll([
      SettingsItem(
        id: 'profile',
        title: 'Profile',
        description: 'Manage your account information',
        icon: Icons.person,
        iconColor: Colors.blue, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.navigation,
      ),
      SettingsItem(
        id: 'subscription',
        title: 'Subscription',
        description: 'Manage your premium subscription',
        icon: Icons.card_membership,
        iconColor: Colors.green, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.navigation,
      ),
      SettingsItem(
        id: 'logout',
        title: 'Logout',
        description: 'Sign out of your account',
        icon: Icons.logout,
        iconColor: Colors.red, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.action,
      ),
    ]);

    _securityItems.addAll([
      SettingsItem(
        id: 'biometric',
        title: 'Biometric Unlock',
        description: 'Checking availability...',
        icon: Icons.fingerprint,
        iconColor: Colors.blue, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.toggle,
        isEnabled: _isBiometricEnabled,
      ),
    ]);

    _appearanceItems.addAll([
      SettingsItem(
        id: 'theme',
        title: 'Theme',
        description: _getThemeDescription(),
        icon: Icons.brightness_6,
        iconColor: Colors.purple, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.navigation,
      ),
    ]);

    _dataItems.addAll([
      SettingsItem(
        id: 'delete',
        title: 'Delete All Data',
        description: 'Permanently delete all vault data',
        icon: Icons.delete_forever,
        iconColor: Colors.red, // Temporary, will be updated in _initializeColors
        type: SettingsItemType.navigation,
      ),
    ]);
  }

  String _getThemeDescription() {
    final themeMode = ThemeService.instance.themeMode;
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  void _initializeColors() {
    if (_colorsInitialized) return;
    final theme = Theme.of(context);
    setState(() {
      _accountItems[0] = _accountItems[0].copyWith(iconColor: theme.colorScheme.primary);
      _accountItems[1] = _accountItems[1].copyWith(iconColor: theme.colorScheme.secondary);
      _accountItems[2] = _accountItems[2].copyWith(iconColor: theme.colorScheme.error);
      _securityItems[0] = _securityItems[0].copyWith(iconColor: theme.colorScheme.primary);
      _appearanceItems[0] = _appearanceItems[0].copyWith(
        iconColor: theme.colorScheme.tertiary,
        description: _getThemeDescription(),
      );
      _dataItems[0] = _dataItems[0].copyWith(iconColor: theme.colorScheme.error);
      _colorsInitialized = true;
    });
  }

  void _handleItemTap(String itemId) async {
    if (itemId == 'logout') {
      await _handleLogout();
      return;
    }

    if (itemId == 'profile') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }

    if (itemId == 'subscription') {
      await _handleSubscription();
      return;
    }

    if (itemId == 'delete') {
      await _handleDeleteData();
      return;
    }

    if (itemId == 'theme') {
      await _handleThemeSelection();
      return;
    }

    // TODO: Handle navigation to other specific settings screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to: $itemId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleSubscription() async {
    // Prevent double taps
    if (_isProcessingSubscription) {
      return;
    }

    setState(() => _isProcessingSubscription = true);

    try {
      // Try to show interstitial ad
      final adShown = await _adMobService.showInterstitialAd();

      if (adShown) {
        // Ad was shown, wait for it to be dismissed before continuing
        // The ad's onAdDismissedFullScreenContent callback will handle the continuation
        // For now, we'll continue after a brief delay to ensure ad is dismissed
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Continue with existing subscription action
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to: subscription'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // If anything fails, still show the subscription action
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigate to: subscription'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingSubscription = false);
      }
    }
  }

  Future<void> _handleThemeSelection() async {
    final themeMode = ThemeService.instance.themeMode;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          title: Text(
            'Select Theme',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                title: 'Light',
                icon: Icons.light_mode,
                themeMode: ThemeMode.light,
                currentThemeMode: themeMode,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                title: 'Dark',
                icon: Icons.dark_mode,
                themeMode: ThemeMode.dark,
                currentThemeMode: themeMode,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                title: 'System',
                icon: Icons.brightness_auto,
                themeMode: ThemeMode.system,
                currentThemeMode: themeMode,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      await ThemeService.instance.setThemeMode(selected);
      setState(() {
        _appearanceItems[0] = _appearanceItems[0].copyWith(
          description: _getThemeDescription(),
        );
      });
    }
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode themeMode,
    required ThemeMode currentThemeMode,
  }) {
    final theme = Theme.of(context);
    final isSelected = themeMode == currentThemeMode;

    return InkWell(
      onTap: () => Navigator.pop(context, themeMode),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMd.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteData() async {
    // Check biometric status
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();
    bool isVerified = false;

    if (isBiometricEnabled) {
      // Require biometric verification
      try {
        isVerified = await _biometricService.authenticate(
          localizedReason: 'Verify your identity to delete all data',
        );
      } catch (e) {
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Biometric authentication failed: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: theme.colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } else {
      // Require password verification
      final password = await showDialog<String>(
        context: context,
        builder: (context) => _PasswordInputDialog(),
      );

      if (password == null) {
        // User cancelled
        return;
      }

      // Verify password with auth service
      try {
        final user = _authService.currentUser;
        if (user != null) {
          final credential = await _authService.reauthenticate(
            user.email!,
            password,
          );
          isVerified = credential != null;
        }
      } catch (e) {
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password verification failed'),
              backgroundColor: theme.colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    if (!isVerified) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          title: Text(
            'Delete All Data',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete all vault data? This action cannot be undone.',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        // Delete all vault data
        await _deleteAllVaultData();

        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All data deleted successfully'),
              backgroundColor: theme.colorScheme.secondary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete data: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllVaultData() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get all vaults
    final vaults = await _vaultService.getAllVaults();

    // Delete each vault
    for (final vault in vaults) {
      await _vaultService.deleteVault(vault.vaultId);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          title: Text(
            'Logout',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Logout',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        // Don't clear credentials on logout - keep them for biometric login
        // Credentials are only cleared when biometric is disabled

        await _authService.signOut();
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: theme.colorScheme.secondary,
            ),
          );
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _handleToggle(String itemId, bool value) async {
    if (itemId == 'biometric') {
      await _handleBiometricToggle(value);
      return;
    }

    setState(() {
      // Update the setting state
      _updateItemState(itemId, value);
    });
  }

  Future<void> _handleBiometricToggle(bool value) async {
    print('Biometric toggle - Setting to: $value');

    if (value) {
      // When enabling, first verify biometrics work
      try {
        final authenticated = await _biometricService.authenticate(
          localizedReason: 'Enable biometric unlock for your vault',
        );

        if (!authenticated) {
          // Authentication failed, don't enable
          setState(() {
            _isBiometricEnabled = false;
            _updateItemState('biometric', false);
          });

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric authentication failed'),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      } catch (e) {
        // Authentication failed with error, don't enable
        setState(() {
          _isBiometricEnabled = false;
          _updateItemState('biometric', false);
        });

        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: theme.colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // After successful biometric auth, prompt user to enter password to save
      if (mounted) {
        final user = _authService.currentUser;
        if (user == null) {
          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User not authenticated'),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          setState(() {
            _isBiometricEnabled = false;
            _updateItemState('biometric', false);
          });
          return;
        }

        final result = await showDialog<bool>(
          context: context,
          builder: (context) => _CredentialInputDialog(email: user.email!),
        );

        if (result == true) {
          // User entered password, enable biometric
          setState(() {
            _isBiometricEnabled = true;
            _updateItemState('biometric', true);
          });
          await _biometricService.setBiometricEnabled(true);

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric unlock enabled! You can now use fingerprint to login.'),
                backgroundColor: theme.colorScheme.secondary,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // User cancelled, don't enable
          setState(() {
            _isBiometricEnabled = false;
            _updateItemState('biometric', false);
          });
        }
      }
    } else {
      // When disabling, clear saved credentials for security
      await _credentialStorage.clearCredentials();

      // Update state and save preference
      setState(() {
        _isBiometricEnabled = false;
        _updateItemState('biometric', false);
      });

      await _biometricService.setBiometricEnabled(false);

      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric unlock disabled'),
            backgroundColor: theme.colorScheme.secondary,
          ),
        );
      }
    }
  }

  void _updateItemState(String itemId, bool value) {
    // Update item in respective list
    setState(() {
      final accountIndex = _accountItems.indexWhere((item) => item.id == itemId);
      if (accountIndex != -1) {
        _accountItems[accountIndex] = SettingsItem(
          id: _accountItems[accountIndex].id,
          title: _accountItems[accountIndex].title,
          description: _accountItems[accountIndex].description,
          icon: _accountItems[accountIndex].icon,
          iconColor: _accountItems[accountIndex].iconColor,
          type: _accountItems[accountIndex].type,
          isEnabled: value,
          value: _accountItems[accountIndex].value,
        );
      }

      final securityIndex = _securityItems.indexWhere((item) => item.id == itemId);
      if (securityIndex != -1) {
        _securityItems[securityIndex] = SettingsItem(
          id: _securityItems[securityIndex].id,
          title: _securityItems[securityIndex].title,
          description: _securityItems[securityIndex].description,
          icon: _securityItems[securityIndex].icon,
          iconColor: _securityItems[securityIndex].iconColor,
          type: _securityItems[securityIndex].type,
          isEnabled: value,
          value: _securityItems[securityIndex].value,
        );
      }

      final appearanceIndex = _appearanceItems.indexWhere((item) => item.id == itemId);
      if (appearanceIndex != -1) {
        _appearanceItems[appearanceIndex] = SettingsItem(
          id: _appearanceItems[appearanceIndex].id,
          title: _appearanceItems[appearanceIndex].title,
          description: _appearanceItems[appearanceIndex].description,
          icon: _appearanceItems[appearanceIndex].icon,
          iconColor: _appearanceItems[appearanceIndex].iconColor,
          type: _appearanceItems[appearanceIndex].type,
          isEnabled: value,
          value: _appearanceItems[appearanceIndex].value,
        );
      }

      final dataIndex = _dataItems.indexWhere((item) => item.id == itemId);
      if (dataIndex != -1) {
        _dataItems[dataIndex] = SettingsItem(
          id: _dataItems[dataIndex].id,
          title: _dataItems[dataIndex].title,
          description: _dataItems[dataIndex].description,
          icon: _dataItems[dataIndex].icon,
          iconColor: _dataItems[dataIndex].iconColor,
          type: _dataItems[dataIndex].type,
          isEnabled: value,
          value: _dataItems[dataIndex].value,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _initializeColors();
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lateralSafeMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.spaceSm),
              SettingsSection(
                title: 'Account',
                items: _accountItems,
                onItemTap: _handleItemTap,
                onToggle: _handleToggle,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              SettingsSection(
                title: 'Security',
                items: _securityItems,
                onItemTap: _handleItemTap,
                onToggle: _handleToggle,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              SettingsSection(
                title: 'Appearance',
                items: _appearanceItems,
                onItemTap: _handleItemTap,
                onToggle: _handleToggle,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              SettingsSection(
                title: 'Data',
                items: _dataItems,
                onItemTap: _handleItemTap,
                onToggle: _handleToggle,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              const AboutSection(),
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Icon(
                Icons.lock,
                color: theme.colorScheme.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PassBox',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
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
                          const SizedBox(width: 4),
                          Text(
                            'Locked',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Settings',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                // TODO: Implement sync
              },
              icon: Icon(
                Icons.sync,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimary,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CredentialInputDialog extends StatefulWidget {
  final String email;

  const _CredentialInputDialog({required this.email});

  @override
  State<_CredentialInputDialog> createState() => _CredentialInputDialogState();
}

class _CredentialInputDialogState extends State<_CredentialInputDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _credentialStorage = CredentialStorageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _credentialStorage.saveCredentials(
        widget.email,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save credentials: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      title: Text(
        'Enable Fingerprint Login',
        style: AppTextStyles.headlineSm.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                'Enter your password to enable quick login with your fingerprint.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppBorderRadius.defaultRadiusBorder,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  filled: true,
                  fillColor: theme.colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCredentials,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                  ),
                )
              : Text(
                  'Enable',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}

class _PasswordInputDialog extends StatefulWidget {
  @override
  State<_PasswordInputDialog> createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<_PasswordInputDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      title: Text(
        'Verify Password',
        style: AppTextStyles.headlineSm.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your password to verify your identity.',
                style: AppTextStyles.bodySm.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  filled: true,
                  fillColor: theme.colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _passwordController.text);
            }
          },
          child: Text(
            'Verify',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
