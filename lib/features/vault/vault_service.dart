import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/vault.dart';
import 'utils/password_analyzer.dart';

class VaultService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> createVault({
    required String service,
    required String username,
    required String password,
    String? icon,
    bool isFavorite = false,
    bool isSecure = true,
    required String category,
    int version = 1,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Analyze password
      final passwordStrength = PasswordAnalyzer.calculateStrength(password);
      final passwordHash = PasswordAnalyzer.generatePasswordHash(password);

      // Check for password reuse
      final allVaults = await getAllVaults();
      final isPasswordReused = allVaults.any((vault) => vault.passwordHash == passwordHash);

      final vaultRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('vaults')
          .collection('items')
          .doc();

      final vault = Vault(
        vaultId: vaultRef.id,
        service: service,
        username: username,
        password: password,
        icon: icon,
        isFavorite: isFavorite,
        isSecure: isSecure,
        category: category,
        lastUpdated: DateTime.now(),
        version: version,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        passwordStrength: passwordStrength,
        isPasswordReused: isPasswordReused,
        passwordHash: passwordHash,
      );

      await vaultRef.set(vault.toMap());

      // Update other vaults with same password to mark them as reused
      if (isPasswordReused) {
        await _markPasswordAsReused(passwordHash);
      }

      return vaultRef.id;
    } catch (e) {
      throw Exception('Failed to create vault: $e');
    }
  }

  Future<Vault?> getVault(String vaultId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('vaults')
          .collection('items')
          .doc(vaultId)
          .get();

      if (doc.exists) {
        return Vault.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vault: $e');
    }
  }

  Future<List<Vault>> getAllVaults() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('vaults')
          .collection('items')
          .get();

      return snapshot.docs
          .map((doc) => Vault.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vaults: $e');
    }
  }

  Stream<List<Vault>> watchVaults() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('valut')
        .doc('user')
        .collection(userId)
        .doc('vaults')
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vault.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateVault({
    required String vaultId,
    String? service,
    String? username,
    String? password,
    String? icon,
    bool? isFavorite,
    bool? isSecure,
    String? category,
    int? version,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final vaultRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('vaults')
          .collection('items')
          .doc(vaultId);

      final updateData = <String, dynamic>{
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (service != null) updateData['service'] = service;
      if (username != null) updateData['username'] = username;
      if (icon != null) updateData['icon'] = icon;
      if (isFavorite != null) updateData['isFavorite'] = isFavorite;
      if (isSecure != null) updateData['isSecure'] = isSecure;
      if (category != null) updateData['category'] = category;
      if (version != null) updateData['version'] = version;

      // If password is being updated, recalculate strength and check reuse
      if (password != null) {
        final passwordStrength = PasswordAnalyzer.calculateStrength(password);
        final passwordHash = PasswordAnalyzer.generatePasswordHash(password);

        // Get current vault to check old password hash
        final currentVault = await getVault(vaultId);
        final oldPasswordHash = currentVault?.passwordHash;

        updateData['password'] = password;
        updateData['passwordStrength'] = passwordStrength;
        updateData['passwordHash'] = passwordHash;

        // Check for reuse
        final allVaults = await getAllVaults();
        final isPasswordReused = allVaults.any((vault) =>
            vault.passwordHash == passwordHash && vault.vaultId != vaultId);
        updateData['isPasswordReused'] = isPasswordReused;

        // Update reuse status for all vaults
        if (isPasswordReused) {
          await _markPasswordAsReused(passwordHash, excludeVaultId: vaultId);
        }

        // If old password was reused by others, update them
        if (oldPasswordHash != null) {
          await _updatePasswordReuseStatus(oldPasswordHash);
        }
      }

      await vaultRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update vault: $e');
    }
  }

  Future<void> deleteVault(String vaultId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get vault before deletion to check password reuse
      final vault = await getVault(vaultId);
      final passwordHash = vault?.passwordHash;

      await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('vaults')
          .collection('items')
          .doc(vaultId)
          .delete();

      // Update reuse status if password was reused
      if (passwordHash != null) {
        await _updatePasswordReuseStatus(passwordHash);
      }
    } catch (e) {
      throw Exception('Failed to delete vault: $e');
    }
  }

  Future<void> _markPasswordAsReused(String passwordHash, {String? excludeVaultId}) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final allVaults = await getAllVaults();
      final vaultsWithSamePassword = allVaults
          .where((vault) => vault.passwordHash == passwordHash)
          .toList();

      // Mark all vaults with this password as reused
      for (final vault in vaultsWithSamePassword) {
        if (excludeVaultId != null && vault.vaultId == excludeVaultId) continue;

        await _firestore
            .collection('valut')
            .doc('user')
            .collection(userId)
            .doc('vaults')
            .collection('items')
            .doc(vault.vaultId)
            .update({'isPasswordReused': true});
      }
    } catch (e) {
      print('Error marking password as reused: $e');
    }
  }

  Future<void> _updatePasswordReuseStatus(String passwordHash) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final allVaults = await getAllVaults();
      final vaultsWithSamePassword = allVaults
          .where((vault) => vault.passwordHash == passwordHash)
          .toList();

      // If only one vault has this password, mark it as not reused
      if (vaultsWithSamePassword.length == 1) {
        await _firestore
            .collection('valut')
            .doc('user')
            .collection(userId)
            .doc('vaults')
            .collection('items')
            .doc(vaultsWithSamePassword.first.vaultId)
            .update({'isPasswordReused': false});
      }
    } catch (e) {
      print('Error updating password reuse status: $e');
    }
  }

  Future<PasswordSecuritySummary> getPasswordSecuritySummary() async {
    try {
      final allVaults = await getAllVaults();

      int weakPasswords = 0;
      int reusedPasswords = 0;
      int totalItems = allVaults.length;

      final passwordHashes = <String>{};

      for (final vault in allVaults) {
        // Count weak passwords (strength < 40)
        if (vault.passwordStrength < 40) {
          weakPasswords++;
        }

        // Count reused passwords
        if (vault.passwordHash != null) {
          if (passwordHashes.contains(vault.passwordHash)) {
            reusedPasswords++;
          } else {
            passwordHashes.add(vault.passwordHash!);
          }
        }
      }

      // Calculate average strength
      int totalStrength = allVaults.fold(0, (sum, vault) => sum + vault.passwordStrength);
      int averageStrength = totalItems > 0 ? (totalStrength / totalItems).round() : 0;

      return PasswordSecuritySummary(
        totalItems: totalItems,
        weakPasswords: weakPasswords,
        reusedPasswords: reusedPasswords,
        averageStrength: averageStrength,
      );
    } catch (e) {
      throw Exception('Failed to get password security summary: $e');
    }
  }
}

class PasswordSecuritySummary {
  final int totalItems;
  final int weakPasswords;
  final int reusedPasswords;
  final int averageStrength;

  PasswordSecuritySummary({
    required this.totalItems,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.averageStrength,
  });
}