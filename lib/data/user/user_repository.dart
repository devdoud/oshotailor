import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/features/personalization/models/user_model.dart';

/// Repository class for user-related data operations using Supabase.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  /// Update FCM Token in Supabase
  Future<void> saveDeviceToken() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Request Permission (essential for iOS)
      await FirebaseMessaging.instance.requestPermission();

      // 2. Get unique device token
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        // 3. Upsert into tailor_tokens table
        await _supabase.from('tailor_tokens').upsert({
          'tailor_id': user.id,
          'fcm_token': token,
        });
        print("✅ FCM Token saved successfully");
      }
    } catch (e) {
      print("❌ Error saving FCM token: $e");
    }
  }

  /// Function to save user record to Supabase "users" table.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _supabase.from('users').upsert(user.toJson());
    } catch (e) {
      throw 'Erreur lors de l\'enregistrement des informations : $e';
    }
  }

  /// Function to fetch user details based on the current logged-in user ID.
  Future<UserModel> fetchUserDetails() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Utilisateur non connecté.';

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('DEBUG: Error fetching user details: $e');
      throw 'Erreur lors de la récupération des informations utilisateur.';
    }
  }

  /// Function to update user data in Supabase
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);
    } catch (e) {
      throw 'Erreur lors de la mise à jour des informations : $e';
    }
  }

  /// Update any specific field in the users table
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Utilisateur non connecté.';

      await _supabase
          .from('users')
          .update(json)
          .eq('id', userId);
    } catch (e) {
      throw 'Erreur lors de la mise à jour du champ : $e';
    }
  }

  /// Function to remove user data from Supabase
  Future<void> removeUserRecord(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      throw 'Erreur lors de la suppression du compte : $e';
    }
  }
}
