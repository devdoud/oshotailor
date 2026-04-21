import 'package:flutter/material.dart';

class OSocialButon extends StatelessWidget {
  const OSocialButon({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(LoginController());
    return const Column(
      children: [
        // SingleSocialButton(dark: dark, sociallogo: OImages.google, socialname: OText.google, action: (){controller.googleSignIn();},),
        // const SizedBox(height: OSizes.spaceBtwInputFields / 2,),
        // SingleSocialButton(dark: dark, sociallogo: OImages.facebook, socialname: OText.facebook, action: (){  },)
      ],
    );
  }
}
