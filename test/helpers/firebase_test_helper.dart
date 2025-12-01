import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burpeebata/providers/auth_provider.dart';
import 'package:burpeebata/models/user_profile.dart';

/// Test helper for Firebase mocking
class FirebaseTestHelper {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockAuthProvider mockAuthProvider;

  FirebaseTestHelper() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: false);
    mockAuthProvider = MockAuthProvider();
  }

  /// Dispose of resources
  void dispose() {
    // Clean up if needed
  }
}

/// Mock AuthProvider for testing that doesn't initialize Firebase
class MockAuthProvider with ChangeNotifier implements AuthProvider {
  bool _isAuthenticated = false;
  bool _isAnonymous = true;

  @override
  firebase_auth.User? get user => null;

  @override
  UserProfile? get userProfile => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isAnonymous => _isAnonymous;

  void setAuthenticated(bool value, {bool anonymous = false}) {
    _isAuthenticated = value;
    _isAnonymous = anonymous;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return default values for all methods
    if (invocation.isMethod) {
      final returnType = invocation.memberName.toString();
      if (returnType.contains('Future')) {
        return Future.value(false);
      }
    }
    return super.noSuchMethod(invocation);
  }
}

/// Wrap a widget with necessary providers for testing
Widget wrapWithProviders(Widget child, {MockAuthProvider? authProvider}) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider ?? MockAuthProvider(),
    child: child,
  );
}
