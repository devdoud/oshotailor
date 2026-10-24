import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:osho/utils/theme/osho_tokens.dart';
import 'package:osho/utils/theme/osho_type.dart';

/// La marque Osho : un anneau ouvert (le O) traversé d'un repère (la craie
/// du tailleur). Géométrie exacte sur un champ de 100 × 100.
///
/// Règles : l'anneau ne pivote pas, l'ouverture reste en haut à droite ;
/// le repère garde sa couleur ; laisser autour un vide égal à la moitié de
/// la hauteur de la marque.
class OshoMark extends StatelessWidget {
  const OshoMark({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _MarkPainter(ring: t.markRing, tick: t.markTick),
      ),
    );
  }
}

/// Marque + nom + descripteur. Sous 20 px de hauteur, la marque seule.
///
/// Le descripteur distingue l'app tailleur de l'app cliente sans toucher à
/// la marque : un filet vertical, puis « ATELIER » en petites capitales
/// DM Sans, couleur `muted`. Passer `descriptor: null` pour le logo nu.
class OshoLogo extends StatelessWidget {
  const OshoLogo({super.key, this.height = 28, this.descriptor = 'Atelier'});

  final double height;
  final String? descriptor;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final mark = OshoMark(size: height);
    final label = descriptor == null ? 'Osho' : 'Osho $descriptor';
    if (height < 20) {
      return Semantics(label: label, image: true, child: mark);
    }
    final nameSize = height * 1.18;
    // Jamais sous le plancher de 11 px.
    final descSize = math.max(OType.floor, height * 0.46);
    const noLeading = TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    );
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            SizedBox(width: height * 0.42),
            Text(
              'Osho',
              style: OType.display(nameSize, t.ink,
                  weight: FontWeight.w600, height: 1),
              textHeightBehavior: noLeading,
            ),
            if (descriptor != null) ...[
              SizedBox(width: height * 0.5),
              Container(width: 1, height: height * 0.8, color: t.hairline),
              SizedBox(width: height * 0.5),
              Text(
                descriptor!.toUpperCase(),
                style: OType.text(descSize, t.muted,
                        weight: FontWeight.w600, height: 1)
                    .copyWith(letterSpacing: descSize * 0.12),
                textHeightBehavior: noLeading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.ring, required this.tick});

  final Color ring;
  final Color tick;

  static double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // Coordonnées du champ 100 × 100 mises à l'échelle à la main (pas de
    // canvas.scale) pour que l'arc soit tracé à la taille réelle, sans facettes.
    final k = size.width / 100;
    final c = Offset(50 * k, 50 * k);

    // Anneau : centre (50,50), rayon 36, épaisseur 11, bouts francs,
    // arc de −27° à 297° dans le sens horaire (y vers le bas).
    final ringPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * k
      ..strokeCap = StrokeCap.butt
      ..color = ring;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 36 * k),
      _rad(-27),
      _rad(324),
      false,
      ringPaint,
    );

    // Repère : segment à −45°, du rayon 24 au rayon 48.
    final a = _rad(-45);
    Offset at(double r) =>
        c + Offset(r * k * math.cos(a), r * k * math.sin(a));
    final tickPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * k
      ..strokeCap = StrokeCap.butt
      ..color = tick;
    canvas.drawLine(at(24), at(48), tickPaint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.ring != ring || old.tick != tick;
}
