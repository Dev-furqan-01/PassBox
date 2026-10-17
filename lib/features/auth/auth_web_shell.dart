import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Shared branded shell for authentication screens on web/desktop
/// Provides a consistent left panel with branding and artwork
class AuthWebShell extends StatelessWidget {
  final Widget child;
  final String? subtitle;

  const AuthWebShell({
    super.key,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Row(
        children: [
          // Left branded panel (50% width on desktop)
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/logo/app_logo_bg_remover.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Tagline
                    Text(
                      'Secure Your Digital Life',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle ?? 'Manage your passwords securely with enterprise-grade encryption',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 60),
                    // Features
                    _buildFeatureItem(
                      icon: Icons.security,
                      title: 'Military-Grade Encryption',
                      description: 'AES-256 encryption for your passwords',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.cloud_sync,
                      title: 'Cloud Sync',
                      description: 'Access your vault anywhere, anytime',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.fingerprint,
                      title: 'Biometric Login',
                      description: 'Quick access with fingerprint or face ID',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right content panel (50% width on desktop)
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
