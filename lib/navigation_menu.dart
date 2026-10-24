import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/features/shop/screens/home/home.dart';
import 'package:osho/features/shop/screens/order/order.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  static const _destinations = [
    (icon: OIcons.home, label: 'Accueil'),
    (icon: OIcons.orders, label: 'Commandes'),
    (icon: OIcons.user, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final t = context.osho;

    if (initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedIndex.value = initialIndex;
      });
    }

    return Scaffold(
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(top: BorderSide(color: t.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _destinations[i].icon,
                      label: _destinations[i].label,
                      selected: controller.selectedIndex.value == i,
                      onTap: () => controller.selectedIndex.value = i,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

/// Onglet du bas : le trait d'encre au-dessus marque l'onglet actif,
/// la graisse du libellé le confirme sans dépendre de la couleur.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final color = selected ? t.ink : t.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: selected ? t.ink : t.surface.withValues(alpha: 0),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OIcon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: OType.text(OType.caption, color,
                    weight: selected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.2),
              ),
            ],
          ),
        ),
      ),
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
