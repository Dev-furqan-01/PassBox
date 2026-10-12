import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'auth_service.dart';
import '../security/models/security_event.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with WidgetsBindingObserver {
  final _authService = AuthService();
  Timer? _timer;
  int _remainingSeconds = 5; // 5 seconds (temporary for testing)
  bool _isLoading = false;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfAlreadyVerified();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload verification status when app resumes from background
    // User may have verified email in Gmail/browser and returned to app
    if (state == AppLifecycleState.resumed) {
      print('App resumed, checking verification status...');
      _checkIfAlreadyVerified();
    }
  }

  Future<void> _checkIfAlreadyVerified() async {
    try {
      // Reload user and get the refreshed instance
      final refreshedUser = await _authService.reloadUser();
      print('Checking verification status: ${refreshedUser?.emailVerified}');

      if (refreshedUser != null && refreshedUser.emailVerified) {
        // Sync verification status to Firestore
        await _authService.syncEmailVerificationStatus();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email already verified! Redirecting...'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else if (refreshedUser == null) {
        // User is not authenticated, prompt them to login
        print('User not authenticated during verification check');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: AppColors.caution,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
      // Ignore errors on initial check
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleResendEmail() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resendVerificationEmail();
      await _authService.logSecurityEvent(
        type: SecurityEventType.verificationSuccess,
        description: 'Verification email resent',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent successfully! Please check your inbox and spam folder.'),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() {
          _remainingSeconds = 5; // 5 seconds (temporary for testing)
          _canResend = false;
        });
        _startTimer();
      }
    } catch (e) {
      await _authService.logSecurityEvent(
        type: SecurityEventType.verificationFailed,
        description: 'Failed to resend verification email',
        metadata: {'error': e.toString()},
      );
      if (mounted) {
        // If user is not authenticated, prompt them to login again
        if (e.toString().contains('No authenticated user')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session expired. Please login again to resend verification email.'),
              backgroundColor: AppColors.caution,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Login',
                textColor: AppColors.onPrimary,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send email: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCheckVerification() async {
    setState(() => _isLoading = true);

    try {
      // Reload user and get the freshly refreshed instance
      final refreshedUser = await _authService.reloadUser();
      print('Manual verification check: ${refreshedUser?.emailVerified}');

      if (refreshedUser != null && refreshedUser.emailVerified) {
        // Sync verification status to Firestore
        await _authService.syncEmailVerificationStatus();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: AppColors.secondary,
            ),
          );
          // Navigate to main screen instead of pop
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else if (refreshedUser == null) {
        // User is not authenticated, prompt them to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: AppColors.caution,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
              backgroundColor: AppColors.caution,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during verification check: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification status: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spaceXl * 2),
              _buildHeader(),
              const SizedBox(height: AppSpacing.spaceXl * 2),
              _buildEmailDisplay(),
              const SizedBox(height: AppSpacing.spaceXl),
              _buildTimerDisplay(),
              const SizedBox(height: AppSpacing.spaceXl),
              _buildResendButton(),
              const SizedBox(height: AppSpacing.spaceMd),
              _buildCheckButton(),
              const SizedBox(height: AppSpacing.spaceMd),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        Text(
          'Verify Your Email',
          style: AppTextStyles.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Text(
          'We\'ve sent a verification link to your email address. Please verify your account to continue.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Text(
          'Check your inbox and spam folder',
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: Column(
        children: [
          Text(
            'Email sent to:',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            widget.email,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Text(
          'Resend available in:',
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Text(
          _formatTime(_remainingSeconds),
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    return ElevatedButton(
      onPressed: (_canResend && !_isLoading) ? _handleResendEmail : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _canResend ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.3),
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : Text(
              'Resend Verification Email',
              style: AppTextStyles.bodyLg.copyWith(
                color: _canResend ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildCheckButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : _handleCheckVerification,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Text(
              'I\'ve Verified My Email',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () async {
        // Sign out user before going back to login
        await _authService.signOut();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Text(
        'Back to Login',
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
