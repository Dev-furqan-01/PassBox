import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/core.dart';
import 'models/security_metrics.dart'
    show SecurityMetrics, UrgentAction, VaultSetting;
import 'security_screen.dart';
import 'web/security_screen_web.dart';
import '../security/security_event_service.dart';
import '../security/models/security_event.dart';
import '../vault/vault_service.dart';
import '../auth/auth_service.dart';

/// Responsive wrapper for Security Screen
/// Uses dual-column command dashboard on desktop (>= 1024px),
/// Uses compact layout on tablet (768-1023px),
/// Falls back to mobile layout on small screens (< 768px)
class SecurityScreenResponsive extends StatefulWidget {
  const SecurityScreenResponsive({super.key});

  @override
  State<SecurityScreenResponsive> createState() => _SecurityScreenResponsiveState();
}

class _SecurityScreenResponsiveState extends State<SecurityScreenResponsive> {
  SecurityMetrics _metrics = SecurityMetrics(
    securityScore: 0,
    securityGrade: 'F',
    securityStatus: 'LOADING',
    weakPasswords: 0,
    reusedPasswords: 0,
    breachesDetected: 0,
    missing2FA: 0,
    analyzedNodes: 0,
    lastAudit: DateTime.now(),
  );
  final List<UrgentAction> _urgentActions = [];
  final List<VaultSetting> _vaultSettings = [];
  bool _isLoading = true;

  // These will be passed to child screens
  final SecurityEventService _securityEventService = SecurityEventService();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final events = await _securityEventService.getAllEvents(limit: 50);

      // Calculate security metrics from vault data
      final weakPasswords = vaults.where((v) => v.passwordStrength < 40).length;
      final reusedPasswords = vaults.where((v) => v.isPasswordReused).length;

      // Calculate average password strength
      int totalStrength = vaults.fold(0, (sum, v) => sum + v.passwordStrength);
      int averageStrength = vaults.isNotEmpty ? (totalStrength / vaults.length).round() : 0;

      // Calculate security score (0-100)
      int securityScore = averageStrength;
      // Deduct points for weak and reused passwords
      securityScore = securityScore - (weakPasswords * 5);
      securityScore = securityScore - (reusedPasswords * 3);
      securityScore = securityScore.clamp(0, 100);

      // Determine security grade
      String securityGrade;
      String securityStatus;
      if (securityScore >= 90) {
        securityGrade = 'A';
        securityStatus = 'OPTIMAL';
      } else if (securityScore >= 80) {
        securityGrade = 'A-';
        securityStatus = 'GOOD';
      } else if (securityScore >= 70) {
        securityGrade = 'B';
        securityStatus = 'FAIR';
      } else if (securityScore >= 60) {
        securityGrade = 'C';
        securityStatus = 'MODERATE';
      } else if (securityScore >= 50) {
        securityGrade = 'D';
        securityStatus = 'WEAK';
      } else {
        securityGrade = 'F';
        securityStatus = 'CRITICAL';
      }

      // Generate urgent actions based on security issues
      _urgentActions.clear();
      if (weakPasswords > 0) {
        _urgentActions.add(UrgentAction(
          id: 'weak_passwords',
          title: 'Weak Passwords Detected',
          description: '$weakPasswords passwords need strengthening',
          badge: '$weakPasswords',
          badgeType: 'error',
          actionType: 'update',
        ));
      }
      if (reusedPasswords > 0) {
        _urgentActions.add(UrgentAction(
          id: 'reused_passwords',
          title: 'Password Reuse Detected',
          description: '$reusedPasswords passwords are reused across accounts',
          badge: '$reusedPasswords',
          badgeType: 'tertiary',
          actionType: 'update',
        ));
      }

