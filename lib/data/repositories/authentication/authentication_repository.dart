import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/data/services/fcm_service.dart';
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
      unawaited(FCMService.registerTailorToken(session.user.id));
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
      if (response.user != null) {
        unawaited(FCMService.registerTailorToken(response.user!.id));
      }
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
      print("DEBUG: Entame de la déconnexion Supabase...");
      await _supabase.auth.signOut();
      print("DEBUG: Session Supabase détruite avec succès.");
    } catch (e) {
      print("DEBUG: Erreur lors du signOut (souvent réseau) : $e");
    } finally {
      Get.offAll(() => const LoginScreen());
    }
  }
}
