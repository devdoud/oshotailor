import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OFormDivider extends StatelessWidget {
  const OFormDivider({
    super.key, required this.dividertext,
  });

  final String dividertext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
            child: DottedLine(
              dashColor: OColors.grey,
              lineThickness: 1,
              dashLength: 4,
              dashGapLength: 3,
            )

        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OSizes.sm),
          child: Text(dividertext, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: OColors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )),
        ),

        Expanded(
            child: DottedLine(
              dashColor: OColors.grey,
              lineThickness: 1,
              dashLength: 4,
              dashGapLength: 3,
            )
        ),
      ],
    );
  }
}