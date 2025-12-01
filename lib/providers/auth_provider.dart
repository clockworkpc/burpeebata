import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;

  AuthProvider() {
    _init();
  }

  /// Initialize authentication state listener
  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      _errorMessage = null;

      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }

      notifyListeners();
    });
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      _userProfile = await _userService.getUserProfile(userId);

      // If profile doesn't exist, create an empty one
      if (_userProfile == null) {
        _userProfile = UserProfile.empty(userId);
        await _userService.createUserProfile(_userProfile!);
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
    }
  }

  /// Sign up with email and password
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in anonymously (guest mode)
  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.saveUserProfile(profile);
      _userProfile = profile;
      _isLoading = false;
      notifyListeners();
      return true;
    } on UserServiceException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Convert anonymous account to permanent
  Future<bool> convertAnonymousAccount(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.convertAnonymousAccount(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_user != null) {
        await _userService.deleteUserProfile(_user!.uid);
        await _authService.deleteAccount();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
