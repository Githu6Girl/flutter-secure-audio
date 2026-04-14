import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; // Return the web config instead of throwing an error
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ADD THIS WEB CONFIGURATION
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAu9xwPb_iQhDcWfMUAVryWpd2Lnlq_dNk',
    appId: '1:583975111750:web:78c3c1e9e0f7f2b1494e47', // Standard web format
    messagingSenderId: '583975111750',
    projectId: 'audio-app-494ef',
    authDomain: 'audio-app-494ef.firebaseapp.com',
    storageBucket: 'audio-app-494ef.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAu9xwPb_iQhDcWfMUAVryWpd2Lnlq_dNk',
    appId: '1:583975111750:android:1cb03b4ba8b92004494e47',
    messagingSenderId: '583975111750',
    projectId: 'audio-app-494ef',
    storageBucket: 'audio-app-494ef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAu9xwPb_iQhDcWfMUAVryWpd2Lnlq_dNk',
    appId: '1:583975111750:ios:1cb03b4ba8b92004494e47',
    messagingSenderId: '583975111750',
    projectId: 'audio-app-494ef',
    storageBucket: 'audio-app-494ef.firebasestorage.app',
    iosBundleId: 'com.example.audioApp',
  );
}