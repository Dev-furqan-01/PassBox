import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';
import '../security/models/security_event.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('valut').doc('user').collection(uid).doc('profile').get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserData(String uid, {String? name, bool? isEmailVerified}) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }

      if (isEmailVerified != null) {
        updateData['isEmailVerified'] = isEmailVerified;
      }

      if (updateData.isNotEmpty) {
        final docRef = _firestore.collection('valut').doc('user').collection(uid).doc('profile');
        final doc = await docRef.get();
        
        if (doc.exists) {
          await docRef.update(updateData);
        } else {
          // Create document if it doesn't exist
          final user = currentUser;
          await docRef.set({
            'uid': uid,
            'name': name ?? user?.displayName ?? 'User',
            'email': user?.email ?? '',
            'isEmailVerified': isEmailVerified ?? user?.emailVerified ?? false,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            ...updateData,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();

        await _firestore.collection('valut').doc('user').collection(user.uid).doc('profile').set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'isEmailVerified': false,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });

        await logSecurityEvent(
          type: SecurityEventType.verificationSuccess,
          description: 'User account created, verification email sent',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await logSecurityEvent(
        type: SecurityEventType.login,
        description: 'User logged in successfully',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      await logSecurityEvent(
        type: SecurityEventType.login,
        description: 'Failed login attempt',
        metadata: {'error': e.code},
      );
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await logSecurityEvent(
        type: SecurityEventType.logout,
        description: 'User logged out',
      );
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      await logSecurityEvent(
        type: SecurityEventType.passwordReset,
        description: 'Password reset email sent',
        metadata: {'email': email},
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<User?> reloadUser() async {
    try {
      await currentUser?.reload();
      // Return the freshly reloaded user
      return _auth.currentUser;
    } catch (e) {
      print('Failed to reload user: $e');
      throw Exception('Failed to reload user: $e');
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No authenticated user found. Please log in first.');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified. You can proceed to login.');
      }

      await user.sendEmailVerification();
      print('Verification email sent successfully to ${user.email}');
    } on FirebaseAuthException catch (e) {
      print('Firebase auth exception during resend: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please wait a few minutes before trying again.';
          break;
        case 'user-not-found':
          errorMessage = 'User not found. Please log in again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Failed to send verification email: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error during resend verification email: $e');
      throw Exception('Failed to resend verification email: $e');
    }
  }

  bool isEmailVerified() {
    return currentUser?.emailVerified ?? false;
  }

  Future<void> syncEmailVerificationStatus() async {
    try {
      final user = currentUser;
      if (user == null) return;

      final isVerified = user.emailVerified;
      await updateUserData(user.uid, isEmailVerified: isVerified);
    } catch (e) {
      print('Failed to sync email verification status: $e');
    }
  }

  Future<void> logSecurityEvent({
    required SecurityEventType type,
    String? description,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return;

      final eventRef = _firestore
          .collection('valut')
          .doc('user')
          .collection(user.uid)
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
    } catch (e) {
      // Don't throw for security logging errors to avoid disrupting main flow
      print('Failed to log security event: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'recaptcha-error':
        return 'reCAPTCHA verification failed. Please check your internet connection.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
