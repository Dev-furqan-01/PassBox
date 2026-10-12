import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/core.dart';
import 'models/security_metrics.dart'
    show SecurityMetrics, UrgentAction, VaultSetting, SettingType;
import 'widgets/security_score_card.dart';
import 'widgets/security_metrics_grid.dart';
import 'widgets/urgent_actions_section.dart';
import 'widgets/vault_hardening_section.dart';
import 'widgets/encryption_info_banner.dart';
import '../security/security_event_service.dart';
import '../security/models/security_event.dart';
import '../vault/vault_service.dart';
import '../auth/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late SecurityMetrics _metrics;
  final List<UrgentAction> _urgentActions = [];
  final List<VaultSetting> _vaultSettings = [];
  final SecurityEventService _securityEventService = SecurityEventService();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

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
      securityScore -= (weakPasswords * 5);
      securityScore -= (reusedPasswords * 3);
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
      securityScore -= (weakPasswords * 5);
      securityScore -= (reusedPasswords * 3);
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

  void _handleUrgentAction(UrgentAction action) {
    switch (action.id) {
      case 'weak_passwords':
        _showWeakPasswordsDialog();
        break;
      case 'reused_passwords':
        _showReusedPasswordsDialog();
        break;
      default:
        print('Unknown action: ${action.id}');
    }
  }

  void _showWeakPasswordsDialog() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final weakVaults = vaults.where((v) => v.passwordStrength < 40).toList();

      if (weakVaults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No weak passwords found')),
        );
        return;
      }

      // Show dialog for each weak password
      for (final vault in weakVaults) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Update Weak Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${vault.service}',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Current Password (Weak):',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Text(
                    vault.password,
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Generated Strong Password:',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Text(
                    _generateStrongPassword(),
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Do you want to update this password?',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Skip'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Update'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Generate and update the password
          final newPassword = _generateStrongPassword();
          await _vaultService.updateVault(
            vaultId: vault.vaultId,
            password: newPassword,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password updated for ${vault.service}'),
                backgroundColor: AppColors.secondary,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update passwords'),
            backgroundColor: AppColors.error,
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

  void _showReusedPasswordsDialog() async {
    try {
      final vaults = await _vaultService.getAllVaults();
      final reusedVaults = vaults.where((v) => v.isPasswordReused).toList();

      if (reusedVaults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No reused passwords found')),
        );
        return;
      }

      // Show dialog for each reused password
      for (final vault in reusedVaults) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Update Reused Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${vault.service}',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Current Password (Reused):',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Text(
                    vault.password,
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Generated Unique Password:',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppBorderRadius.defaultRadiusBorder,
                  ),
                  child: Text(
                    _generateStrongPassword(),
                    style: AppTextStyles.labelCodeMd.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Do you want to update this password?',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Skip'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Update'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Generate and update the password
          final newPassword = _generateStrongPassword();
          await _vaultService.updateVault(
            vaultId: vault.vaultId,
            password: newPassword,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password updated for ${vault.service}'),
                backgroundColor: AppColors.secondary,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update passwords'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lateralSafeMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.spaceSm),
                    SecurityScoreCard(
                      metrics: _metrics,
                      onRunAudit: _runAudit,
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    SecurityMetricsGrid(metrics: _metrics),
                    const SizedBox(height: AppSpacing.spaceMd),
                    if (_urgentActions.isNotEmpty)
                      UrgentActionsSection(
                        actions: _urgentActions,
                        onActionTap: _handleUrgentAction,
                      ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    if (_vaultSettings.isNotEmpty)
                      VaultHardeningSection(settings: _vaultSettings),
                    const SizedBox(height: AppSpacing.spaceMd),
                    const EncryptionInfoBanner(),
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
                  'Security Center',
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
