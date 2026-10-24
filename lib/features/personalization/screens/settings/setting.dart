import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/features/personalization/screens/settings/widgets/user_profile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) Get.put(LoginController());
    if (!Get.isRegistered<UserController>()) Get.put(UserController());
    final t = context.osho;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kGutter, 16, kGutter, 32),
          children: [
            Semantics(
              header: true,
              child: Text('Profil atelier',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 20),
            const OUserProfile(),
            const SizedBox(height: 32),
            const OSectionLabel('Mon activité'),
            const SizedBox(height: 4),
            const OHairline(),
            OMenuRow(
              title: 'Détails du profil',
              subtitle: 'Nom, e-mail, téléphone',
              onTap: () => Get.to(() => const ProfileScreen()),
            ),
            const OMenuRow(
              title: 'Statistiques et revenus',
              subtitle: "Performance de l'atelier",
              trailingText: 'Bientôt',
            ),
            const OMenuRow(
              title: 'Mes services',
              subtitle: 'Vos types de couture',
              trailingText: 'Bientôt',
            ),
            const SizedBox(height: 32),
            const OSectionLabel('Service'),
            const SizedBox(height: 4),
            const OHairline(),
            const OMenuRow(
              title: 'Notifications',
              subtitle: "Préférences d'alertes",
              trailingText: 'Bientôt',
            ),
            const OMenuRow(
              title: 'Aide et support',
              subtitle: "Centre d'assistance Osho",
              trailingText: 'Bientôt',
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => LoginController.instance.logout(),
              child: const Text('Se déconnecter'),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text('Osho · atelier · v1.0.4',
                  style: OType.text(OType.caption, t.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
