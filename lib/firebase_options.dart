// File: lib/firebase_options.dart
//
// Firebase configuration extracted from google-services.json
// Project: vaults-8c948
//
// Make sure to enable Email/Password authentication in Firebase Console:
// https://console.firebase.google.com/project/vaults-8c948/authentication/providers

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyC8Rly_fMiKBo1xMxW7j1cnTt7g-MCbnc4',
          appId: '1:90187469062:android:bbf68cd252796ebbe28e87',
          messagingSenderId: '90187469062',
          projectId: 'vaults-8c948',
          storageBucket: 'vaults-8c948.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyC8Rly_fMiKBo1xMxW7j1cnTt7g-MCbnc4',
          appId: '1:90187469062:ios:bbf68cd252796ebbe28e87',
          messagingSenderId: '90187469062',
          projectId: 'vaults-8c948',
          storageBucket: 'vaults-8c948.firebasestorage.app',
          iosBundleId: 'com.devtrisoft.valut_password',
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyC8Rly_fMiKBo1xMxW7j1cnTt7g-MCbnc4',
          appId: '1:90187469062:android:bbf68cd252796ebbe28e87',
          messagingSenderId: '90187469062',
          projectId: 'vaults-8c948',
          storageBucket: 'vaults-8c948.firebasestorage.app',
          iosBundleId: 'com.devtrisoft.valut_password',
        );
      case TargetPlatform.windows:
        return const FirebaseOptions(
          apiKey: 'AIzaSyC8Rly_fMiKBo1xMxW7j1cnTt7g-MCbnc4',
          appId: '1:90187469062:android:bbf68cd252796ebbe28e87',
          messagingSenderId: '90187469062',
          projectId: 'vaults-8c948',
          storageBucket: 'vaults-8c948.firebasestorage.app',
        );
      case TargetPlatform.linux:
        throw UnimplementedError(
          'DefaultFirebaseOptions has not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnimplementedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
