import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../vault/vault_service.dart';
import '../../vault/models/vault.dart';
import 'components/web_item_form_header.dart';
import 'components/web_item_form_fields.dart';
import 'components/web_item_form_footer.dart';

/// Desktop/Web Add/Edit Item Screen with slide-over drawer layout
/// Animates from right side (width: 480px) over the underlying dashboard
class WebAddItemScreen extends StatefulWidget {
  final Vault? vaultToEdit;

  const WebAddItemScreen({super.key, this.vaultToEdit});

  @override
  State<WebAddItemScreen> createState() => _WebAddItemScreenState();
}

class _WebAddItemScreenState extends State<WebAddItemScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final VaultService _vaultService = VaultService();

  final _serviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _iconController = TextEditingController();

  bool _isFavorite = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmojiPicker = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

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
    _animationController.dispose();
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
        await _vaultService.updateVault(
          vaultId: widget.vaultToEdit!.vaultId,
          service: _serviceController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
          isFavorite: _isFavorite,
        );
      } else {
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
        _handleClose();
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

  void _handleClose() {
    _animationController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  bool _isFormDirty() {
    return _serviceController.text.isNotEmpty ||
           _usernameController.text.isNotEmpty ||
           _passwordController.text.isNotEmpty ||
           _iconController.text.isNotEmpty;
  }

  bool _handleEscapeKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isFormDirty()) {
        _showCloseConfirmation();
      } else {
        _handleClose();
      }
      return true;
    }
    return false;
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to close?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleClose();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: _isFormDirty() ? _showCloseConfirmation : _handleClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          // Slide-over drawer
          Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (_handleEscapeKey(event)) {
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 480,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      WebItemFormHeader(
                        vaultToEdit: widget.vaultToEdit,
                        onClose: _handleClose,
                      ),
                      // Form content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                WebItemFormFields(
                                  serviceController: _serviceController,
                                  usernameController: _usernameController,
                                  passwordController: _passwordController,
                                  iconController: _iconController,
                                  obscurePassword: _obscurePassword,
                                  showEmojiPicker: _showEmojiPicker,
                                  isFavorite: _isFavorite,
                                  onTogglePasswordVisibility: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                  onGeneratePassword: () {
                                    final generatedPassword = _generatePassword();
                                    setState(() {
                                      _passwordController.text = generatedPassword;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Password generated!'),
                                        backgroundColor: theme.colorScheme.secondary,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  onToggleEmojiPicker: () {
                                    setState(() => _showEmojiPicker = !_showEmojiPicker);
                                  },
                                  onEmojiSelected: (emoji) {
                                    setState(() {
                                      _iconController.text = emoji;
                                      _showEmojiPicker = false;
                                    });
                                  },
                                  onFavoriteChanged: (value) {
                                    setState(() => _isFavorite = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Footer
                      WebItemFormFooter(
                        isLoading: _isLoading,
                        onCancel: _isFormDirty() ? _showCloseConfirmation : _handleClose,
                        onSave: _isLoading ? null : _handleSave,
                        vaultToEdit: widget.vaultToEdit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
