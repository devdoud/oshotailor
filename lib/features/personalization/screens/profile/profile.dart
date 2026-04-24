import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/common/widgets/images/o_circular_image.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:osho/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OAppBar(
        showBackArrow: true,
        title: Text('Profil Professionnel', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultSpace),
          child: Column(
            children: [
              // Photo de profil
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage : OImages.profile;
                      return OCircularImage(
                        image: image, 
                        width: 100, 
                        height: 100, 
                        isNetworkImage: networkImage.isNotEmpty
                      );
                    }),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(), 
                      child: const Text('Changer la photo de profil', style: TextStyle(color: OColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: OSizes.spaceBtwItems),

              // Informations de base
              _buildSectionHeader('Informations de l\'Atelier'),
              const SizedBox(height: OSizes.spaceBtwItems),

              Obx(() => OProfileMenu(
                title: 'Atelier', 
                value: controller.user.value.fullName, 
                onPressed: () => _showUpdateNameDialog(context, controller)
              )),
              Obx(() => OProfileMenu(
                title: 'E-mail', 
                value: controller.user.value.email, 
                onPressed: () => Get.snackbar("Info", "L'email ne peut pas être modifié car il est lié à votre identifiant.")
              )),
              Obx(() => OProfileMenu(
                title: 'Téléphone', 
                value: controller.user.value.phone.isEmpty ? 'Non renseigné' : controller.user.value.phone, 
                onPressed: () => _showUpdatePhoneDialog(context, controller)
              )),

              const SizedBox(height: OSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: OSizes.spaceBtwItems),

              // Informations techniques
              _buildSectionHeader('Paramètres Techniques'),
              const SizedBox(height: OSizes.spaceBtwItems),
              
              OProfileMenu(title: 'ID Atelier', value: controller.user.value.id.length > 10 ? controller.user.value.id.substring(0, 10) : controller.user.value.id, onPressed: () {}, icon: Iconsax.copy),
              Obx(() => OProfileMenu(title: 'Rôle', value: controller.user.value.role.toUpperCase(), onPressed: () {}, icon: Iconsax.info_circle)),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Supprimer mon compte professionnel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: OSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
      ],
    );
  }

  void _showUpdateNameDialog(BuildContext context, UserController controller) {
    final firstNameController = TextEditingController(text: controller.user.value.firstName);
    final lastNameController = TextEditingController(text: controller.user.value.lastName);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modifier le nom de l\'atelier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Nom / Nom de l\'atelier', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updatedUser = controller.user.value;
                  updatedUser.firstName = firstNameController.text.trim();
                  updatedUser.lastName = lastNameController.text.trim();
                  controller.updateProfile(updatedUser);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Enregistrer les modifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePhoneDialog(BuildContext context, UserController controller) {
    final phoneController = TextEditingController(text: controller.user.value.phone);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Numéro de téléphone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.call),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updatedUser = controller.user.value;
                  updatedUser.phone = phoneController.text.trim();
                  controller.updateProfile(updatedUser);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mettre à jour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'Supprimer le compte ?',
      middleText: 'Cette action est irréversible. Toutes vos données d\'atelier seront perdues.',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Logique de suppression
        Get.back();
        Get.snackbar("Action requise", "Pour des raisons de sécurité, veuillez contacter le support pour supprimer définitivement votre compte atelier.");
      }
    );
  }
}
