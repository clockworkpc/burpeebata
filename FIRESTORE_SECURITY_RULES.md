# Firestore Security Rules

This document describes the Firestore security rules required for the BurpeeBata application.

## Required Security Rules

Add these rules to your Firebase project's Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User profiles - users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Workouts subcollection - users can only access their own workouts
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## How to Apply These Rules

### Via Firebase Console

1. Go to the [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database** in the left sidebar
4. Click on the **Rules** tab
5. Replace the existing rules with the rules above
6. Click **Publish**

### Via Firebase CLI

If you have the Firebase CLI installed and initialized in your project:

```bash
# Edit the firestore.rules file in your project root
# Then deploy:
firebase deploy --only firestore:rules
```

## What These Rules Do

### User Profiles (`/users/{userId}`)
- **Read/Write**: Only the authenticated user with matching `userId` can access their profile
- Prevents users from viewing or modifying other users' profiles
- Anonymous users can still create and access their own profile

### Workouts Subcollection (`/users/{userId}/workouts/{workoutId}`)
- **Read/Write**: Only the authenticated user with matching `userId` can access their workouts
- Workouts are stored as a subcollection under each user document
- Each workout is isolated to its owner
- Anonymous users can access their own workouts during their session

## Data Structure

The security rules assume this Firestore structure:

```
/users/{userId}
  - name: string (optional)
  - age: number (optional)
  - sex: string (optional)
  - heightCm: number (optional)
  - weightKg: number (optional)
  - createdAt: timestamp
  - updatedAt: timestamp

  /workouts/{workoutId}
    - id: string
    - date: timestamp
    - burpeeType: number
    - repsPerSet: number
    - secondsPerSet: number
    - numberOfSets: number
    - restBetweenSets: number
    - completed: boolean
    - completedSets: number
```

## Testing the Rules

You can test these rules in the Firebase Console:

1. Go to **Firestore Database** > **Rules**
2. Click on **Rules Playground** tab
3. Test scenarios:
   - **Authenticated user reading own data**: Should succeed
   - **Authenticated user reading another user's data**: Should fail
   - **Unauthenticated request**: Should fail

## Important Notes

- These rules require users to be authenticated (including anonymous auth)
- Guest users using anonymous authentication can access their own data
- When a user deletes their account, you should also delete their subcollections
- Consider adding server-side functions to clean up user data on account deletion

## Additional Security Considerations

For production deployments, consider:

1. **Field Validation**: Add rules to validate field types and required fields
2. **Rate Limiting**: Implement Cloud Functions to prevent abuse
3. **Data Validation**: Ensure workout data is within reasonable bounds
4. **Audit Logging**: Enable Firebase audit logs for compliance

Example with field validation:

```javascript
match /users/{userId}/workouts/{workoutId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null
    && request.auth.uid == userId
    && request.resource.data.keys().hasAll(['id', 'date', 'burpeeType', 'repsPerSet', 'completed'])
    && request.resource.data.repsPerSet is int
    && request.resource.data.repsPerSet > 0
    && request.resource.data.repsPerSet <= 100;
}
```
