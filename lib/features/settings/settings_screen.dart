import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/services/admob_service.dart';
import '../auth/auth_service.dart';
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
  final List<SettingsItem> _accountItems = [];
  final List<SettingsItem> _securityItems = [];
  final List<SettingsItem> _appearanceItems = [];
  final List<SettingsItem> _dataItems = [];
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isProcessingSubscription = false;

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
    final description = _isBiometricAvailable
        ? await _biometricService.getBiometricDescription()
        : 'Not available on this device';

    setState(() {
      final biometricIndex = _securityItems.indexWhere((item) => item.id == 'biometric');
      if (biometricIndex != -1) {
        _securityItems[biometricIndex] = SettingsItem(
          id: 'biometric',
          title: 'Biometric Unlock',
          description: description,
          icon: Icons.fingerprint,
          iconColor: AppColors.primary,
          type: SettingsItemType.toggle,
          isEnabled: _isBiometricEnabled,
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
        iconColor: AppColors.primary,
        type: SettingsItemType.navigation,
      ),
      SettingsItem(
        id: 'subscription',
        title: 'Subscription',
        description: 'Manage your premium subscription',
        icon: Icons.card_membership,
        iconColor: AppColors.secondary,
        type: SettingsItemType.navigation,
      ),
      SettingsItem(
        id: 'logout',
        title: 'Logout',
        description: 'Sign out of your account',
        icon: Icons.logout,
        iconColor: AppColors.error,
        type: SettingsItemType.action,
      ),
    ]);

    _securityItems.addAll([
      SettingsItem(
        id: 'biometric',
        title: 'Biometric Unlock',
        description: 'Checking availability...',
        icon: Icons.fingerprint,
        iconColor: AppColors.primary,
        type: SettingsItemType.toggle,
        isEnabled: _isBiometricEnabled,
      ),
    ]);

    _appearanceItems.addAll([
      SettingsItem(
        id: 'language',
        title: 'Language',
        description: 'App display language',
        icon: Icons.language,
        iconColor: AppColors.secondary,
        type: SettingsItemType.navigation,
        value: 'English',
      ),
    ]);

    _dataItems.addAll([
      SettingsItem(
        id: 'delete',
        title: 'Delete All Data',
        description: 'Permanently delete all vault data',
        icon: Icons.delete_forever,
        iconColor: AppColors.error,
        type: SettingsItemType.navigation,
      ),
    ]);
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

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: Text(
          'Logout',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Don't clear credentials on logout - keep them for biometric login
        // Credentials are only cleared when biometric is disabled

        await _authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: AppColors.secondary,
            ),
          );
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.error,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric authentication failed'),
                backgroundColor: AppColors.error,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // After successful biometric auth, prompt user to enter credentials to save
      if (mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => _CredentialInputDialog(),
        );

        if (result == true) {
          // User entered credentials, enable biometric
          setState(() {
            _isBiometricEnabled = true;
            _updateItemState('biometric', true);
          });
          await _biometricService.setBiometricEnabled(true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric unlock enabled! You can now use fingerprint to login.'),
                backgroundColor: AppColors.secondary,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric unlock disabled'),
            backgroundColor: AppColors.secondary,
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
              const AboutSection(),
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: const Icon(
                Icons.lock,
                color: AppColors.onPrimary,
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
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: AppBorderRadius.fullRadius,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Locked',
                            style: AppTextStyles.labelBadge.copyWith(
                              color: AppColors.secondary,
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
                    color: AppColors.onSurfaceVariant,
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
              icon: const Icon(
                Icons.sync,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppBorderRadius.fullRadius,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.onPrimary,
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
  @override
  State<_CredentialInputDialog> createState() => _CredentialInputDialogState();
}

class _CredentialInputDialogState extends State<_CredentialInputDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _credentialStorage = CredentialStorageService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _credentialStorage.saveCredentials(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save credentials: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      title: Text(
        'Save Credentials for Biometric Login',
        style: AppTextStyles.headlineSm.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email and password to enable biometric login.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  filled: true,
                  fillColor: AppColors.background,
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
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCredentials,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                  ),
                )
              : Text(
                  'Save',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
