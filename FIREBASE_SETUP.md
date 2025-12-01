# Firebase Setup Guide

This document explains how to configure Firebase for BurpeeBata across all platforms (Android, iOS, and Web).

## Prerequisites

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name your project (e.g., "BurpeeBata")
4. Follow the setup wizard (Google Analytics optional)

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the following sign-in providers:
   - **Email/Password**: Enable this
   - **Anonymous**: Enable this (for guest access and app store reviewers)

## Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **production mode**
4. Choose a location close to your users
5. After creation, update the security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Add additional rules for workout data if needed
  }
}
```

## Step 4: Configure Firebase for Flutter

Run the FlutterFire CLI from the project root:

```bash
flutterfire configure
```

This will:
1. Ask you to select your Firebase project
2. Select platforms: **Android**, **iOS**, **Web**
3. Generate `lib/firebase_options.dart` with configuration for all platforms
4. Update platform-specific configuration files

## Step 5: Platform-Specific Configuration

### Android

The `flutterfire configure` command should have updated:
- `android/app/build.gradle`
- `android/app/google-services.json`

Verify `android/app/build.gradle` has:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}

apply plugin: 'com.google.gms.google-services'
```

### iOS

The command should have updated:
- `ios/Runner/GoogleService-Info.plist`

No additional configuration needed.

### Web

The command should have updated:
- `web/index.html`

Verify Firebase SDKs are included in `web/index.html`.

## Step 6: Create Demo Account for App Store Reviewers

### For Google Play and App Store Review:

Create a demo account that reviewers can use:

```bash
# You can create this through Firebase Console > Authentication > Users
# Or programmatically after the app is running
```

**Demo Account Credentials:**
- Email: `reviewer@burpeebata.com`
- Password: `Reviewer2025!`

**Important:**
- Document these credentials in your app store submissions
- Alternatively, users can click "Continue as Guest" for anonymous access
- The guest/anonymous feature is perfect for reviewers

### Setting Up the Demo Account:

1. **Option 1: Use Anonymous Sign-In (Recommended for Reviewers)**
   - No credentials needed
   - Click "Continue as Guest" on login screen
   - Reviewers get immediate access

2. **Option 2: Create Email/Password Account**
   - Go to Firebase Console > Authentication > Users
   - Click "Add user"
   - Email: `reviewer@burpeebata.com`
   - Password: `Reviewer2025!`
   - Optionally pre-populate with sample workout data

## Step 7: Install Dependencies

From the project root:

```bash
make up
docker compose exec flutter flutter pub get
```

## Step 8: Run the App

```bash
# Development mode
make up

# Access the app
# - Web: http://localhost:8080
# - Android: Connected device or emulator
# - iOS: Connected device or simulator
```

## Troubleshooting

### "firebase_options.dart not found"

Run `flutterfire configure` again to regenerate the file.

### Authentication errors

1. Check that Email/Password and Anonymous auth are enabled in Firebase Console
2. Verify Firestore security rules allow authenticated users to read/write their profiles

### Platform-specific issues

**Android:**
- Ensure `google-services.json` is in `android/app/`
- Check that Google Services plugin is applied in `build.gradle`

**iOS:**
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Run `pod install` in the `ios/` directory if needed

**Web:**
- Check browser console for Firebase initialization errors
- Verify Firebase SDKs are loaded in `web/index.html`

## Cost Estimate

Firebase free tier includes:
- **Authentication**: 50,000 MAU (Monthly Active Users)
- **Firestore**:
  - 50,000 reads/day
  - 20,000 writes/day
  - 1 GB storage

**Expected costs for small app (< 10,000 users):** $0-5/month

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment-specific projects** (dev, staging, prod)
3. **Review Firestore security rules** regularly
4. **Enable App Check** for production (optional but recommended)
5. **Monitor Firebase usage** in the console to avoid unexpected costs

## Support

For issues with Firebase setup:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)


```
✔ Select a Firebase project to configure your Flutter application with · burpeebata (BurpeeBata)
✔ Which platforms should your configuration support (use arrow keys & space to select)? · android, ios, macos, web, windows
i Firebase android app com.burpeebata.app is not registered on Firebase project burpeebata.
i Registered a new Firebase android app on Firebase project burpeebata.
i Firebase ios app com.burpeebata.app is not registered on Firebase project burpeebata.
i Registered a new Firebase ios app on Firebase project burpeebata.
i Firebase macos app com.burpeebata.app registered.
i Firebase web app burpeebata (web) is not registered on Firebase project burpeebata.
i Registered a new Firebase web app on Firebase project burpeebata.
i Firebase windows app burpeebata (windows) is not registered on Firebase project burpeebata.
i Registered a new Firebase windows app on Firebase project burpeebata.

Firebase configuration file lib/firebase_options.dart generated successfully with the following Firebase apps:

Platform  Firebase App Id
web       1:726464864566:web:3f67cb2b748b5317931397
android   1:726464864566:android:f777fb2d6415c8ee931397
ios       1:726464864566:ios:26d1a256e93a3b67931397
macos     1:726464864566:ios:26d1a256e93a3b67931397
windows   1:726464864566:web:a97dae8ad628b8e6931397

Learn more about using this file and next steps from the documentation:
 > https://firebase.google.com/docs/flutter/setup

```
