import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/device.dart';

class DeviceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> createDevice({
    required String name,
    required String platform,
    String? osVersion,
    String? appVersion,
    bool isTrusted = false,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final deviceRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .doc();

      final device = Device(
        deviceId: deviceRef.id,
        name: name,
        platform: platform,
        osVersion: osVersion,
        appVersion: appVersion,
        isTrusted: isTrusted,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await deviceRef.set(device.toMap());
      return deviceRef.id;
    } catch (e) {
      throw Exception('Failed to create device: $e');
    }
  }

  Future<Device?> getDevice(String deviceId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .doc(deviceId)
          .get();

      if (doc.exists) {
        return Device.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  Future<List<Device>> getAllDevices() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .get();

      return snapshot.docs
          .map((doc) => Device.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  Stream<List<Device>> watchDevices() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('valut')
        .doc('user')
        .collection(userId)
        .doc('devices')
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Device.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateDevice({
    required String deviceId,
    String? name,
    String? platform,
    String? osVersion,
    String? appVersion,
    bool? isTrusted,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final deviceRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .doc(deviceId);

      final updateData = <String, dynamic>{
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) updateData['name'] = name;
      if (platform != null) updateData['platform'] = platform;
      if (osVersion != null) updateData['osVersion'] = osVersion;
      if (appVersion != null) updateData['appVersion'] = appVersion;
      if (isTrusted != null) updateData['isTrusted'] = isTrusted;

      await deviceRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update device: $e');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .doc(deviceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete device: $e');
    }
  }

  Future<void> updateLastSeen(String deviceId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('devices')
          .collection('items')
          .doc(deviceId)
          .update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update last seen: $e');
    }
  }
}
