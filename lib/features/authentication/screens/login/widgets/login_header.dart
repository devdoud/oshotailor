import 'package:flutter/material.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/utils/constants/text_strings.dart';

class OLoginHeader extends StatelessWidget {
  const OLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OshoLogo(height: 32),
        const SizedBox(height: 48),
        Semantics(
          header: true,
          child: Text(OText.loginTitle,
              style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: 8),
        Text(OText.loginSubTitle, style: OType.text(OType.body, t.muted)),
      ],
    );
  }
}
