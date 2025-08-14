import 'package:firebase_core/firebase_core.dart';

// Renomeie este arquivo para firebase_config.dart e adicione suas credenciais
class FirebaseConfig {
  static const FirebaseOptions options = FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    databaseURL: "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.firebasestorage.app",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID",
    measurementId: "YOUR_MEASUREMENT_ID",
  );
} 