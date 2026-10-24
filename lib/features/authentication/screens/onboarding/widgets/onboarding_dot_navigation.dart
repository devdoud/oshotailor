import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/controllers/onboarding/onboarding_controller.dart';

/// Indicateur de page : trois traits fins, celui de la page courante à
/// l'encre et plus long. Non tactile ; on avance par le bouton ou au doigt.
class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  static const _count = 3;

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final t = context.osho;
    return Obx(() {
      final current = controller.currentPageIndex.value;
      return Semantics(
        label: 'Page ${current + 1} sur $_count',
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == current ? 28 : 14,
                height: 2,
                color: i == current ? t.ink : t.muted,
              ),
          ],
        ),
      );
    });
  }
}
