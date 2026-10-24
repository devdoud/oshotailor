import 'package:flutter/material.dart';

/// Typographie « Atelier » : une seule serif (Fraunces) pour ce qui a de la
/// valeur — titres et prix — et DM Sans pour tout le reste.
class OType {
  OType._();

  static const String serif = 'Fraunces';
  static const String sans = 'DMSans';
  static const List<String> serifFallback = ['Georgia', 'serif'];
  static const List<String> sansFallback = ['system-ui', 'sans-serif'];

  /// Tailles du corps de texte, en pixels logiques.
  static const double body = 15;
  static const double secondary = 13.5;
  static const double caption = 12.5;

  /// Plancher absolu : rien ne descend sous 11.
  static const double floor = 11;

  /// Une seule coupe optique (72 pt, dessinée pour les titres) :
  /// l'interlettrage se resserre en grand et s'ouvre en petit.
  static double frauncesTracking(double size) {
    if (size >= 24) return -0.012 * size;
    if (size >= 20) return 0;
    return 0.008 * (20 - size);
  }

  /// Fraunces, graisse 400 ou 600 uniquement.
  static TextStyle display(double size, Color color,
      {FontWeight weight = FontWeight.w400, double height = 1.15}) {
    assert(weight == FontWeight.w400 || weight == FontWeight.w600);
    return TextStyle(
      fontFamily: serif,
      fontFamilyFallback: serifFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: frauncesTracking(size),
      color: color,
    );
  }

  /// Un prix ou un total : Fraunces 600, chiffres tabulaires.
  static TextStyle price(double size, Color color) =>
      display(size, color, weight: FontWeight.w600, height: 1.2).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle text(double size, Color color,
      {FontWeight weight = FontWeight.w400, double height = 1.4}) {
    assert(size >= floor);
    return TextStyle(
      fontFamily: sans,
      fontFamilyFallback: sansFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  /// Intitulé de section en petites capitales : 12 px, 600, +1.44.
  static TextStyle smallCaps(Color color) =>
      text(12, color, weight: FontWeight.w600, height: 1.3)
          .copyWith(letterSpacing: 1.44);
}
