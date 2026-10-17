import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/core.dart';
import 'auth_service.dart';
import 'signup_screen_responsive.dart';
import 'verification_screen.dart';
import 'forgot_password_screen.dart';
import 'forgot_password_screen_responsive.dart';
import 'auth_web_shell.dart';
import 'login_screen.dart';
import '../settings/services/biometric_service.dart';
import '../settings/services/credential_storage_service.dart';

/// Responsive wrapper for Login Screen
/// Uses split-screen layout on desktop/tablet, falls back to mobile layout on small screens
class ResponsiveLoginScreen extends StatefulWidget {
  const ResponsiveLoginScreen({super.key});

  @override
  State<ResponsiveLoginScreen> createState() => _ResponsiveLoginScreenState();
}

class _ResponsiveLoginScreenState extends State<ResponsiveLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _biometricService = BiometricService();
  final _credentialStorage = CredentialStorageService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showBiometricButton = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isDeviceSupported();
    final isEnrolled = await _biometricService.areBiometricsEnrolled();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final hasCredentials = await _credentialStorage.hasCredentials();

    // Biometric only available on mobile, not web
    if (isAvailable && isEnrolled && isEnabled && !kIsWeb) {
      setState(() {
        _showBiometricButton = true;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access your vault',
      );

      if (authenticated) {
        final credentials = await _credentialStorage.getCredentials();

        if (credentials == null) {
          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No saved credentials found. Please login with email and password first.'),
                backgroundColor: theme.colorScheme.tertiary,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        final email = credentials['email']!;
        final password = credentials['password']!;

        setState(() => _isLoading = true);

        try {
          await _authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final refreshedUser = await _authService.reloadUser();

          if (refreshedUser == null || !refreshedUser.emailVerified) {
            if (mounted) {
              final theme = Theme.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please verify your email first before logging in.'),
                  backgroundColor: theme.colorScheme.tertiary,
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VerificationScreen(
                    email: email,
                  ),
                ),
              );
            }
            return;
          }

          await _authService.syncEmailVerificationStatus();

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric login successful!'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
            Navigator.pushReplacementNamed(context, '/main');
          }
        } catch (e) {
          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed: ${e.toString()}'),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final refreshedUser = await _authService.reloadUser();

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please verify your email first before logging in.'),
              backgroundColor: theme.colorScheme.tertiary,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
        return;
      }

      await _authService.syncEmailVerificationStatus();

      await _credentialStorage.saveCredentials(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: theme.colorScheme.secondary,
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: theme.colorScheme.error,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop/Tablet breakpoint: 768px
        if (constraints.maxWidth >= 768) {
          return _buildDesktopLayout(context);
        } else {
          // Fall back to original mobile layout
          return LoginScreen();
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return AuthWebShell(
      child: _buildLoginForm(context),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
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
          Text(
            'Welcome Back',
            style: AppTextStyles.headlineLg.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your secure vault',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Email field
          _buildWebEmailField(context),
          const SizedBox(height: 16),
          // Password field
          _buildWebPasswordField(context),
          const SizedBox(height: 12),
          // Forgot password
          _buildWebForgotPassword(context),
          const SizedBox(height: 24),
          // Login button
          _buildWebLoginButton(context),
          const SizedBox(height: 16),
          // Signup link
          _buildWebSignupLink(context),
        ],
      ),
    );
  }

  Widget _buildWebEmailField(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        _emailFocusNode.unfocus();
        _passwordFocusNode.requestFocus();
      },
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

  Widget _buildWebPasswordField(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
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
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildWebForgotPassword(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResponsiveForgotPasswordScreen(),
              ),
            );
          },
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLoginButton(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
                'Sign In',
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildWebSignupLink(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResponsiveSignupScreen()),
              );
            },
            child: Text(
              'Sign Up',
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
}
