import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import '../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Horizontal scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: OImages.onBoardingReceive,
                rectangleImage: OImages.onBoardingReceive,
                title: OText.onBoardingTitle1,
                subTitle: OText.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: OImages.onBoardingAccept,
                rectangleImage: OImages.onBoardingAccept,
                title: OText.onBoardingTitle2,
                subTitle: OText.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: OImages.onBoardingDeliver,
                rectangleImage: OImages.onBoardingDeliver,
                title: OText.onBoardingTitle3,
                subTitle: OText.onBoardingSubTitle3,
              ),
            ],
          ),

          /// Skip Button
          const OnBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          /// Circular Button
          OnBoardingElevatedButton(controller: controller)
        ],
      ),
    );
  }
}

class OnBoardingElevatedButton extends StatelessWidget {
  const OnBoardingElevatedButton({
    super.key,
    required this.controller,
  });

  final OnBoardingController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: OSizes.defaultSpace * 1.5,
        left: OSizes.defaultSpace,
        right: OSizes.defaultSpace,
        child: SizedBox(
            width: double.infinity,
            child: Obx(() {
              return ElevatedButton(
                onPressed: () {
                  OnBoardingController.instance.nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.currentPageIndex.value < 2
                        ? 'Suivant'
                        : 'Démarrer'),
                    if (controller.currentPageIndex.value < 2) ...[
                      const SizedBox(width: OSizes.md),
                      const Image(
                        image: AssetImage(OImages.onBoardingArrow),
                        width: 20,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              );
            })));
  }
}
