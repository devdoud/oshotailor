import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/data/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'env.dart';

/// Message reçu app fermée ou en arrière-plan. Un message avec un bloc
/// `notification` est affiché par le système ; un message de données seul
/// doit être affiché par l'app, sinon le tailleur ne voit rien.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (message.notification == null) {
    await NotificationService.show(message);
  }
}

Future<void> main() async {
  // No logs in release builds: they end up in logcat and may carry
  // customer data or backend error details.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Bord à bord : les écrans passent sous les barres système, qui restent
  // transparentes (style défini dans OshoTheme.systemOverlay).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await GetStorage.init();
  await loadEnv();
  await initializeDateFormatting('fr_FR', null);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Permission et jeton : demandés après la connexion (registerDevice).
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  FlutterNativeSplash.remove();

  runApp(const App());
}
