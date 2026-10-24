import 'package:flutter/material.dart';
import 'package:osho/features/authentication/controllers/onboarding/onboarding_controller.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => OnBoardingController.instance.skipPage(),
      child: const Text('Passer'),
    );
  }
}
