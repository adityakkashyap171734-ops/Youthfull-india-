import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtNGiUoqGCWjaUnFZayKJAqeaVO9fxEwo',
    appId: '1:590594762839:android:345d206081f2493da09b12',
    messagingSenderId: '590594762839',
    projectId: 'youthfull-india',
    storageBucket: 'youthfull-india.firebasestorage.app',
  );
}
