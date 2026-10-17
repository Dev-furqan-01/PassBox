import 'package:flutter/material.dart';
import '../../core/core.dart';
import 'auth_service.dart';
import 'signup_screen_responsive.dart';
import 'verification_screen.dart';
import 'forgot_password_screen.dart';
import 'forgot_password_screen_responsive.dart';
import '../settings/services/biometric_service.dart';
import '../settings/services/credential_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _biometricService = BiometricService();
  final _credentialStorage = CredentialStorageService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showBiometricButton = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isDeviceSupported();
    final isEnrolled = await _biometricService.areBiometricsEnrolled();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final hasCredentials = await _credentialStorage.hasCredentials();

    print('Biometric Check - Available: $isAvailable, Enrolled: $isEnrolled, Enabled: $isEnabled, Has Credentials: $hasCredentials');

    // Show biometric button only if:
    // 1. Device supports biometrics
    // 2. User has enrolled biometrics
    // 3. Biometric unlock is enabled in settings
    if (isAvailable && isEnrolled && isEnabled) {
      setState(() {
        _showBiometricButton = true;
      });
      print('Biometric button will be shown');
    } else {
      print('Biometric button will NOT be shown');
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Authenticate to access your vault',
      );

      if (authenticated) {
        // Biometric authentication successful - retrieve saved credentials
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

        // Auto-fill credentials and sign in
        final email = credentials['email']!;
        final password = credentials['password']!;

        setState(() => _isLoading = true);

        try {
          await _authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Reload user to get latest verification status
          final refreshedUser = await _authService.reloadUser();
          print('Biometric login verification check: ${refreshedUser?.emailVerified}');

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
              // Don't sign out - keep user signed in so they can resend verification email
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

          // Sync verification status to Firestore
          await _authService.syncEmailVerificationStatus();

          if (mounted) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric login successful!'),
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
            // Navigate to main screen
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Reload user to get latest verification status
      final refreshedUser = await _authService.reloadUser();
      print('Login verification check: ${refreshedUser?.emailVerified}');

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
          // Don't sign out - keep user signed in so they can resend verification email
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

      // Sync verification status to Firestore
      await _authService.syncEmailVerificationStatus();

      // Save credentials securely for biometric login
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
        // Navigate to main screen
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spaceXl * 2),
                _buildHeader(),
                const SizedBox(height: AppSpacing.spaceXl * 2),
                _buildEmailField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildPasswordField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildForgotPassword(),
                const SizedBox(height: AppSpacing.spaceXl),
                _buildLoginButtonsRow(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildSignupLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.35; // 35% of screen width
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(logoSize * 0.1),
                child: Image.asset(
                  'assets/logo/app_logo_bg_remover.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXl),
        Text(
          'Welcome Back',
          style: AppTextStyles.headlineLg.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Text(
          'Sign in to access your secure vault',
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
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

  Widget _buildPasswordField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
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

  Widget _buildForgotPassword() {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
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
    );
  }

  Widget _buildLoginButton() {
    final theme = Theme.of(context);
    return ElevatedButton(
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
    );
  }

  Widget _buildLoginButtonsRow() {
    if (_showBiometricButton) {
      return Row(
        children: [
          Expanded(child: _buildLoginButton()),
          const SizedBox(width: AppSpacing.spaceMd),
          _buildBiometricButton(),
        ],
      );
    } else {
      return _buildLoginButton();
    }
  }

  Widget _buildBiometricButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleBiometricLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.defaultRadiusBorder,
          ),
          elevation: 0,
        ),
        child: const Icon(
          Icons.fingerprint,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
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
        GestureDetector(
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
      ],
    );
  }
}
