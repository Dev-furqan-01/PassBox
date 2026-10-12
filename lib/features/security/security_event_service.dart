import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/security_event.dart';

class SecurityEventService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> logEvent({
    required SecurityEventType type,
    String? description,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final eventRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .doc();

      final event = SecurityEvent(
        eventId: eventRef.id,
        type: type,
        description: description,
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      await eventRef.set(event.toMap());
      return eventRef.id;
    } catch (e) {
      throw Exception('Failed to log security event: $e');
    }
  }

  Future<SecurityEvent?> getEvent(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .doc(eventId)
          .get();

      if (doc.exists) {
        return SecurityEvent.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get security event: $e');
    }
  }

  Future<List<SecurityEvent>> getAllEvents({
    int limit = 50,
    SecurityEventType? type,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => SecurityEvent.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get security events: $e');
    }
  }

  Stream<List<SecurityEvent>> watchEvents({
    int limit = 50,
    SecurityEventType? type,
  }) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('valut')
        .doc('user')
        .collection(userId)
        .doc('security_events')
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SecurityEvent.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<List<SecurityEvent>> getEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .where('createdAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('createdAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SecurityEvent.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by date range: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete security event: $e');
    }
  }

  Future<void> deleteOldEvents({DateTime? beforeDate}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final cutoffDate = beforeDate ?? DateTime.now().subtract(const Duration(days: 90));

      final snapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('security_events')
          .collection('events')
          .where('createdAt', isLessThan: cutoffDate.millisecondsSinceEpoch)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete old security events: $e');
    }
  }
}
