import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icônes au trait, en SVG. Aucune police de symboles dans l'app.
/// Champ 24 × 24, trait 1.6, bouts francs, angles vifs.
class OIcons {
  OIcons._();

  static const arrowLeft = '<path d="M11 5l-7 7 7 7"/><path d="M4 12h16"/>';
  static const arrowRight = '<path d="M13 5l7 7-7 7"/><path d="M20 12H4"/>';
  static const chevronRight = '<path d="M9 5l7 7-7 7"/>';
  static const close = '<path d="M6 6l12 12"/><path d="M18 6L6 18"/>';
  static const refresh =
      '<path d="M20 12a8 8 0 1 1-2.34-5.66"/><path d="M20 4v5h-5"/>';
  static const eye =
      '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/>'
      '<circle cx="12" cy="12" r="3"/>';
  static const eyeOff =
      '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/>'
      '<circle cx="12" cy="12" r="3"/><path d="M4 4l16 16"/>';
  static const home = '<path d="M3.5 10.5L12 4l8.5 6.5"/><path d="M6 9v11h12V9"/>'
      '<path d="M10 20v-6h4v6"/>';
  static const orders = '<path d="M5 3.5h14v17H5z"/><path d="M8.5 8h7"/>'
      '<path d="M8.5 12h7"/><path d="M8.5 16h4"/>';
  static const user =
      '<circle cx="12" cy="8.5" r="4"/><path d="M4.5 20.5c0-4 3.4-6.5 7.5-6.5s7.5 2.5 7.5 6.5"/>';
  static const copy = '<path d="M9 9h11v11H9z"/><path d="M15 9V4H4v11h5"/>';
  static const image = '<path d="M3.5 4.5h17v15h-17z"/><path d="M3.5 16l5-5 4 4 3-3 4.5 4.5"/>'
      '<circle cx="15.5" cy="8.5" r="1.5"/>';

  static String svg(String body) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#000" stroke-width="1.6" stroke-linecap="butt" '
      'stroke-linejoin="miter">$body</svg>';
}

class OIcon extends StatelessWidget {
  const OIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  /// Une des constantes de [OIcons].
  final String icon;
  final double? size;
  final Color? color;

  /// À renseigner seulement si l'icône porte seule une information ;
  /// dans un bouton, c'est le `tooltip` du bouton qui la nomme.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 22;
    final c = color ?? theme.color ?? DefaultTextStyle.of(context).style.color!;
    final picture = SvgPicture.string(
      OIcons.svg(icon),
      width: s,
      height: s,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: picture);
    return Semantics(label: semanticLabel, image: true, child: picture);
  }
}
