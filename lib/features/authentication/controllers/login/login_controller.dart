import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/helpers/network_manager.dart';
import '../../../../utils/popups/full-screen_loader.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    // Load saved email and password if "Remember Me" was checked
    String? savedEmail = localStorage.read('REMEMBER_ME_EMAIL');

    if (savedEmail != null) {
      email.text = savedEmail;
      rememberMe.value = true;
    }
    super.onInit();
  }

  /// -- Email and Password Login with Supabase
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog(
          'Connexion en cours...', OImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        OFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        OFullScreenLoader.stopLoading();
        return;
      }

      // Save Email if Remember Me is checked (Better not to save password for security)
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
      } else {
        localStorage.remove('REMEMBER_ME_EMAIL');
      }

      // Login user using Supabase
      await AuthenticationRepository.instance
          .loginWithSupabase(email.text.trim(), password.text.trim());

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Show Success Message
      OLoaders.successSnackBar(
          title: 'Connexion réussie', message: 'Ravi de vous revoir !');

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Redirect User
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      OFullScreenLoader.stopLoading();
      // Show Error Snackbar
      OLoaders.errorSnackBar(title: 'Erreur de connexion', message: e.toString());
    }
  }

  /// -- Logout
  Future<void> logout() async {
    try {
      await AuthenticationRepository.instance.logout();
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    }
  }
}
