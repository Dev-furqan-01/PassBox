import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/core.dart';
import '../categories/category_service.dart';
import '../categories/models/category.dart' as CategoryModel;
import '../vault/vault_service.dart';
import '../vault/models/vault.dart';
import '../auth/auth_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final VaultService _vaultService = VaultService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService();

  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _iconController = TextEditingController();

  String _selectedCategory = 'Other';
  bool _isFavorite = false;
  bool _isSecure = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmojiPicker = false;

  List<CategoryModel.Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first.name;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
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
      await _vaultService.createVault(
        service: _serviceController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
        isFavorite: _isFavorite,
        isSecure: _isSecure,
        category: _selectedCategory,
        version: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: AppColors.error,
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Item',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.primary,
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
                _buildServiceField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildUsernameField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildPasswordField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildIconField(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildCategoryDropdown(),
                const SizedBox(height: AppSpacing.spaceMd),
                _buildToggleOptions(),
                const SizedBox(height: AppSpacing.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceField() {
    return TextFormField(
      controller: _serviceController,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: 'Service Name',
        hintText: 'e.g., Google, GitHub, Netflix',
        prefixIcon: const Icon(Icons.business_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: 'Username / Email',
        hintText: 'Enter your username or email',
        prefixIcon: const Icon(Icons.person_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
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
                  const SnackBar(
                    content: Text('Password generated!'),
                    backgroundColor: AppColors.secondary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.defaultRadiusBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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

  Widget _buildIconField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _iconController,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
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
              color: AppColors.onSurfaceVariant,
            ),
            hintStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainer,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.defaultRadiusBorder,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.defaultRadiusBorder,
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          readOnly: true,
          onTap: () {
            setState(() {
              _showEmojiPicker = !_showEmojiPicker;
            });
          },
        ),
        if (_showEmojiPicker) _buildEmojiPicker(),
      ],
    );
  }

  Widget _buildEmojiPicker() {
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
        color: AppColors.surfaceContainer,
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
                color: AppColors.surface,
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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.folder_outlined),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: [
        'Other',
        ..._categories.map((cat) => cat.name),
      ].map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    );
  }

  Widget _buildToggleOptions() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Add to Favorites',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Show in pinned favorites section',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          value: _isFavorite,
          onChanged: (bool value) {
            setState(() {
              _isFavorite = value;
            });
          },
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: Text(
            'Secure Item',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Mark as sensitive information',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          value: _isSecure,
          onChanged: (bool value) {
            setState(() {
              _isSecure = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
