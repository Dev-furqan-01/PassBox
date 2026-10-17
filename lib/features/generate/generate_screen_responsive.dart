import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import '../../../core/services/password_history_service.dart';
import 'models/password_config.dart';
import 'generate_screen.dart';
import 'web/generate_screen_web.dart';

/// Responsive wrapper for Generate Screen
/// Uses dual-column workbench on desktop (>= 1024px),
/// sidebar layout on tablet (768-1023px),
/// and falls back to mobile layout on small screens (< 768px)
class GenerateScreenResponsive extends StatefulWidget {
  const GenerateScreenResponsive({super.key});

  @override
  State<GenerateScreenResponsive> createState() => _GenerateScreenResponsiveState();
}

class _GenerateScreenResponsiveState extends State<GenerateScreenResponsive> {
  late PasswordConfig _config;
  String _currentPassword = '';
  bool _isMasked = false;
  final List<PasswordHistoryEntry> _history = [];
  final _historyService = PasswordHistoryService();

  @override
  void initState() {
    super.initState();
    _config = const PasswordConfig();
    _generatePassword();
    _loadHistory();
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

  void _handleCopy() {
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

  void _handleConfigChanged(PasswordConfig newConfig) {
    setState(() {
      _config = newConfig;
      _generatePassword();
    });
  }

  Future<void> _handleClearHistory() async {
    setState(() {
      _history.clear();
    });
    await _historyService.clearPasswordHistory();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile breakpoint: < 768px
        if (constraints.maxWidth < 768) {
          return GenerateScreen(
            key: const ValueKey('mobile_generate'),
          );
        }
        // Tablet and Desktop: Use web layout
        return GenerateScreenWeb(
          key: const ValueKey('web_generate'),
          config: _config,
          currentPassword: _currentPassword,
          isMasked: _isMasked,
          history: _history,
          onConfigChanged: _handleConfigChanged,
          onCopy: _handleCopy,
          onRegenerate: () {
            _generatePassword();
            _saveToHistory();
          },
          onToggleMask: () {
            setState(() {
              _isMasked = !_isMasked;
            });
          },
          onSaveToVault: () {
            // TODO: Implement save to vault
          },
          onClearHistory: _handleClearHistory,
          onCopyFromHistory: (password) {
            Clipboard.setData(ClipboardData(text: password));
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
          },
        );
      },
    );
  }
}
