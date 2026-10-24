import 'package:flutter/material.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/utils/theme/theme.dart';

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
    final t = context.osho;
    final paragraphs = [subTitle, subTitle2, subTitle3]
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kGutter, 16, kGutter, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Featured image: flat, square corners, no shadow
            ClipRRect(
              borderRadius: OshoTheme.borderRadius,
              child: ExcludeSemantics(
                child: Image.asset(
                  image,
                  height: constraints.maxHeight * 0.58,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Semantics(
              header: true,
              child: Text(title,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 10),
            for (final p in paragraphs) ...[
              Text(p, style: OType.text(OType.body, t.muted, height: 1.55)),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
