import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Register tailor token in Supabase
  static Future<void> registerTailorToken(String tailorId) async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token == null) {
        throw Exception('Failed to get FCM token');
      }

      // Upsert the token to avoid unique constraint conflicts.
      await _supabase.from('tailor_tokens').upsert(
        {
          'tailor_id': tailorId,
          'fcm_token': token,
          'created_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'tailor_id',
      );
    } catch (e) {
      print('❌ Error registering FCM token: $e');
      rethrow;
    }
  }

  /// Listen to incoming notifications
  static void listenToNotifications(Function() onNewOrder) {
    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message, onNewOrder);
    });

    // Handle notification when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message, onNewOrder);
    });
  }

  /// Handle notification based on type
  static void _handleNotification(
      RemoteMessage message, Function() onNewOrder) {
    try {
      final data = message.data;

      if (data['type'] == 'new_order') {
        print('📬 New order notification received');
        onNewOrder();
      } else if (data['type'] == 'order_update') {
        print('🔄 Order update notification received');
        onNewOrder();
      }
    } catch (e) {
      print('❌ Error handling notification: $e');
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Request notification permissions (iOS specific)
  static Future<NotificationSettings> requestPermissions() async {
    try {
      return await _firebaseMessaging.requestPermission();
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      rethrow;
    }
  }
}
