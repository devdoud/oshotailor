import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/utils/constants/image_strings.dart';

/// En-tête du profil : photo carrée, nom en Fraunces, e-mail.
class OUserProfile extends StatelessWidget {
  const OUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final t = context.osho;

    return Obx(() {
      final user = controller.user.value;
      final networkImage = user.profilePicture;
      final hasName = user.firstName.isNotEmpty || user.lastName.isNotEmpty;

      return Semantics(
        button: true,
        hint: 'Ouvrir le profil',
        child: InkWell(
          onTap: () => Get.to(() => const ProfileScreen()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                OThumb(
                  url: networkImage.isNotEmpty ? networkImage : OImages.profile,
                  asset: networkImage.isEmpty,
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: controller.profileLoading.value
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: OLoader(size: 24),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasName ? user.fullName : 'Atelier Osho',
                                style: OType.display(20, t.ink,
                                    weight: FontWeight.w600)),
                            if (user.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(user.email,
                                  style: OType.text(OType.secondary, t.muted)),
                            ],
                          ],
                        ),
                ),
                OIcon(OIcons.chevronRight, size: 18, color: t.muted),
              ],
            ),
          ),
        ),
      );
    });
  }
}
