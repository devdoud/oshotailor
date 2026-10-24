import 'package:flutter/material.dart';

/// Jetons de couleur de la direction « Atelier ».
///
/// C'est la seule source de couleur de l'app : aucun écran ne doit écrire une
/// couleur en dur. Chaque jeton existe dans les deux jeux, clair et sombre.
/// Le sombre n'est pas une inversion : fond chaud, accent éclairci, rouge
/// garance relevé pour garder son contraste.
@immutable
class OshoTokens extends ThemeExtension<OshoTokens> {
  const OshoTokens({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.placeholder,
    required this.placeholderInk,
    required this.accent,
    required this.accentBg,
    required this.accentBorder,
    required this.accentInk,
    required this.warnBg,
    required this.warnBorder,
    required this.warnInk,
    required this.okBg,
    required this.okBorder,
    required this.okInk,
    required this.dangerBg,
    required this.dangerBorder,
    required this.dangerInk,
    required this.primaryFill,
    required this.primaryInk,
    required this.like,
    required this.markRing,
    required this.markTick,
  });

  /// Le papier, fond de toute page.
  final Color bg;

  /// Une zone posée sur le papier.
  final Color surface;
  final Color ink;
  final Color muted;

  /// Tous les traits, bordures, séparateurs.
  final Color hairline;
  final Color placeholder;
  final Color placeholderInk;
  final Color accent;
  final Color accentBg;
  final Color accentBorder;
  final Color accentInk;
  final Color warnBg;
  final Color warnBorder;
  final Color warnInk;
  final Color okBg;
  final Color okBorder;
  final Color okInk;

  /// Ajout au brief : erreurs et actions destructrices (refus, suppression).
  final Color dangerBg;
  final Color dangerBorder;
  final Color dangerInk;
  final Color primaryFill;
  final Color primaryInk;
  final Color like;

  /// Anneau et repère du logo.
  final Color markRing;
  final Color markTick;

  static const light = OshoTokens(
    bg: Color(0xFFF7F3EA),
    surface: Color(0xFFFDFBF6),
    ink: Color(0xFF16181D),
    muted: Color(0xFF5E6066),
    hairline: Color(0xFFDED5C4),
    placeholder: Color(0xFFEDE6D7),
    placeholderInk: Color(0xFF8A8578),
    accent: Color(0xFF2A3F6B),
    accentBg: Color(0xFFECEFF6),
    accentBorder: Color(0xFFC3CCDF),
    accentInk: Color(0xFF1C2C4D),
    warnBg: Color(0xFFF6EDE4),
    warnBorder: Color(0xFFD9B48F),
    warnInk: Color(0xFF6B4410),
    okBg: Color(0xFFE7EFE8),
    okBorder: Color(0xFFB3CDB9),
    okInk: Color(0xFF24502F),
    dangerBg: Color(0xFFF7E8E5),
    dangerBorder: Color(0xFFDDAAA2),
    dangerInk: Color(0xFF8A2A21),
    primaryFill: Color(0xFF16181D),
    primaryInk: Color(0xFFF7F3EA),
    like: Color(0xFFA8322A),
    markRing: Color(0xFF16181D),
    markTick: Color(0xFFA8322A),
  );

  static const dark = OshoTokens(
    bg: Color(0xFF14130F),
    surface: Color(0xFF1C1A16),
    ink: Color(0xFFF2EEE4),
    muted: Color(0xFFA09A8D),
    hairline: Color(0xFF332F28),
    placeholder: Color(0xFF26231D),
    placeholderInk: Color(0xFF938D7F),
    accent: Color(0xFF8FA8D6),
    accentBg: Color(0xFF1A2236),
    accentBorder: Color(0xFF2E3A54),
    accentInk: Color(0xFFB9C8E6),
    warnBg: Color(0xFF2A1F10),
    warnBorder: Color(0xFF5C4526),
    warnInk: Color(0xFFE6C28E),
    okBg: Color(0xFF12241A),
    okBorder: Color(0xFF2C4433),
    okInk: Color(0xFF9FCBAB),
    dangerBg: Color(0xFF2C1613),
    dangerBorder: Color(0xFF5E2E28),
    dangerInk: Color(0xFFF0A396),
    primaryFill: Color(0xFFF2EEE4),
    primaryInk: Color(0xFF14130F),
    like: Color(0xFFE8705F),
    markRing: Color(0xFFF7F3EA),
    markTick: Color(0xFFD4564A),
  );

  /// Voile des fenêtres modales : toujours le ton le plus sombre du jeu.
  Color get scrim => (ink.computeLuminance() < bg.computeLuminance() ? ink : bg)
      .withValues(alpha: 0.48);

  static OshoTokens of(BuildContext context) =>
      Theme.of(context).extension<OshoTokens>() ?? light;

  @override
  OshoTokens copyWith() => this;

  @override
  OshoTokens lerp(ThemeExtension<OshoTokens>? other, double t) {
    if (other is! OshoTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return OshoTokens(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      hairline: l(hairline, other.hairline),
      placeholder: l(placeholder, other.placeholder),
      placeholderInk: l(placeholderInk, other.placeholderInk),
      accent: l(accent, other.accent),
      accentBg: l(accentBg, other.accentBg),
      accentBorder: l(accentBorder, other.accentBorder),
      accentInk: l(accentInk, other.accentInk),
      warnBg: l(warnBg, other.warnBg),
      warnBorder: l(warnBorder, other.warnBorder),
      warnInk: l(warnInk, other.warnInk),
      okBg: l(okBg, other.okBg),
      okBorder: l(okBorder, other.okBorder),
      okInk: l(okInk, other.okInk),
      dangerBg: l(dangerBg, other.dangerBg),
      dangerBorder: l(dangerBorder, other.dangerBorder),
      dangerInk: l(dangerInk, other.dangerInk),
      primaryFill: l(primaryFill, other.primaryFill),
      primaryInk: l(primaryInk, other.primaryInk),
      like: l(like, other.like),
      markRing: l(markRing, other.markRing),
      markTick: l(markTick, other.markTick),
    );
  }
}

extension OshoTokensContext on BuildContext {
  OshoTokens get osho => OshoTokens.of(this);
}
