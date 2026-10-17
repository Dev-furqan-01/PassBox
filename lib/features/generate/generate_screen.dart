import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/services/password_history_service.dart';
import 'models/password_config.dart';
import 'widgets/password_hero_card.dart';
import 'widgets/password_config_section.dart';
import 'widgets/entropy_info_banner.dart';
import 'widgets/password_history.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  late PasswordConfig _config;
  String _currentPassword = '';
  bool _isMasked = false;
  final List<PasswordHistoryEntry> _history = [];
  final _adMobService = AdMobService();
  final _historyService = PasswordHistoryService();
  Timer? _bannerRefreshTimer;

  @override
  void initState() {
    super.initState();
    _config = const PasswordConfig();
    _generatePassword();
    _loadHistory();
    // Load banner ad (platform-specific)
    try {
      _adMobService.loadBannerAd();
      // Refresh banner every 60 seconds
      _startBannerRefreshTimer();
    } catch (e) {
      // AdMob not available on this platform (e.g., web)
      print('AdMob not available: $e');
    }
  }

  void _startBannerRefreshTimer() {
    _bannerRefreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      try {
        _adMobService.loadBannerAd();
      } catch (e) {
        // Silently fail on Ad refresh errors
        print('AdMob refresh failed: $e');
      }
    });
  }

  @override
  void dispose() {
    _bannerRefreshTimer?.cancel();
    _adMobService.dispose();
    super.dispose();
  }

  void _generatePassword() {
    setState(() {
      _currentPassword = _generateSecurePassword();
    });
  }

  String _generateSecurePassword() {
    final random = Random.secure();
    String charset = '';

    if (_config.includeUppercase) charset += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_config.includeLowercase) charset += 'abcdefghijklmnopqrstuvwxyz';
    if (_config.includeNumbers) charset += '0123456789';
    if (_config.includeSymbols) charset += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (_config.excludeAmbiguous) {
      final ambiguous = 'l1I0O';
      charset = charset.split('').where((c) => !ambiguous.contains(c)).join();
    }

    if (charset.isEmpty) {
      charset = 'abcdefghijklmnopqrstuvwxyz';
    }

    if (_config.pronounceable) {
      return _generatePronounceablePassword(random, _config.length);
    }

    final password = List.generate(
      _config.length,
      (index) => charset[random.nextInt(charset.length)],
    ).join();

    return password;
  }

  String _generatePronounceablePassword(Random random, int length) {
    const vowels = 'aeiou';
    const consonants = 'bcdfghjklmnpqrstvwxyz';
    String password = '';

    for (int i = 0; i < length; i++) {
      if (i % 2 == 0) {
        password += consonants[random.nextInt(consonants.length)];
      } else {
        password += vowels[random.nextInt(vowels.length)];
      }
    }

    return password;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentPassword));
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(
              'Copied to Clipboard',
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _saveToHistory() {
    final entry = PasswordHistoryEntry(
      password: _currentPassword,
      generatedAt: DateTime.now(),
      entropy: _config.entropy,
    );

    setState(() {
      _history.insert(0, entry);
      if (_history.length > 10) {
        _history.removeLast();
      }
    });

    // Save to Firestore
    _historyService.savePasswordHistory(entry);
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadPasswordHistory();
    if (mounted) {
      setState(() {
        _history.clear();
        _history.addAll(history);
      });
    }
  }

  Future<void> _clearHistory() async {
    setState(() {
      _history.clear();
    });
    await _historyService.clearPasswordHistory();
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
                  'Generator',
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

  Widget _buildPresetChips() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Security Architecture Mode',
              style: AppTextStyles.labelBadge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
            ),
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
                    'PRNG ACTIVE',
                    style: AppTextStyles.labelBadge.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _PresetChip(
                icon: Icons.shield,
                label: 'Maximum Security',
                isSelected: _isMaxSecurityPreset(),
                onTap: () {
                  setState(() {
                    _config = const PasswordConfig(
                      length: 24,
                      includeUppercase: true,
                      includeLowercase: true,
                      includeNumbers: true,
                      includeSymbols: true,
                      excludeAmbiguous: true,
                    );
                    _generatePassword();
                  });
                },
              ),
              const SizedBox(width: 4),
              _PresetChip(
                icon: Icons.auto_stories,
                label: 'Passphrase (Diceware)',
                isSelected: _isDicewarePreset(),
                onTap: () {
                  setState(() {
                    _config = const PasswordConfig(
                      length: 32,
                      includeUppercase: true,
                      includeLowercase: true,
                      includeNumbers: false,
                      includeSymbols: false,
                      excludeAmbiguous: false,
                      pronounceable: true,
                    );
                    _generatePassword();
                  });
                },
              ),
              const SizedBox(width: 4),
              _PresetChip(
                icon: Icons.pin,
                label: 'PIN Code (8-digit)',
                isSelected: _isPinPreset(),
                onTap: () {
                  setState(() {
                    _config = const PasswordConfig(
                      length: 8,
                      includeUppercase: false,
                      includeLowercase: false,
                      includeNumbers: true,
                      includeSymbols: false,
                      excludeAmbiguous: false,
                    );
                    _generatePassword();
                  });
                },
              ),
              const SizedBox(width: 4),
              _PresetChip(
                icon: Icons.wifi,
                label: 'WiFi Key',
                isSelected: _isWifiPreset(),
                onTap: () {
                  setState(() {
                    _config = const PasswordConfig(
                      length: 32,
                      includeUppercase: true,
                      includeLowercase: true,
                      includeNumbers: true,
                      includeSymbols: true,
                      excludeAmbiguous: true,
                    );
                    _generatePassword();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isMaxSecurityPreset() {
    return _config.length == 24 &&
        _config.includeUppercase &&
        _config.includeLowercase &&
        _config.includeNumbers &&
        _config.includeSymbols &&
        _config.excludeAmbiguous &&
        !_config.pronounceable;
  }

  bool _isDicewarePreset() {
    return _config.length == 32 &&
        _config.includeUppercase &&
        _config.includeLowercase &&
        !_config.includeNumbers &&
        !_config.includeSymbols &&
        !_config.excludeAmbiguous &&
        _config.pronounceable;
  }

  bool _isPinPreset() {
    return _config.length == 6 &&
        !_config.includeUppercase &&
        !_config.includeLowercase &&
        _config.includeNumbers &&
        !_config.includeSymbols &&
        !_config.excludeAmbiguous &&
        !_config.pronounceable;
  }

  bool _isWifiPreset() {
    return _config.length == 32 &&
        _config.includeUppercase &&
        _config.includeLowercase &&
        _config.includeNumbers &&
        _config.includeSymbols &&
        _config.excludeAmbiguous &&
        !_config.pronounceable;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lateralSafeMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.spaceSm),
                    _buildPresetChips(),
                    const SizedBox(height: AppSpacing.spaceMd),
                    PasswordHeroCard(
                      password: _currentPassword,
                      entropy: _config.entropy,
                      strengthLabel: _config.strengthLabel,
                      strengthLevel: _config.strengthLevel,
                      isMasked: _isMasked,
                      onCopy: () {
                        _copyToClipboard();
                        _saveToHistory();
                      },
                      onRegenerate: () {
                        _generatePassword();
                        _saveToHistory();
                      },
                      onSaveToVault: () {
                        // TODO: Implement save to vault
                      },
                      onToggleMask: () {
                        setState(() {
                          _isMasked = !_isMasked;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    PasswordConfigSection(
                      config: _config,
                      onConfigChanged: (newConfig) {
                        setState(() {
                          _config = newConfig;
                          _generatePassword();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    const EntropyInfoBanner(),
                    const SizedBox(height: AppSpacing.spaceMd),
                    if (_history.isNotEmpty)
                      PasswordHistory(
                        history: _history,
                        onCopyFromHistory: (password) {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: theme.colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Copied to Clipboard',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: theme.colorScheme.surface,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        },
                        onClearHistory: _clearHistory,
                      ),
                    const SizedBox(height: AppSpacing.spaceXl),
                  ],
                ),
              ),
            ),
            // Banner Ad - Positioned above bottom nav
            Container(
              alignment: Alignment.center,
              height: 50, // Banner ads need fixed height
              child: _adMobService.getBannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.fullRadius,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelBadge.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
