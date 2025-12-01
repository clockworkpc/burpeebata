# Test Setup for BurpeeBata

## Current Test Status

The test suite currently requires Firebase/Firestore mocking to function properly after the implementation of cloud workout storage (Issue #28).

## Known Issues

### Firebase Not Initialized in Tests

Tests fail with:
```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
```

This occurs because:
1. `TimerScreen` now depends on `AuthProvider` (via Provider)
2. `_TimerScreenState` instantiates `WorkoutService` which accesses Firestore
3. `HistoryScreen` also accesses `WorkoutService` and `AuthProvider`
4. Tests don't initialize Firebase or mock Firestore

## Solutions

### Option 1: Add Firebase Mocking Packages

Add to `pubspec.yaml` dev dependencies:

```yaml
dev_dependencies:
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0
```

Then update tests to use mocks:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
  });

  // Use mocks in tests...
}
```

### Option 2: Mock Firebase in Test Setup

Create a test helper file `test/helpers/firebase_test_helper.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return {
        'name': '[DEFAULT]',
        'options': {
          'apiKey': 'test-api-key',
          'appId': 'test-app-id',
          'messagingSenderId': 'test-sender-id',
          'projectId': 'test-project-id',
        },
        'pluginConstants': {},
      };
    }
    return null;
  });

  // Mock Firestore
  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return null; // Return appropriate mock data
  });

  // Mock Firebase Auth
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Auth#authStateChanges') {
      return Stream.value(null); // No user logged in
    }
    return null;
  });
}
```

Then use in tests:

```dart
import 'helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseMocks();
  });

  // Tests...
}
```

### Option 3: Dependency Injection

Refactor services to use dependency injection, allowing tests to inject mock services:

```dart
class _TimerScreenState extends State<TimerScreen> {
  final WorkoutService workoutService;

  _TimerScreenState({WorkoutService? workoutService})
      : workoutService = workoutService ?? WorkoutService();

  // ...
}
```

Then in tests:

```dart
class MockWorkoutService extends Mock implements WorkoutService {}

testWidgets('test', (tester) async {
  final mockService = MockWorkoutService();
  await tester.pumpWidget(
    MaterialApp(
      home: TimerScreen(
        config: config,
        workoutService: mockService,
      ),
    ),
  );
});
```

## Affected Tests

The following test files are affected:
- `test/widget_test.dart` - Main app test
- `test/screens/timer_screen_test.dart` - Timer screen tests
- `test/screens/history_screen_test.dart` - History screen tests (if exists)
- Any integration tests that use these screens

## Running Tests

Until Firebase mocking is implemented:

```bash
# Run only non-Firebase dependent tests
make test test/models/
make test test/services/storage_service_test.dart

# Skip Firebase-dependent tests
docker compose exec flutter flutter test --exclude-tags=firebase
```

## Recommended Approach

**Short term**: Use Option 2 (Mock Firebase in Test Setup) as it doesn't require new dependencies and works with the existing test structure.

**Long term**: Consider Option 3 (Dependency Injection) for better testability and cleaner architecture.

## Test Coverage Before Issue #28

Before cloud workout storage implementation, tests could run without Firebase because:
- `TimerScreen` didn't depend on `AuthProvider`
- Workouts were only saved to `StorageService` (SharedPreferences)
- No Firestore access was needed

## Test Coverage After Issue #28

After cloud workout storage implementation:
- All screens using `AuthProvider` need Firebase mocked
- `WorkoutService` accesses Firestore and needs mocking
- Tests need to handle both authenticated and anonymous user states

## Example: Fixing timer_screen_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:burpeebata/screens/timer_screen.dart';
import 'package:burpeebata/models/workout_config.dart';
import 'package:burpeebata/providers/auth_provider.dart';

// Mock AuthProvider that doesn't initialize Firebase
class MockAuthProvider with ChangeNotifier implements AuthProvider {
  @override
  User? get user => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isAnonymous => true;

  @override
  UserProfile? get userProfile => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  // Stub out all methods
  @override
  Future<bool> signIn(String email, String password) async => false;

  @override
  Future<bool> signUp(String email, String password) async => false;

  @override
  Future<bool> signInAnonymously() async => false;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> updateProfile(UserProfile profile) async => false;

  @override
  Future<bool> sendPasswordResetEmail(String email) async => false;

  @override
  Future<bool> convertAnonymousAccount(String email, String password) async => false;

  @override
  Future<bool> deleteAccount() async => false;

  @override
  void clearError() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock WakelockPlus
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (MethodCall methodCall) async => true,
    );

    // Mock SharedPreferences
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    // Mock Firestore (simplified - returns empty for all queries)
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/cloud_firestore'),
      (MethodCall methodCall) async => null,
    );
  });

  Widget createTestWidget(WorkoutConfig config) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => MockAuthProvider(),
      child: MaterialApp(
        home: TimerScreen(config: config),
      ),
    );
  }

  group('TimerScreen', () {
    testWidgets('renders without error', (tester) async {
      const config = WorkoutConfig(
        repsPerSet: 5,
        secondsPerSet: 20,
        numberOfSets: 3,
      );

      await tester.pumpWidget(createTestWidget(config));
      await tester.pump();

      expect(find.byType(TimerScreen), findsOneWidget);
    });
  });
}
```

## Next Steps

1. Choose and implement one of the three options above
2. Create a shared test helper module
3. Update all affected tests
4. Document the testing approach in this file
5. Add CI/CD configuration that properly sets up test environment
