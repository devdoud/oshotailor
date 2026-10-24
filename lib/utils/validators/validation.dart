/// Validateurs de formulaires. Messages courts, en français.
class OValidator {
  OValidator._();

  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) return '$fieldName requis.';
    return null;
  }

  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'E-mail requis.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v)) {
      return 'E-mail invalide.';
    }
    return null;
  }

  /// Connexion : le mot de passe existant est seulement requis. Les règles
  /// de robustesse ne s'appliquent qu'à la création d'un mot de passe.
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis.';
    return null;
  }

  /// Nouveau mot de passe.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis.';
    if (value.length < 8) return '8 caractères minimum.';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Une majuscule requise.';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Un chiffre requis.';
    return null;
  }

  static String? validateWorkshopName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nom requis.';
    if (v.length < 2) return 'Nom trop court.';
    if (v.length > 60) return '60 caractères maximum.';
    return null;
  }

  /// Téléphone international, facultatif : `+`, chiffres, espaces, tirets,
  /// points et parenthèses ; 8 à 15 chiffres.
  static String? validatePhoneNumber(String? value, {bool required = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return required ? 'Téléphone requis.' : null;
    if (!RegExp(r'^\+?[\d\s().-]+$').hasMatch(v)) return 'Numéro invalide.';
    final digits = v.replaceAll(RegExp(r'\D'), '').length;
    if (digits < 8 || digits > 15) return 'Numéro invalide.';
    return null;
  }
}
