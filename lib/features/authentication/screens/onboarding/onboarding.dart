import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/text_strings.dart';
import '../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// Logo & Skip
            Padding(
              padding: const EdgeInsets.fromLTRB(kGutter, 8, 4, 0),
              child: Row(
                children: const [
                  OshoLogo(height: 24),
                  Spacer(),
                  OnBoardingSkip(),
                ],
              ),
            ),

            /// Horizontal scrollable Pages
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
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
            ),

            /// Page indicator
            const OnBoardingDotNavigation(),
            const SizedBox(height: 20),

            /// Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(kGutter, 0, kGutter, 16),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.nextPage,
                      child: Text(controller.currentPageIndex.value < 2
                          ? 'Suivant'
                          : 'Démarrer'),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
