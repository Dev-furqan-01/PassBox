import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'auth_service.dart';
import 'auth_web_shell.dart';
import 'forgot_password_screen.dart';

/// Responsive wrapper for Forgot Password Screen
/// Uses split-screen layout on desktop/tablet, falls back to mobile layout on small screens
class ResponsiveForgotPasswordScreen extends StatefulWidget {
  const ResponsiveForgotPasswordScreen({super.key});

  @override
  State<ResponsiveForgotPasswordScreen> createState() => _ResponsiveForgotPasswordScreenState();
}

class _ResponsiveForgotPasswordScreenState extends State<ResponsiveForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();

  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });

        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: theme.colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop/Tablet breakpoint: 768px
        if (constraints.maxWidth >= 768) {
          return _buildDesktopLayout(context);
        } else {
          // Fall back to original mobile layout
          return const ForgotPasswordScreen();
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);

    return AuthWebShell(
      subtitle: 'Reset your password securely',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo for smaller screens
            if (MediaQuery.of(context).size.width < 1200) ...[
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/logo/app_logo_bg_remover.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            // Header
            if (!_emailSent) ...[
              Text(
                'Forgot Password?',
                style: AppTextStyles.headlineLg.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Email field
              _buildWebEmailField(context),
              const SizedBox(height: 24),
              // Reset button
              _buildWebResetButton(context),
              const SizedBox(height: 16),
              // Back to login link
              _buildWebBackToLoginLink(context),
            ] else ...[
              // Success message
              _buildWebSuccessMessage(context),
              const SizedBox(height: 24),
              // Back to login button
              _buildWebBackToLoginButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebEmailField(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleResetPassword(),
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
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
    );
  }

  Widget _buildWebResetButton(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                ),
              )
            : Text(
                'Send Reset Link',
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildWebBackToLoginLink(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Remember your password? ",
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSuccessMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: AppBorderRadius.defaultRadiusBorder,
        border: Border.all(color: theme.colorScheme.secondary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            'Email Sent!',
            style: AppTextStyles.headlineSm.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebBackToLoginButton(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
          elevation: 0,
        ),
        child: Text(
          'Back to Login',
          style: AppTextStyles.bodyLg.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