      setState(() {
        _metrics = SecurityMetrics(
          securityScore: securityScore,
          securityGrade: securityGrade,
          securityStatus: securityStatus,
          weakPasswords: weakPasswords,
          reusedPasswords: reusedPasswords,
          breachesDetected: 0,
          missing2FA: 0,
          analyzedNodes: vaults.length,
          lastAudit: DateTime.now(),
        );

        _vaultSettings.addAll([]);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading security data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runAudit() async {
    try {
      final vaults = await _vaultService.getAllVaults();

      // Recalculate security metrics
      final weakPasswords = vaults.where((v) => v.passwordStrength < 40).length;
      final reusedPasswords = vaults.where((v) => v.isPasswordReused).length;

      int totalStrength = vaults.fold(0, (sum, v) => sum + v.passwordStrength);
      int averageStrength = vaults.isNotEmpty ? (totalStrength / vaults.length).round() : 0;

      int securityScore = averageStrength;
      securityScore = securityScore - (weakPasswords * 5);
      securityScore = securityScore - (reusedPasswords * 3);
      securityScore = securityScore.clamp(0, 100);

      String securityGrade;
      String securityStatus;
      if (securityScore >= 90) {
        securityGrade = 'A';
        securityStatus = 'OPTIMAL';
      } else if (securityScore >= 80) {
        securityGrade = 'A-';
        securityStatus = 'GOOD';
      } else if (securityScore >= 70) {
        securityGrade = 'B';
        securityStatus = 'FAIR';
      } else if (securityScore >= 60) {
        securityGrade = 'C';
        securityStatus = 'MODERATE';
      } else if (securityScore >= 50) {
        securityGrade = 'D';
        securityStatus = 'WEAK';
      } else {
        securityGrade = 'F';
        securityStatus = 'CRITICAL';
      }

      // Update urgent actions
      _urgentActions.clear();
      if (weakPasswords > 0) {
        _urgentActions.add(UrgentAction(
          id: 'weak_passwords',
          title: 'Weak Passwords Detected',
          description: '$weakPasswords passwords need strengthening',
          badge: '$weakPasswords',
          badgeType: 'error',
          actionType: 'update',
        ));
      }
      if (reusedPasswords > 0) {
        _urgentActions.add(UrgentAction(
          id: 'reused_passwords',
          title: 'Password Reuse Detected',
          description: '$reusedPasswords passwords are reused across accounts',
          badge: '$reusedPasswords',
          badgeType: 'tertiary',
          actionType: 'update',
        ));
      }

      setState(() {
        _metrics = _metrics.copyWith(
          lastAudit: DateTime.now(),
          securityScore: securityScore,
          securityGrade: securityGrade,
          securityStatus: securityStatus,
          weakPasswords: weakPasswords,
          reusedPasswords: reusedPasswords,
          analyzedNodes: vaults.length,
        );
      });
    } catch (e) {
      print('Error running audit: $e');
    }
  }

  Future<void> _handleUrgentAction(UrgentAction action) async {
    switch (action.id) {
      case 'weak_passwords':
        await _showWeakPasswordsDialog();
        break;
      case 'reused_passwords':
        await _showReusedPasswordsDialog();
        break;
      default:
        print('Unknown action: ${action.id}');
    }
  }

  Future<void> _showWeakPasswordsDialog() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final weakVaults = vaults.where((v) => v.passwordStrength < 40).toList();

      if (weakVaults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No weak passwords found')),
        );
        return;
      }

      // Show dialog for each weak password
      for (final vault in weakVaults) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  minWidth: 400,
                ),
                child: AlertDialog(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  title: Text(
                    'Update Weak Password',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service: ${vault.service}',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Password (Weak):',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: AppBorderRadius.defaultRadiusBorder,
                        ),
                        child: Text(
                          vault.password,
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Generated Strong Password:',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: AppBorderRadius.defaultRadiusBorder,
                        ),
                        child: Text(
                          _generateStrongPassword(),
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Do you want to update this password?',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Update',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (confirmed == true) {
          // Generate and update the password
          final newPassword = _generateStrongPassword();
          await _vaultService.updateVault(
            vaultId: vault.vaultId,
            password: newPassword,
          );

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password updated for ${vault.service}'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          }
        }
      }

      // Refresh metrics after updates
      await _runAudit();
    } catch (e) {
      print('Error updating weak passwords: $e');
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update passwords'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showReusedPasswordsDialog() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final reusedVaults = vaults.where((v) => v.isPasswordReused).toList();

      if (reusedVaults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reused passwords found')),
        );
        return;
      }

      // Show dialog for each reused password
      for (final vault in reusedVaults) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  minWidth: 400,
                ),
                child: AlertDialog(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  title: Text(
                    'Update Reused Password',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service: ${vault.service}',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Password (Reused):',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: AppBorderRadius.defaultRadiusBorder,
                        ),
                        child: Text(
                          vault.password,
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Generated Unique Password:',
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: AppBorderRadius.defaultRadiusBorder,
                        ),
                        child: Text(
                          _generateStrongPassword(),
                          style: AppTextStyles.labelCodeMd.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Do you want to update this password?',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Update',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (confirmed == true) {
          // Generate and update the password
          final newPassword = _generateStrongPassword();
          await _vaultService.updateVault(
            vaultId: vault.vaultId,
            password: newPassword,
          );

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password updated for ${vault.service}'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          }
        }
      }

      // Refresh metrics after updates
      await _runAudit();
    } catch (e) {
      print('Error updating reused passwords: $e');
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update passwords'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateStrongPassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String charset = uppercase + lowercase + numbers + symbols;
    final random = Random.secure();

    return List.generate(20, (index) => charset[random.nextInt(charset.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile breakpoint: < 768px
        if (constraints.maxWidth < 768) {
          return SecurityScreen(
            key: const ValueKey('mobile_security'),
          );
        }
        // Tablet and Desktop: Use web layout
        return WebSecurityScreen(
          key: const ValueKey('web_security'),
          metrics: _metrics,
          urgentActions: _urgentActions,
          vaultSettings: _vaultSettings,
          isLoading: _isLoading,
          onRunAudit: _runAudit,
          onUrgentAction: _handleUrgentAction,
        );
      },
    );
  }
}
