import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/features/tailor_dashboard/screens/tailor_order_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifications de commandes, de bout en bout :
/// affichage (app ouverte ou non), son dédié, ouverture de la commande au
/// toucher, et cycle de vie du jeton FCM côté Supabase.
///
/// Contrat attendu du serveur (champs `data` du message FCM) :
///   type      : 'new_order' | 'order_update'
///   order_id  : identifiant de la commande (ou assignment_id)
///   title, body (facultatifs) : textes affichés si le message n'a pas de
///   bloc `notification`.
class NotificationService {
  NotificationService._();

  static const _channel = AndroidNotificationChannel(
    'new_orders',
    'Nouvelles commandes',
    description: 'Alerte quand un client passe une commande pour votre atelier.',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('new_order'),
  );

  static const _smallIcon = '@drawable/ic_notification';

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _listening = false;
  static StreamSubscription<String>? _tokenRefreshSub;

  /// Prépare l'affichage local (canal Android, iOS au premier plan).
  /// Appelé au démarrage, et dans l'isolat d'arrière-plan.
  static Future<void> initialize() async {
    if (_initialized) return;
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        // La permission est demandée à la connexion, pas au démarrage.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => _openOrder(r.payload),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    // iOS : afficher aussi la bannière quand l'app est ouverte.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    _initialized = true;
  }

  /// À appeler une fois le tailleur connecté : permission, jeton, écoute.
  static Future<void> registerDevice() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        OLoaders.warningSnackBar(
          title: 'Notifications désactivées',
          message:
              'Activez-les dans les réglages du téléphone pour être alerté des nouvelles commandes.',
        );
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) throw Exception('Jeton FCM indisponible');
      await _saveToken(userId, token);

      _tokenRefreshSub ??=
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        final uid = Supabase.instance.client.auth.currentUser?.id;
        if (uid != null) {
          _saveToken(uid, newToken).catchError(
              (Object e) => debugPrint('Token refresh not saved: $e'));
        }
      });

      _listen();
    } catch (e) {
      debugPrint('Device registration failed: $e');
      OLoaders.warningSnackBar(
        title: 'Notifications indisponibles',
        message:
            'Cet appareil n’a pas pu être enregistré. Les nouvelles commandes restent visibles dans l’app.',
      );
    }
  }

  /// À appeler avant la déconnexion : l'appareil ne doit plus recevoir les
  /// commandes de ce compte.
  static Future<void> unregisterDevice() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (userId != null && token != null) {
        await Supabase.instance.client
            .from('tailor_tokens')
            .delete()
            .eq('tailor_id', userId)
            .eq('fcm_token', token);
      }
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Device unregistration failed: $e');
    }
  }

  /// Si l'app a été ouverte par le toucher d'une notification, ouvre la
  /// commande concernée. À appeler une fois l'écran principal affiché.
  static Future<void> openLaunchOrder() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) return _openOrder(_orderId(initial.data));

    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _openOrder(launch!.notificationResponse?.payload);
    }
  }

  /// Affiche localement un message sans bloc `notification` (sinon c'est le
  /// système qui l'affiche) ou reçu app ouverte.
  static Future<void> show(RemoteMessage message) async {
    await initialize();
    final data = message.data;
    final title = message.notification?.title ??
        data['title'] ??
        (data['type'] == 'order_update'
            ? 'Commande mise à jour'
            : 'Nouvelle commande');
    final body = message.notification?.body ??
        data['body'] ??
        (data['type'] == 'order_update'
            ? 'Le statut d’une de vos commandes a changé.'
            : 'Un client vient de commander une pièce à votre atelier.');

    await _local.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: _smallIcon,
          sound: _channel.sound,
          category: AndroidNotificationCategory.message,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: 'new_order.caf',
        ),
      ),
      payload: _orderId(data),
    );
  }

  static void _listen() {
    if (_listening) return;
    _listening = true;

    FirebaseMessaging.onMessage.listen((message) {
      _refreshData();
      // iOS affiche lui-même la bannière (options ci-dessus) ; Android non.
      if (defaultTargetPlatform == TargetPlatform.android ||
          message.notification == null) {
        show(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _refreshData();
      _openOrder(_orderId(message.data));
    });
  }

  static Future<void> _saveToken(String userId, String token) async {
    await Supabase.instance.client.from('tailor_tokens').upsert(
      {
        'tailor_id': userId,
        'fcm_token': token,
        'created_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'tailor_id',
    );
  }

  static String? _orderId(Map<String, dynamic> data) {
    final id = data['order_id'] ?? data['orderId'] ?? data['assignment_id'];
    final s = id?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  static void _openOrder(String? orderId) {
    if (orderId == null) return;
    if (Supabase.instance.client.auth.currentSession == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => TailorOrderDetailScreen(orderId: orderId));
    });
  }

  static void _refreshData() {
    if (Get.isRegistered<TailorOrdersController>()) {
      TailorOrdersController.instance.fetchOrders();
    }
    if (Get.isRegistered<HomeController>()) {
      HomeController.instance.fetchDashboardData();
    }
  }
}
