import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.rectangleImage,
    this.subTitle2 = '',
    this.subTitle3 = '',
  });

  final String image, rectangleImage, title, subTitle, subTitle2, subTitle3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OSizes.defaultSpace),
      child: Column(
        children: [
          const SizedBox(height: OSizes.spaceBtwSections * 2),
          // Featured Image with soft shadow and rounded corners
          Container(
            height: OHelperFunctions.screenHeight() * 0.45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: OSizes.spaceBtwSections * 1.5),
          // Text Content with modern typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: OColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: OSizes.spaceBtwItems),
                Text(
                  subTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OColors.grey,
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                if (subTitle2.isNotEmpty) ...[
                  const SizedBox(height: OSizes.xs),
                  Text(
                    subTitle2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: OColors.grey,
                          fontSize: 16,
                          height: 1.6,
                        ),
                  ),
                ],
                if (subTitle3.isNotEmpty) ...[
                  const SizedBox(height: OSizes.xs),
                  Text(
                    subTitle3,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: OColors.grey,
                          fontSize: 16,
                          height: 1.6,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
