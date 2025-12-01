# App Store Reviewer Access

This document provides instructions for Google Play and Apple App Store reviewers to access BurpeeBata.

## For App Store Submission

Include the following information in your app store submission notes:

---

## Reviewer Access Instructions

BurpeeBata provides **two methods** for reviewers to access the application:

### Method 1: Guest Access (Recommended)

**No credentials required!**

1. Launch the app
2. On the login screen, tap **"Continue as Guest"**
3. You will be signed in anonymously with immediate access to all features

**Why this method is recommended:**
- No credentials to manage
- Instant access
- Full feature access
- No account setup required

### Method 2: Demo Account (Alternative)

If you prefer to test with a persistent account:

**Demo Account Credentials:**
- **Email:** `reviewer@burpeebata.com`
- **Password:** `Reviewer2025!`

This account has pre-configured data and demonstrates the full user experience.

---

## What Reviewers Can Access

Both guest and demo accounts provide access to:

1. **Timer Functionality**
   - Configure workout parameters (sets, reps, rest periods)
   - Start and complete burpee workouts
   - Use audio cues during workouts

2. **Workout History**
   - View completed workouts (demo account has sample data)
   - Share workout summaries

3. **Profile Settings** (Demo account only)
   - View and edit optional profile information
   - Name, age, sex, height, weight (all optional fields)

4. **Saved Workouts**
   - Create custom workout templates
   - Load and modify saved configurations

## Features Overview

### Authentication System

- **Email/Password Sign-Up/Login**: Users can create accounts
- **Guest Mode**: Anonymous authentication for quick access
- **Optional Profile**: Users can optionally add personal information

### Profile Attributes (All Optional)

- Name
- Age
- Sex (Male/Female, defaults to Male)
- Height (cm)
- Weight (kg)

**Note:** Creating a profile is completely optional. Users can use the app without providing any personal information.

### Data Storage

- User profiles stored in Firebase Firestore
- Workout history persisted locally and in cloud (for authenticated users)
- Secure, user-specific data access via Firebase security rules

## Technical Details

### Backend

- **Service**: Firebase (Google Cloud)
- **Authentication**: Firebase Auth
  - Email/Password provider enabled
  - Anonymous provider enabled for guest access
- **Database**: Cloud Firestore
  - User profiles collection
  - Row-level security enforced

### Platform Support

- Android (Google Play)
- iOS (App Store)
- Web (burpeebata.com)

All platforms share the same authentication and data storage backend.

## Privacy & Security

- Guest accounts are anonymous and temporary
- Demo account contains only sample data
- All user data is encrypted in transit and at rest
- Firebase security rules prevent unauthorized access
- Users can delete their accounts and data at any time

## Support Contact

For reviewer questions or issues:
- **GitHub Issues**: https://github.com/garber-squared/burpeebata/issues
- **Email**: [Your contact email]

---

## Quick Start for Reviewers

1. **Open the app**
2. **Tap "Continue as Guest"** on the login screen
3. **Tap "START WORKOUT"** to test the core functionality
4. **Explore the menu** (account icon in top-right) to test profile features

That's it! No setup or credentials needed.
