// File generated manually from Firebase Console config.
// Project: bd-domastic--airline

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have only been configured for web so far. '
          'Run `flutterfire configure` again and select Android/iOS if you '
          'need to run this app on a device or emulator.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzE9fMDvTJ1W6p6V1yiITtyBCKb72w_CE',
    appId: '1:217432336884:web:308bed31c6a36d8a93f1a1',
    messagingSenderId: '217432336884',
    projectId: 'bd-domastic--airline',
    authDomain: 'bd-domastic--airline.firebaseapp.com',
    storageBucket: 'bd-domastic--airline.firebasestorage.app',
  );
}