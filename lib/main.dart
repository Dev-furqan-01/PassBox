import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/core.dart';
import 'core/services/admob_service.dart';
import 'core/services/theme_service.dart';
import 'features/vault/vault.dart';
import 'features/vault/vault_screen_responsive.dart';
import 'features/items/items.dart';
import 'features/items/items_screen_responsive.dart';
import 'features/generate/generate_screen_responsive.dart';
import 'features/security/security.dart';
import 'features/settings/settings.dart';
import 'features/auth/auth.dart';
import 'features/auth/login_screen_responsive.dart';
import 'splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Theme Service
  await ThemeService.instance.init();
  // Initialize AdMob
  await AdMobService().initialize();
  // Preload interstitial and banner ads
  AdMobService().loadInterstitialAd();
  AdMobService().loadBannerAd();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const ResponsiveLoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

  final List<Widget> _screens = [
    const VaultScreenResponsive(),
    const ItemsScreenResponsive(),
    const GenerateScreenResponsive(),
    const SecurityScreenResponsive(),
    const SettingsScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.grid_view, label: 'Vault'),
    NavItem(icon: Icons.key, label: 'Items'),
    NavItem(icon: Icons.sync, label: 'Generate'),
    NavItem(icon: Icons.verified_user, label: 'Security', hasNotification: true),
    NavItem(icon: Icons.settings, label: 'Settings'),
  ];

  Future<void> _handleTabTap(int index) async {
    if (_currentIndex == index) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _currentIndex = index;
      _isLoading = false;
    });
  }

  bool get _isDesktopOrWeb {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 1024 || kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isDesktopOrWeb
              ? Row(
                  children: [
                    // Side Navigation Rail for desktop/web
                    _buildSideNavigationRail(),
                    // Main Content
                    Expanded(
                      child: Stack(
                        children: [
                          _screens[_currentIndex],
                          if (_isLoading) _buildLoadingOverlay(),
                        ],
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _screens[_currentIndex],
                    if (_isLoading) _buildLoadingOverlay(),
                  ],
                ),
        ],
      ),
      bottomNavigationBar: _isDesktopOrWeb ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildSideNavigationRail() {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Items
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < _navItems.length; i++)
                  _buildSideNavItem(
                    icon: _navItems[i].icon,
                    label: _navItems[i].label,
                    index: i,
                    hasNotification: _navItems[i].hasNotification,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool hasNotification = false,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleTabTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              if (hasNotification)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        child: Center(
          child: SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator around the logo
                SizedBox(
                  width: 85,
                  height: 85,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                // Logo in the center (inside the spinner)
                Image.asset(
                  'assets/logo/app_logo_bg_remover.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceXs,
            vertical: AppSpacing.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _navItems.length; i++)
                _buildNavItem(
                  icon: _navItems[i].icon,
                  label: _navItems[i].label,
                  index: i,
                  hasNotification: _navItems[i].hasNotification,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool hasNotification = false,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _handleTabTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceXs,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (hasNotification)
              Positioned(
                top: 0,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final bool hasNotification;

  NavItem({
    required this.icon,
    required this.label,
    this.hasNotification = false,
  });
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            '$title Screen',
            style: AppTextStyles.headlineLg.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            'Coming Soon',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
