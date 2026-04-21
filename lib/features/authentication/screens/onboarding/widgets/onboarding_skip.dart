import 'package:flutter/material.dart';
import 'package:osho/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: ODeviceUtils.getAppBarHeight(),
      right: OSizes.defaultSpace,
      child: TextButton(
        onPressed: () {
          OnBoardingController.instance.skipPage();
        },
        child: const Text(
          'Passer',
          style: TextStyle(
            color: OColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
