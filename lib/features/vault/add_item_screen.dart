import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../core/core.dart';
import '../vault/vault_service.dart';
import '../vault/models/vault.dart';
import '../auth/auth_service.dart';

class AddItemScreen extends StatefulWidget {
  final Vault? vaultToEdit;

  const AddItemScreen({super.key, this.vaultToEdit});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final VaultService _vaultService = VaultService();
  final AuthService _authService = AuthService();

  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _iconController = TextEditingController();

  bool _isFavorite = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    if (widget.vaultToEdit != null) {
      _serviceController.text = widget.vaultToEdit!.service;
      _usernameController.text = widget.vaultToEdit!.username;
      _passwordController.text = widget.vaultToEdit!.password;
      _iconController.text = widget.vaultToEdit!.icon ?? '';
      _isFavorite = widget.vaultToEdit!.isFavorite;
    }
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    String charset = uppercase + lowercase + numbers + symbols;
    final random = Random.secure();
    
    return List.generate(16, (index) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.vaultToEdit != null) {
        // Update existing vault
        await _vaultService.updateVault(
          vaultId: widget.vaultToEdit!.vaultId,
          service: _serviceController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
          isFavorite: _isFavorite,
        );
      } else {
        // Create new vault
        await _vaultService.createVault(
          service: _serviceController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
          isFavorite: _isFavorite,
          version: 1,
        );
      }

      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vaultToEdit != null ? 'Item updated successfully!' : 'Item added successfully!'),
            backgroundColor: theme.colorScheme.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vaultToEdit != null ? 'Failed to update item: $e' : 'Failed to add item: $e'),
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vaultToEdit != null ? 'Edit Item' : 'Add New Item',
          style: AppTextStyles.headlineMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spaceMd),
                // Lottie Animation
                Lottie.asset(
                  'assets/lottie/add item lock.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildServiceField(context),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildUsernameField(context),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildPasswordField(context),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildIconField(context),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildToggleOptions(context),
                const SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceField(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _serviceController,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Service Name',
        hintText: 'e.g., Google, GitHub, Netflix',
        prefixIcon: const Icon(Icons.business_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
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
          return 'Please enter service name';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _usernameController,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Username / Email',
        hintText: 'Enter your username or email',
        prefixIcon: const Icon(Icons.person_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
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
          return 'Please enter username or email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            IconButton(
              icon: const Icon(Icons.casino_outlined),
              onPressed: () {
                final generatedPassword = _generatePassword();
                setState(() {
                  _passwordController.text = generatedPassword;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password generated!'),
                    backgroundColor: theme.colorScheme.secondary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
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
          return 'Please enter password';
        }
        return null;
      },
    );
  }

  Widget _buildIconField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _iconController,
          style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Icon (Optional)',
            hintText: 'Tap emoji icon to select an emoji',
            prefixIcon: Text(
              _iconController.text.isNotEmpty ? _iconController.text : '🔒',
              style: const TextStyle(fontSize: 24),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                });
              },
            ),
            labelStyle: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            hintStyle: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
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
          readOnly: true,
          onTap: () {
            setState(() {
              _showEmojiPicker = !_showEmojiPicker;
            });
          },
        ),
        if (_showEmojiPicker) _buildEmojiPicker(context),
      ],
    );
  }

  Widget _buildEmojiPicker(BuildContext context) {
    final theme = Theme.of(context);
    final emojis = [
      '🔒', '🔐', '🔑', '🗝️', '🔓', '🔏', '🔎', '🔍',
      '💼', '🏢', '🏠', '🏦', '💳', '💰', '💸', '💎',
      '🌐', '📱', '💻', '⌨️', '🖥️', '📧', '📬', '📮',
      '🔴', '🟠', '🟡', '🟢', '🔵', '🟣', '⚫', '⚪',
      '😀', '😎', '🤔', '👍', '👎', '🔥', '⭐', '💡',
      '🚀', '✈️', '🚗', '🏃', '⚡', '🎯', '🎮', '🎨',
      '📚', '📝', '✏️', '📊', '📈', '🔧', '⚙️', '🛠️',
      '🌟', '💫', '✨', '🌈', '☀️', '🌙', '⭐', '🌍',
    ];

    return Container(
      height: 250,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppBorderRadius.defaultRadiusBorder,
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _iconController.text = emojis[index];
                _showEmojiPicker = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppBorderRadius.smRadius,
              ),
              child: Center(
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleOptions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Add to Favorites',
            style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text(
            'Show in pinned favorites section',
            style: AppTextStyles.bodySm.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          value: _isFavorite,
          onChanged: (bool value) {
            setState(() {
              _isFavorite = value;
            });
          },
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
