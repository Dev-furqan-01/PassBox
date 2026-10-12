import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/core.dart';
import 'features/auth/auth.dart';
import 'features/settings/services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = _authService.currentUser;

    if (user != null) {
      // Reload user to get latest verification status
      await _authService.reloadUser();
      final isVerified = _authService.isEmailVerified();

      if (isVerified) {
        // Check if biometric is enabled
        final isBiometricEnabled = await _biometricService.isBiometricEnabled();
        
        if (isBiometricEnabled) {
          // Show biometric authentication
          try {
            final authenticated = await _biometricService.authenticate(
              localizedReason: 'Authenticate to access your vault',
            );
            
            if (authenticated && mounted) {
              Navigator.of(context).pushReplacementNamed('/main');
            } else if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          } catch (e) {
            // Biometric failed, go to login
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        } else {
          // Biometric not enabled, go directly to main
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/main');
          }
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Forgot Password.json',
              controller: _controller,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                _controller.forward();
              },
            ),
            const SizedBox(height: AppSpacing.spaceXl),
            Text(
              'PassBox',
              style: AppTextStyles.headlineXl.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              'Secure Password Manager',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
