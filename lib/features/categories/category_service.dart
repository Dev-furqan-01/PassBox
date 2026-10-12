import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/category.dart';

class CategoryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> createCategory({
    required String name,
    String? icon,
    String? color,
    int order = 0,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final categoryRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('categories')
          .collection('items')
          .doc();

      final category = Category(
        categoryId: categoryRef.id,
        name: name,
        icon: icon,
        color: color,
        order: order,
        createdAt: DateTime.now(),
      );

      await categoryRef.set(category.toMap());
      return categoryRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category?> getCategory(String categoryId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('categories')
          .collection('items')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return Category.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('categories')
          .collection('items')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Stream<List<Category>> watchCategories() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('valut')
        .doc('user')
        .collection(userId)
        .doc('categories')
        .collection('items')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? color,
    int? order,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final categoryRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('categories')
          .collection('items')
          .doc(categoryId);

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) updateData['name'] = name;
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color;
      if (order != null) updateData['order'] = order;

      await categoryRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('valut')
          .doc('user')
          .collection(userId)
          .doc('categories')
          .collection('items')
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
