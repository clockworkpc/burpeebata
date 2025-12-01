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

## Linting

Uses `flutter_lints` package. Run analysis with:
```bash
docker compose exec flutter flutter analyze
```
