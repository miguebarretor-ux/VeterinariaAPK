import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Firebase no configurado para Android.');
      case TargetPlatform.iOS:
        throw UnsupportedError('Firebase no configurado para iOS.');
      default:
        throw UnsupportedError('Plataforma no soportada.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAxct082BYWGG8IBiI00AIrggzfqfvKliA',
    appId: '1:258115146591:web:b4fe2203aeb09fbbaddcea',
    messagingSenderId: '258115146591',
    projectId: 'veterinariaapk',
    authDomain: 'veterinariaapk.firebaseapp.com',
    storageBucket: 'veterinariaapk.firebasestorage.app',
    measurementId: 'G-6JSW5DXWHS',
  );
}
