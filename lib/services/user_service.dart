import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Service for managing user profile data in Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Get a user profile by user ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      throw UserServiceException('Failed to get user profile: $e');
    }
  }

  /// Stream of user profile changes
  Stream<UserProfile?> userProfileStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserProfile.fromJson(doc.data()!);
    });
  }

  /// Create a new user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(profile.userId)
          .set(profile.toJson());
    } catch (e) {
      throw UserServiceException('Failed to create user profile: $e');
    }
  }

  /// Update an existing user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(profile.userId)
          .update(profile.toJson());
    } catch (e) {
      throw UserServiceException('Failed to update user profile: $e');
    }
  }

  /// Delete a user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      throw UserServiceException('Failed to delete user profile: $e');
    }
  }

  /// Check if a user profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw UserServiceException('Failed to check if profile exists: $e');
    }
  }

  /// Create or update a user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final exists = await profileExists(profile.userId);
      if (exists) {
        await updateUserProfile(profile);
      } else {
        await createUserProfile(profile);
      }
    } catch (e) {
      throw UserServiceException('Failed to save user profile: $e');
    }
  }
}

/// Custom exception for user service errors
class UserServiceException implements Exception {
  final String message;

  UserServiceException(this.message);

  @override
  String toString() => message;
}
