import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialStorageService {
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _encryptionKey = 'valut_encryption_key_2024';

  /// Simple XOR encryption for basic security
  String _encrypt(String text) {
    final keyBytes = utf8.encode(_encryptionKey);
    final textBytes = utf8.encode(text);
    final encrypted = <int>[];

    for (int i = 0; i < textBytes.length; i++) {
      encrypted.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// Simple XOR decryption
  String _decrypt(String encryptedText) {
    final keyBytes = utf8.encode(_encryptionKey);
    final encrypted = base64.decode(encryptedText);
    final decrypted = <int>[];

    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  /// Save user credentials securely
  Future<void> saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, _encrypt(email));
      await prefs.setString(_passwordKey, _encrypt(password));
      print('Credentials saved securely');
    } catch (e) {
      print('Error saving credentials: $e');
      throw Exception('Failed to save credentials');
    }
  }

  /// Get saved credentials
  Future<Map<String, String?>?> getCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedEmail = prefs.getString(_emailKey);
      final encryptedPassword = prefs.getString(_passwordKey);

      if (encryptedEmail != null && encryptedPassword != null) {
        print('Credentials retrieved successfully');
        return {
          'email': _decrypt(encryptedEmail),
          'password': _decrypt(encryptedPassword),
        };
      }

      print('No credentials found');
      return null;
    } catch (e) {
      print('Error retrieving credentials: $e');
      return null;
    }
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
      print('Credentials cleared');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_emailKey);
      final password = prefs.getString(_passwordKey);
      return email != null && password != null;
    } catch (e) {
      print('Error checking credentials: $e');
      return false;
    }
  }
}
