import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      case TargetPlatform.iOS:
        return ios;

      case TargetPlatform.macOS:
        return macos;

      case TargetPlatform.windows:
        return windows;

      case TargetPlatform.linux:
        return linux;

      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPiPeo7yB-rnVe_mQYzeG2UF-QayM9Goc',
    appId: '1:418085831140:android:47d8760532c09cc1f5c7f1',
    messagingSenderId: '418085831140',
    projectId: 'aitradex-hybrid',
    storageBucket: 'aitradex-hybrid.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCa-yt8biUPYZ7ipaiATXbWv936RGyuajo',
    appId: '1:418085831140:ios:908a067687d0ffc9f5c7f1',
    messagingSenderId: '418085831140',
    projectId: 'aitradex-hybrid',
    storageBucket: 'aitradex-hybrid.firebasestorage.app',
    iosClientId: '418085831140-3gccg57dv3lg288b8s7kqj4r6fkrrunp.apps.googleusercontent.com',
    iosBundleId: 'com.example.aitradex',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDTROqSv_ynIrMTePv8PwjfcHaRgRh5ITI',
    appId: '1:418085831140:web:49fedd56f3431b12f5c7f1',
    messagingSenderId: '418085831140',
    projectId: 'aitradex-hybrid',
    authDomain: 'aitradex-hybrid.firebaseapp.com',
    storageBucket: 'aitradex-hybrid.firebasestorage.app',
    measurementId: 'G-HHEZDBK601',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCa-yt8biUPYZ7ipaiATXbWv936RGyuajo',
    appId: '1:418085831140:ios:908a067687d0ffc9f5c7f1',
    messagingSenderId: '418085831140',
    projectId: 'aitradex-hybrid',
    storageBucket: 'aitradex-hybrid.firebasestorage.app',
    iosClientId: '418085831140-3gccg57dv3lg288b8s7kqj4r6fkrrunp.apps.googleusercontent.com',
    iosBundleId: 'com.example.aitradex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDTROqSv_ynIrMTePv8PwjfcHaRgRh5ITI',
    appId: '1:418085831140:web:b15891ba0bdd69a0f5c7f1',
    messagingSenderId: '418085831140',
    projectId: 'aitradex-hybrid',
    authDomain: 'aitradex-hybrid.firebaseapp.com',
    storageBucket: 'aitradex-hybrid.firebasestorage.app',
    measurementId: 'G-Y2YCJXX6J9',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
