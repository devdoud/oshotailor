import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/common/widgets/images/o_circular_image.dart';
import 'package:osho/utils/constants/colors.dart';

class OUserProfile extends StatelessWidget {
  const OUserProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Ensuring UserController is available
    final controller = Get.put(UserController());

    return Column(
      children: [
        Obx(() {
          final networkImage = controller.user.value.profilePicture;
          final image = networkImage.isNotEmpty ? networkImage : OImages.profile;
          
          return InkWell(
            onTap: () {
                // ProfileScreen removed for now as it was causing an error
                Get.snackbar("Info", "La modification du profil sera disponible prochainement.");
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: OColors.primary.withValues(alpha: 0.1), width: 1),
              ),
              child: OCircularImage(
                image: image,
                width: 80,
                height: 80,
                isNetworkImage: networkImage.isNotEmpty,
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.profileLoading.value) {
              return const SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(strokeWidth: 2, color: OColors.primary)
              );
          }
          
          final user = controller.user.value;
          final hasName = user.firstName.isNotEmpty || user.lastName.isNotEmpty;
          
          return Column(
            children: [
              Text(
                hasName ? user.fullName : "Bienvenue Atelier",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                user.email.isEmpty ? "connectez-vous" : user.email,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          );
        }),
      ],
    );
  }
}
