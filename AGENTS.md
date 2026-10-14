# PassBox - Password Manager - Project Information

## Project Overview
A Flutter-based password manager application with Firebase authentication and Firestore database integration.

## Tech Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore)
- **Authentication**: Email/Password with email verification
- **Security**: Biometric authentication (local_auth), crypto operations

## Build Commands

### Run the app
```bash
flutter run
```

### Build for Android
```bash
flutter build apk
```

### Build for iOS
```bash
flutter build ios
```

### Get dependencies
```bash
flutter pub get
```

### Clean build
```bash
flutter clean
flutter pub get
```

## Key Dependencies
- `firebase_core: ^3.15.2`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.4.4`
- `crypto: ^3.0.3`
- `local_auth: ^2.3.0`
- `lottie: ^3.1.2`

## Project Structure
```
lib/
├── core/                    # Core utilities (theme, constants, etc.)
├── features/
│   ├── auth/               # Authentication flow
│   │   ├── auth.dart       # Auth barrel file
│   │   ├── auth_service.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── verification_screen.dart
│   │   └── models/
│   │       └── user_model.dart
│   ├── security/           # Security features
│   │   └── models/
│   │       └── security_event.dart
│   ├── vault/              # Password vault
│   ├── items/              # Password items
│   ├── generate/          # Password generator
│   └── settings/          # App settings
├── main.dart
├── splash_screen.dart
└── firebase_options.dart  # Firebase configuration (needs generation)
```

## Authentication Flow

### 1. Signup Flow
- User enters name, email, password
- Calls `AuthService.signUpWithEmailAndPassword()`
- Creates Firebase Auth user
- Sends verification email
- Stores user data in Firestore
- Navigates to VerificationScreen

### 2. Verification Flow
- User clicks link in email
- Returns to app and clicks "I've Verified My Email"
- App reloads user and checks `emailVerified` status
- If verified, syncs status to Firestore and navigates to main screen
- Timer allows resend after 5 minutes (300 seconds)

### 3. Login Flow
- User enters email, password
- Calls `AuthService.signInWithEmailAndPassword()`
- Reloads user to get latest verification status
- If not verified, signs out and navigates to VerificationScreen
- If verified, syncs status to Firestore and navigates to main screen

### 4. Splash Screen Flow
- Shows splash animation for 3 seconds
- Checks if user is logged in
- If logged in, reloads user and checks verification status
- If verified, navigates to main screen
- Otherwise, navigates to login screen

## Firestore Database Structure

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

## Important Notes

### Firebase Setup
- Firebase configuration requires `firebase_options.dart` to be generated
- Run: `dart pub global run flutterfire_cli:flutterfire configure`
- See `FIREBASE_SETUP.md` for detailed instructions

### Email Verification
- Email verification is REQUIRED before accessing the app
- Timer for resend is set to 5 minutes (300 seconds)
- Verification status is synced to Firestore on successful verification

### Security
- All auth operations log security events to Firestore
- Security events are tracked for audit purposes
- Biometric authentication is available via local_auth

### Theme
- App uses a dark theme by default
- Theme is defined in `lib/core/theme/`
- Color scheme is Material 3 based

## Common Issues

### Firebase Options Error
If you get "Firebase options not configured":
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. Configure: `dart pub global run flutterfire_cli:flutterfire configure`

### Email Verification Not Working
1. Check that Email/Password is enabled in Firebase Console
2. Check spam folder for verification email
3. Ensure `isEmailVerified` is synced to Firestore
4. Verify Firestore security rules allow user access

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check that all dependencies are compatible
- Verify Android SDK is properly configured

### APK Crashes in Release Mode
The following issues have been fixed to prevent release mode crashes:

1. **AdMob Ad Unit IDs**: Updated to use test IDs for both debug and release modes. Configure production AdMob IDs before publishing to store.

2. **Firebase iOS Configuration**: Fixed iOS app ID in firebase_options.dart (was using Android app ID).

3. **Signing Configuration**: Updated build.gradle.kts to use debug signing if key.properties is missing (allows release builds without custom keystore).

4. **ProGuard Rules**: Added proguard-rules.pro for Firebase, Google Ads, and Flutter classes.

5. **Internet Permission**: Added INTERNET permission to AndroidManifest.xml (required for Firebase).

### Setting Up Release Signing (Optional)
For production releases with your own keystore:

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Create `android/app/key.properties`:
   ```
   storePassword=<your keystore password>
   keyPassword=<your key password>
   keyAlias=key
   storeFile=<path to keystore file>
   ```

3. Build signed APK:
   ```bash
   flutter build apk --release
   ```

### Setting Up AdMob for Production
Before publishing to the store:

1. Get your AdMob App ID and ad unit IDs from Google AdMob console
2. Update `lib/core/services/admob_service.dart`:
   - Replace `_productionInterstitialAdUnitId` with your actual interstitial ad unit ID
   - Replace `_productionBannerAdUnitId` with your actual banner ad unit ID
   - Update the ad unit ID selection logic to use production IDs in release mode
3. Update `android/app/src/main/AndroidManifest.xml`:
   - Replace the test AdMob App ID with your production App ID

## Navigation Routes
- `/` - SplashScreen
- `/login` - LoginScreen
- `/main` - MainScreen (with bottom navigation)

## Future Enhancements
- Password reset functionality
- Social auth (Google, Apple)
- Two-factor authentication
- End-to-end encryption for passwords
- Cross-platform sync
- Import/export passwords
