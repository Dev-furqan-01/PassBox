import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/generate/models/password_config.dart';
import '../../features/auth/auth_service.dart';

class PasswordHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Save a password history entry to Firestore
  Future<void> savePasswordHistory(PasswordHistoryEntry entry) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        print('No authenticated user found. Password history not saved.');
        return;
      }

      final historyRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(user.uid)
          .doc('password_history')
          .collection('entries')
          .doc();

      await historyRef.set({
        'entryId': historyRef.id,
        'password': entry.password,
        'generatedAt': entry.generatedAt.millisecondsSinceEpoch,
        'entropy': entry.entropy,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only the last 50 entries
      await _cleanupOldHistory(user.uid);
    } catch (e) {
      print('Failed to save password history: $e');
    }
  }

  /// Load password history from Firestore
  Future<List<PasswordHistoryEntry>> loadPasswordHistory() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(user.uid)
          .doc('password_history')
          .collection('entries')
          .orderBy('generatedAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PasswordHistoryEntry(
          password: data['password'] as String,
          generatedAt: DateTime.fromMillisecondsSinceEpoch(data['generatedAt'] as int),
          entropy: data['entropy'] as int,
        );
      }).toList();
    } catch (e) {
      print('Failed to load password history: $e');
      return [];
    }
  }

  /// Clear all password history from Firestore
  Future<void> clearPasswordHistory() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return;
      }

      final collectionRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(user.uid)
          .doc('password_history')
          .collection('entries');

      final querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Failed to clear password history: $e');
    }
  }

  /// Delete old history entries (keep only the last 50)
  Future<void> _cleanupOldHistory(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(uid)
          .doc('password_history')
          .collection('entries')
          .orderBy('generatedAt', descending: true)
          .get();

      if (querySnapshot.docs.length > 50) {
        final docsToDelete = querySnapshot.docs.skip(50);
        for (var doc in docsToDelete) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Failed to cleanup old history: $e');
    }
  }
}
