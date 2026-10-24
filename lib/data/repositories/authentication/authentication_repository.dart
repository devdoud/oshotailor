import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/data/services/notification_service.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/authentication/screens/onboarding/onboarding.dart';
import 'package:osho/navigation_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _supabase = Supabase.instance.client;

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  Future<void> screenRedirect() async {
    final session = _supabase.auth.currentSession;

    if (session != null) {
      Get.offAll(() => const NavigationMenu());
      // Same path after login and on app start with a saved session.
      unawaited(NotificationService.registerDevice());
      unawaited(NotificationService.openLaunchOrder());
      return;
    }

    deviceStorage.writeIfNull('IsFirstTime', true);

    if (deviceStorage.read('IsFirstTime') != true) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(const OnBoardingScreen());
    }
  }

  Future<AuthResponse> registerWithSupabase({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Une erreur inattendue est survenue lors de l\'inscription.';
    }
  }

  Future<AuthResponse> loginWithSupabase(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      // Affichera précisément "Email not confirmed" ou "Invalid login credentials"
      throw e.message; 
    } catch (e) {
      throw 'Erreur de connexion : Vérifiez votre connexion internet.';
    }
  }

  Future<void> logout() async {
    try {
      debugPrint("DEBUG: Entame de la déconnexion Supabase...");
      // While still signed in: stop sending this account's orders here.
      await NotificationService.unregisterDevice();
      await _supabase.auth.signOut();
      debugPrint("DEBUG: Session Supabase détruite avec succès.");
    } catch (e) {
      debugPrint("DEBUG: Erreur lors du signOut (souvent réseau) : $e");
    } finally {
      Get.offAll(() => const LoginScreen());
    }
  }
}
