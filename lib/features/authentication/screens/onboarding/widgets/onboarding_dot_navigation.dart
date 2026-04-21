import 'package:flutter/material.dart';
import 'package:osho/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
        bottom: OSizes.defaultSpace * 6,
        left: 0,
        right: 0,
        child: Center(
          child: SmoothPageIndicator(
            controller: controller.pageController,
            onDotClicked: controller.dotNavigationClick,
            count: 3,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 10,
              activeDotColor: OColors.primary,
              dotColor: OColors.grey.withValues(alpha: 0.2),
            ),
          ),
        ));
  }
}
