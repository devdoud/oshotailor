import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/user/user_repository.dart';
import 'package:osho/features/personalization/models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  final photoUploading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Récupérer les données de l'utilisateur
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      user(await userRepository.fetchUserDetails());
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Enregistre le profil modifié. Le profil affiché ne change qu'une fois
  /// l'enregistrement réussi. Renvoie un message d'erreur, ou `null`.
  Future<String?> saveProfile(UserModel updated) async {
    try {
      await userRepository.updateUserDetails(updated);
      user(updated);
      OLoaders.successSnackBar(title: 'Profil enregistré.');
      return null;
    } catch (e) {
      return e is String ? e : 'Enregistrement impossible.';
    }
  }

  /// Choisit une photo (appareil photo ou galerie), l'envoie, puis
  /// l'enregistre sur le profil.
  Future<void> changePhoto(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
    } catch (e) {
      debugPrint('Image picker failed: $e');
      OLoaders.errorSnackBar(
          title: source == ImageSource.camera
              ? 'Appareil photo inaccessible.'
              : 'Galerie inaccessible.');
      return;
    }
    if (picked == null) return; // Annulé par l'utilisateur.

    photoUploading.value = true;
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.contains('.')
          ? picked.name.split('.').last
          : 'jpg';
      final url = await userRepository.uploadAvatar(bytes, extension: ext);
      await userRepository.updateSingleField({'avatar_url': url});
      user(user.value.copyWith(profilePicture: url));
      OLoaders.successSnackBar(title: 'Photo mise à jour.');
    } catch (e) {
      OLoaders.errorSnackBar(
          title: e is String ? e : 'Envoi de la photo impossible.');
    } finally {
      photoUploading.value = false;
    }
  }

  /// Retire la photo du profil (le fichier reste dans le stockage).
  Future<void> removePhoto() async {
    photoUploading.value = true;
    try {
      await userRepository.updateSingleField({'avatar_url': ''});
      user(user.value.copyWith(profilePicture: ''));
      OLoaders.successSnackBar(title: 'Photo retirée.');
    } catch (e) {
      OLoaders.errorSnackBar(title: e is String ? e : 'Action impossible.');
    } finally {
      photoUploading.value = false;
    }
  }
}
