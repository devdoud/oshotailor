import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/features/shop/screens/home/home.dart';
import 'package:osho/features/shop/screens/order/order.dart';
import 'package:osho/utils/constants/colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    if (initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedIndex.value = initialIndex;
      });
    }

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          backgroundColor: Colors.white,
          indicatorColor: OColors.primary.withOpacity(0.1),
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
                icon: Icon(Iconsax.home),
                selectedIcon: Icon(Iconsax.home5, color: OColors.primary),
                label: 'Accueil'),
            NavigationDestination(
                icon: Icon(Iconsax.task),
                selectedIcon: Icon(Iconsax.task, color: OColors.primary),
                label: 'Commandes'),
            NavigationDestination(
                icon: Icon(Iconsax.user),
                selectedIcon: Icon(Iconsax.user, color: Colors.black),
                label: 'Profil'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final List<Widget> screens = [
    const HomeScreen(),      
    const OrderScreen(),
    const SettingsScreen(),
  ];
}
