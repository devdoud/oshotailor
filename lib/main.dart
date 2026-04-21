import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/data/services/fcm_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Handling a background message: ');
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FCMService.requestPermissions();

    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization warning: ');
  }

  await Supabase.initialize(
    url: 'https://pzkeklqgogwvnspmivhp.supabase.co',
    anonKey: 'sb_publishable_kNei4UoU8GgPwr05EXXJXw_yJFzmBAY',
  );

  FlutterNativeSplash.remove();

  runApp(const App());
}
