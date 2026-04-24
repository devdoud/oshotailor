import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/features/personalization/screens/settings/widgets/user_profile.dart';
import 'package:osho/utils/constants/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) Get.put(LoginController());
    if (!Get.isRegistered<UserController>()) Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Premium Header ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil Atelier',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: OColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Iconsax.setting_2, color: OColors.primary, size: 22),
                      )
                    ],
                  ),
                  const SizedBox(height: 35),
                  const OUserProfile(), 
                ],
              ),
            ),
      
            // --- Menu Sections ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Mon Activité"),
                  const SizedBox(height: 12),
                  
                  _buildMenuCard([
                    _buildMenuTile(
                      icon: Iconsax.user_edit, 
                      title: "Détails du Profil", 
                      subtitle: "Nom, email, téléphone",
                      onTap: () => Get.to(() => const ProfileScreen())
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Iconsax.status_up, 
                      title: "Statistiques & Revenus",
                      subtitle: "Performance de l'atelier", 
                      onTap: () => Get.snackbar("Bientôt", "Cette section est en cours de développement.")
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Iconsax.shop_add, 
                      title: "Mes Services",
                      subtitle: "Gérer vos types de couture", 
                      onTap: () => Get.snackbar("Services", "Fonctionnalité disponible bientôt.")
                    ),
                  ]),

                  const SizedBox(height: 30),
                  _buildSectionHeader("Service"),
                  const SizedBox(height: 12),

                  _buildMenuCard([
                    _buildMenuTile(
                      icon: Iconsax.notification_bing, 
                      title: "Notifications", 
                      subtitle: "Préférences d'alertes",
                      onTap: () => Get.snackbar("Paramètres", "Configuration des notifications.")
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Iconsax.message_question, 
                      title: "Aide & Support", 
                      subtitle: "Centre d'assistance Osho",
                      onTap: () {} 
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Iconsax.info_circle, 
                      title: "À propos", 
                      subtitle: "Version de l'application",
                      onTap: () {} 
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  InkWell(
                    onTap: () => LoginController.instance.logout(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.logout, color: Colors.red, size: 22),
                          const SizedBox(width: 12),
                          const Text(
                            "Déconnexion du compte", 
                            style: TextStyle(
                              color: Colors.red, 
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "OSHO TAILOR PREVIEW",
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "v1.0.4 • Made with love",
                          style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 10),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: OColors.grey2,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: OColors.primary, size: 22),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)
        ),
        trailing: Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey[300]),
      ),
    );
  }
}
