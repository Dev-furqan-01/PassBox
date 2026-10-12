# Firebase Setup Guide

This guide will help you set up Firebase for the Valut Password Manager app.

## Current Status

✅ Firebase is already configured with your project:
- **Project ID**: vaults-8c948
- **API Key**: AIzaSyC8Rly_fMiKBo1xMxW7j1cnTt7g-MCbnc4
- **google-services.json**: Already present in `android/app/`
- **firebase_options.dart**: Already configured

## Remaining Steps

### Step 1: Enable Authentication

1. Go to Firebase Console → [vaults-8c948](https://console.firebase.google.com/project/vaults-8c948/authentication)
2. Click "Get Started"
3. Click "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

### Step 2: Enable Firestore Database

1. Go to Firebase Console → [vaults-8c948 → Firestore Database](https://console.firebase.google.com/project/vaults-8c948/firestore)
2. Click "Create database"
3. Choose a location (select one closest to your users)
4. Choose "Start in Test Mode" (for development)
5. Click "Create"

**Important:** For production, you'll need to set up proper security rules (see below).

### Step 3: Run the App

```bash
flutter run
```

## Manual Configuration (If Needed)

If you need to reconfigure Firebase or add iOS support:

### Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Reconfigure FlutterFire

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

## Firestore Database Structure

The app uses the following Firestore structure:

```
valut (collection)
  └── user (document)
      └── {uid} (collection)
          ├── profile (document)
          │   ├── uid: string
          │   ├── name: string
          │   ├── email: string
          │   ├── isEmailVerified: boolean
          │   ├── createdAt: timestamp
          │   └── updatedAt: timestamp
          └── security_events (collection)
              └── events (collection)
                  └── {eventId} (document)
                      ├── eventId: string
                      ├── type: string
                      ├── description: string
                      ├── ipAddress: string
                      ├── userAgent: string
                      ├── metadata: map
                      └── createdAt: timestamp
```

## Security Rules (Development)

For development, you can use these test rules in Firestore:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /valut/user/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Security Rules (Production)

For production, use these stricter rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /valut/user/{userId}/profile {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId 
                   && request.resource.data.email == resource.data.email;
    }
    
    match /valut/user/{userId}/security_events/events/{eventId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### "Email/Password sign-in is not enabled" error
- Go to Firebase Console → Authentication → Sign-in method
- Enable Email/Password provider

### "Missing google-services.json" error
- Make sure `android/app/google-services.json` exists
- If missing, download it from Firebase Console → Project Settings → General

### Permission denied errors in Firestore
- Check your Firestore security rules
- For development, use test mode
- For production, set up proper rules based on your needs

### App crashes on startup
- Ensure Email/Password authentication is enabled in Firebase Console
- Ensure Firestore database is created
- Check that `firebase_options.dart` has valid configuration

## Next Steps

1. ✅ Enable Email/Password authentication in Firebase Console
2. ✅ Enable Firestore Database in Firebase Console
3. ✅ Test the signup flow
4. ✅ Test email verification
5. ✅ Test login flow
6. ✅ Set up proper Firestore security rules for production

## Additional Resources

- Firebase Documentation: https://firebase.flutter.dev/docs/overview
- FlutterFire CLI: https://github.com/firebase/flutterfire
- Firebase Console: https://console.firebase.google.com/
- Your Project: https://console.firebase.google.com/project/vaults-8c948

## Firestore Database Structure

The app uses the following Firestore structure:

```
valut (collection)
  └── user (document)
      └── {uid} (collection)
          ├── profile (document)
          │   ├── uid: string
          │   ├── name: string
          │   ├── email: string
          │   ├── isEmailVerified: boolean
          │   ├── createdAt: timestamp
          │   └── updatedAt: timestamp
          └── security_events (collection)
              └── events (collection)
                  └── {eventId} (document)
                      ├── eventId: string
                      ├── type: string
                      ├── description: string
                      ├── ipAddress: string
                      ├── userAgent: string
                      ├── metadata: map
                      └── createdAt: timestamp
```

## Security Rules (Development)

For development, you can use these test rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /valut/user/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### "Firebase options not configured" error
- Make sure you ran `flutterfire configure`
- Check that `lib/firebase_options.dart` exists
- Verify it's imported in `main.dart`

### "Email/Password sign-in is not enabled" error
- Go to Firebase Console → Authentication → Sign-in method
- Enable Email/Password provider

### "Missing google-services.json" error
- Make sure you ran `flutterfire configure`
- Check that `android/app/google-services.json` exists
- If missing, download it from Firebase Console → Project Settings → General

### Permission denied errors in Firestore
- Check your Firestore security rules
- For development, use test mode
- For production, set up proper rules based on your needs

## Next Steps

1. Test the signup flow
2. Test email verification
3. Test login flow
4. Test the verification screen
5. Set up proper Firestore security rules for production

## Additional Resources

- Firebase Documentation: https://firebase.flutter.dev/docs/overview
- FlutterFire CLI: https://github.com/firebase/flutterfire
- Firebase Console: https://console.firebase.google.com/
