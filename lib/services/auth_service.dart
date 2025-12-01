import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing user authentication with Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Get the current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in anonymously (for guest/demo access)
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete the current user's account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Convert a user to a permanent account from anonymous
  Future<UserCredential> convertAnonymousAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await _auth.currentUser?.linkWithCredential(credential);
      if (userCredential == null) {
        throw AuthException('Failed to convert anonymous account');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase authentication exceptions
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AuthException('The password is too weak. Please use at least 6 characters.');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email.');
      case 'invalid-email':
        return AuthException('The email address is not valid.');
      case 'user-disabled':
        return AuthException('This account has been disabled.');
      case 'user-not-found':
        return AuthException('No account found with this email.');
      case 'wrong-password':
        return AuthException('Incorrect password.');
      case 'too-many-requests':
        return AuthException('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return AuthException('This sign-in method is not enabled.');
      case 'requires-recent-login':
        return AuthException('Please sign in again to perform this action.');
      default:
        return AuthException('Authentication failed: ${e.message ?? 'Unknown error'}');
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
