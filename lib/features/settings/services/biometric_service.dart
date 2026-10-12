import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  // In-memory fallback for platforms where SharedPreferences might not work
  // Static so it persists across all instances of BiometricService
  static bool _inMemoryBiometricEnabled = false;

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometric support: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometrics are enrolled on the device
  Future<bool> areBiometricsEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Check if biometric unlock is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_biometricEnabledKey);
      print('Biometric enabled read from SharedPreferences: $enabled');

      if (enabled != null) {
        return enabled;
      }

      // Fallback to in-memory value
      print('Using in-memory biometric enabled: $_inMemoryBiometricEnabled');
      return _inMemoryBiometricEnabled;
    } catch (e) {
      print('Error checking biometric enabled: $e');
      // Fallback to in-memory value
      print('Using in-memory biometric enabled (fallback): $_inMemoryBiometricEnabled');
      return _inMemoryBiometricEnabled;
    }
  }

  /// Enable or disable biometric unlock
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      print('Biometric enabled saved to SharedPreferences: $enabled');

      // Verify it was saved
      final saved = prefs.getBool(_biometricEnabledKey);
      print('Biometric enabled verification: $saved');

      // Also update in-memory fallback
      _inMemoryBiometricEnabled = enabled;
      print('In-memory biometric enabled updated: $enabled');
    } catch (e) {
      print('Error setting biometric enabled: $e');
      // Still update in-memory fallback even if SharedPreferences fails
      _inMemoryBiometricEnabled = enabled;
      print('In-memory biometric enabled updated (fallback): $enabled');
      // Don't throw exception - the in-memory fallback is working
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access your vault',
  }) async {
    try {
      // Check if biometrics are available before attempting authentication
      final isAvailable = await isDeviceSupported();
      if (!isAvailable) {
        print('Biometric authentication not available on this device');
        throw Exception('Biometric authentication not available on this device');
      }

      final isEnrolled = await areBiometricsEnrolled();
      if (!isEnrolled) {
        print('No biometrics enrolled on this device');
        throw Exception('No biometrics enrolled. Please set up fingerprint or face unlock in your device settings.');
      }

      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      return result;
    } on PlatformException catch (e) {
      String errorMessage = 'Biometric authentication failed';
      switch (e.code) {
        case 'not_available':
          errorMessage = 'Biometric authentication not available on this device';
          break;
        case 'not_enrolled':
          errorMessage = 'No biometrics enrolled. Please set up fingerprint or face unlock in your device settings.';
          break;
        case 'locked_out':
          errorMessage = 'Too many attempts. Please use your device PIN/password to unlock.';
          break;
        case 'permanently_locked_out':
          errorMessage = 'Biometric authentication permanently locked. Please restart your device.';
          break;
        case 'other_operation_in_progress':
          errorMessage = 'Another authentication is in progress. Please wait.';
          break;
        case 'passcode_not_set':
          errorMessage = 'Please set up a device lock screen first.';
          break;
        case 'canceled':
          errorMessage = 'Authentication was canceled';
          break;
        case 'user_fallback':
          errorMessage = 'User chose to use device PIN/password';
          break;
        default:
          errorMessage = 'Biometric authentication error: ${e.message ?? e.code}';
      }
      print('Biometric authentication error: ${e.code} - ${e.message}');
      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected authentication error: $e');
      throw Exception('Authentication error: $e');
    }
  }

  /// Cancel any ongoing authentication
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('Error cancelling authentication: $e');
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometric';
      case BiometricType.weak:
        return 'Device Lock';
      default:
        return 'Biometric';
    }
  }

  /// Get description of available biometrics
  Future<String> getBiometricDescription() async {
    final availableBiometrics = await getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return 'No biometrics available';
    }

    final names = availableBiometrics.map(getBiometricTypeName).toList();
    if (names.length == 1) {
      return names.first;
    } else if (names.length == 2) {
      return '${names.first} or ${names.last}';
    } else {
      return '${names.join(", ")}';
    }
  }
}
