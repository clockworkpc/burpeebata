# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BurpeeBata is a Flutter application - a tabata timer specifically designed for burpee workouts. It targets mobile platforms (Android/iOS) and web.

## Development Commands

All commands run through Docker Compose via Makefile:

```bash
# Start development environment
make up

# Build and start
make up-build

# Run tests
make test

# Run a single test file
docker compose exec flutter flutter test test/path/to/test_file.dart

# Generate mocks (for mockito)
make mocks

# Build release APK
make apk

# View logs
make logs

# Check Flutter environment
make doctor
```

## Code Architecture

### Directory Structure
- `lib/` - Main application code
  - `main.dart` - App entry point with Firebase initialization and Provider setup
  - `screens/` - UI screens
    - Authentication: LoginScreen, SignupScreen, AuthWrapper
    - Main: HomeScreen, TimerScreen, HistoryScreen, ProfileScreen
    - Workouts: SavedWorkoutsScreen, WorkoutBuilderScreen
  - `models/` - Data models
    - Workout data: Workout, WorkoutConfig, BurpeeType, WorkoutTemplate
    - User data: UserProfile (with optional fields)
  - `services/` - Business logic
    - Workout: TimerService, StorageService, AudioService
    - User: AuthService (Firebase Auth), UserService (Firestore)
  - `providers/` - State management (Provider pattern)
    - AuthProvider - Authentication state and user profile
- `test/` - Test files mirror lib structure
- `assets/audio/` - Audio files for workout cues

### Key Dependencies

**Authentication & Data:**
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication (email/password, anonymous)
- `cloud_firestore` - User profile storage in cloud
- `provider` - State management for authentication

**Workout Features:**
- `shared_preferences` - Local storage for workout history
- `audioplayers` - Audio playback for timer cues
- `wakelock_plus` - Keep screen awake during workout
- `uuid` - Unique ID generation
- `share_plus` - Share workout results

**Development:**
- `mockito` + `build_runner` - Test mocking
- `flutter_lints` - Linting rules

## Testing

Uses Flutter's test framework with mockito for mocking. Mocks are generated in `*.mocks.dart` files.

To regenerate mocks after adding new mock annotations:
```bash
make mocks
```

## Authentication & User Profiles

BurpeeBata uses Firebase for authentication and user data storage.

### Authentication Methods
- **Email/Password** - Standard sign-up and login
- **Anonymous** - Guest access (perfect for app store reviewers)
- Users can convert anonymous accounts to permanent accounts

### User Profile (Optional)
All profile fields are optional:
- Name
- Age
- Sex (Male/Female, defaults to Male)
- Height (cm)
- Weight (kg)

### Firebase Setup
See `FIREBASE_SETUP.md` for complete configuration instructions.

### App Store Reviewer Access
See `APP_STORE_REVIEWER_ACCESS.md` for credentials and access instructions.

**Quick Access for Reviewers:**
- Tap "Continue as Guest" on login screen (no credentials needed)
- OR use demo account: `reviewer@burpeebata.com` / `Reviewer2025!`

## Workout Storage Architecture

### Current Implementation (Local Only)
**File**: `lib/services/storage_service.dart`

Workouts are currently stored in **SharedPreferences** (device-local only):
- **Key**: `'workouts'` - JSON-encoded list of completed/partial workouts
- **Key**: `'workout_templates'` - JSON-encoded list of saved templates
- **Limitation**: Data is per-device only, not synced across devices

**Operations:**
- `saveWorkout()` - Adds workout to local storage
- `getWorkouts()` - Retrieves all workouts (sorted newest first)
- `deleteWorkout()` - Removes specific workout
- `clearAllWorkouts()` - Wipes all workout history

### Workout Data Flow

**Workout Execution**: `lib/screens/timer_screen.dart`
1. User starts workout with `WorkoutConfig`
2. `TimerService` manages countdown and state
3. Completion triggers save via `_saveWorkout()`:
   - Normal completion → `completed: true`
   - Early end → `completed: false` with partial sets
   - Back navigation → Shows dialog, saves on confirm
4. Data saved to SharedPreferences only

**Workout Model**: `lib/models/workout.dart`
```dart
class Workout {
  final String id;              // UUID v4
  final DateTime date;
  final BurpeeType burpeeType;  // militarySixCount or navySeal
  final int repsPerSet;
  final int secondsPerSet;
  final int numberOfSets;
  final int restBetweenSets;
  final bool completed;         // true if all sets finished
  final int completedSets;      // actual sets completed

  // Calculated properties
  int get totalReps => repsPerSet * completedSets;
  String get shareText => // Formatted for sharing
}
```

**Workout Display**: `lib/screens/history_screen.dart`
- Loads from `StorageService.getWorkouts()`
- Shows: date, time, burpee type, sets, reps, completion status
- Actions: Share (via `share_plus`), Delete (with confirmation)

### Future: Cloud Storage (Not Yet Implemented)

To sync workouts to Firestore (following the UserService pattern):

**Proposed Structure**:
```
Firestore
└── users/{userId}
    ├── (user profile fields)
    └── workouts (subcollection)
        └── {workoutId}
            ├── date
            ├── burpeeType
            ├── repsPerSet
            ├── secondsPerSet
            ├── numberOfSets
            ├── restBetweenSets
            ├── completed
            └── completedSets
```

**Implementation would require**:
1. New `WorkoutService` (similar to `lib/services/user_service.dart`)
2. Firestore security rules to isolate user workouts
3. Modifications to `TimerScreen` to sync after local save
4. Modifications to `HistoryScreen` to load from Firestore when authenticated
5. Offline-first approach with local cache

## Linting

Uses `flutter_lints` package. Run analysis with:
```bash
docker compose exec flutter flutter analyze
```
