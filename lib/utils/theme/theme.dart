import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:osho/common/widgets/atelier/o_icon.dart';
import 'package:osho/utils/theme/osho_tokens.dart';
import 'package:osho/utils/theme/osho_type.dart';

/// Thème « Atelier » : papier plat, angles de 2 px, aucune ombre.
/// Tout est dérivé des [OshoTokens] ; aucun écran ne fixe sa propre couleur.
class OshoTheme {
  OshoTheme._();

  /// Le seul rayon de l'app.
  static const double radius = 2;
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(radius));

  /// Cibles tactiles : 48 px, le tailleur travaille debout et d'une main.
  static const double target = 48;
  static const double buttonHeight = 52;

  static ThemeData lightTheme = _build(OshoTokens.light, Brightness.light);
  static ThemeData darkTheme = _build(OshoTokens.dark, Brightness.dark);

  /// Barres système transparentes : le papier de l'écran passe dessous
  /// (affichage bord à bord), icônes lisibles dans les deux thèmes.
  static SystemUiOverlayStyle systemOverlay(Brightness brightness) {
    final light = brightness == Brightness.light;
    final t = light ? OshoTokens.light : OshoTokens.dark;
    final iconBrightness = light ? Brightness.dark : Brightness.light;
    return SystemUiOverlayStyle(
      statusBarColor: t.bg.withValues(alpha: 0),
      statusBarIconBrightness: iconBrightness,
      // iOS : décrit le fond, pas les icônes.
      statusBarBrightness: brightness,
      systemNavigationBarColor: t.bg.withValues(alpha: 0),
      systemNavigationBarDividerColor: t.bg.withValues(alpha: 0),
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    );
  }

  static ThemeData _build(OshoTokens t, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.primaryFill,
      onPrimary: t.primaryInk,
      primaryContainer: t.accentBg,
      onPrimaryContainer: t.accentInk,
      secondary: t.accent,
      onSecondary: t.bg,
      secondaryContainer: t.accentBg,
      onSecondaryContainer: t.accentInk,
      tertiary: t.accent,
      onTertiary: t.bg,
      error: t.dangerInk,
      onError: t.bg,
      errorContainer: t.dangerBg,
      onErrorContainer: t.dangerInk,
      surface: t.bg,
      onSurface: t.ink,
      onSurfaceVariant: t.muted,
      surfaceContainerLowest: t.surface,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surface,
      surfaceContainerHigh: t.surface,
      surfaceContainerHighest: t.surface,
      outline: t.hairline,
      outlineVariant: t.hairline,
      shadow: t.bg.withValues(alpha: 0),
      scrim: t.scrim,
      surfaceTint: t.bg.withValues(alpha: 0),
      inverseSurface: t.ink,
      onInverseSurface: t.bg,
      inversePrimary: t.primaryInk,
    );

    const shape = RoundedRectangleBorder(borderRadius: borderRadius);
    final buttonText =
        OType.text(15, t.ink, weight: FontWeight.w500, height: 1.2);

    final textTheme = TextTheme(
      displaySmall: OType.display(36, t.ink),
      headlineLarge: OType.display(32, t.ink),
      headlineMedium: OType.display(28, t.ink),
      headlineSmall: OType.display(24, t.ink),
      titleLarge: OType.display(20, t.ink, weight: FontWeight.w600),
      titleMedium: OType.text(OType.body, t.ink, weight: FontWeight.w500),
      titleSmall:
          OType.text(OType.secondary, t.ink, weight: FontWeight.w600),
      bodyLarge: OType.text(OType.body, t.ink, height: 1.5),
      bodyMedium: OType.text(OType.body, t.ink),
      bodySmall: OType.text(OType.secondary, t.muted),
      labelLarge: buttonText,
      labelMedium: OType.text(OType.caption, t.muted),
      labelSmall: OType.smallCaps(t.muted),
    );

    final noShadow = WidgetStatePropertyAll<Color>(t.bg.withValues(alpha: 0));

    OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [t],
      fontFamily: OType.sans,
      textTheme: textTheme,
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.bg,
      dividerColor: t.hairline,
      splashColor: t.ink.withValues(alpha: 0.06),
      highlightColor: t.ink.withValues(alpha: 0.04),
      hoverColor: t.ink.withValues(alpha: 0.04),
      focusColor: t.accent.withValues(alpha: 0.12),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const OIcon(OIcons.arrowLeft),
        closeButtonIconBuilder: (_) => const OIcon(OIcons.close),
      ),
      iconTheme: IconThemeData(color: t.ink, size: 22),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: t.bg,
        surfaceTintColor: t.bg.withValues(alpha: 0),
        foregroundColor: t.ink,
        iconTheme: IconThemeData(color: t.ink, size: 22),
        actionsIconTheme: IconThemeData(color: t.ink, size: 22),
        titleTextStyle: OType.display(20, t.ink, weight: FontWeight.w600),
        shape: Border(bottom: BorderSide(color: t.hairline)),
        systemOverlayStyle: systemOverlay(brightness),
      ),
      dividerTheme: DividerThemeData(color: t.hairline, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: noShadow,
          minimumSize:
              const WidgetStatePropertyAll(Size(target, buttonHeight)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20)),
          shape: const WidgetStatePropertyAll(shape),
          textStyle: WidgetStatePropertyAll(buttonText),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? t.hairline : t.primaryFill),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? t.muted : t.primaryInk),
          overlayColor:
              WidgetStatePropertyAll(t.primaryInk.withValues(alpha: 0.1)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize:
              const WidgetStatePropertyAll(Size(target, buttonHeight)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20)),
          shape: const WidgetStatePropertyAll(shape),
          textStyle: WidgetStatePropertyAll(buttonText),
          foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.disabled) ? t.muted : t.ink),
          side: WidgetStateProperty.resolveWith((s) => BorderSide(
              color: s.contains(WidgetState.disabled) ? t.hairline : t.ink)),
          backgroundColor: WidgetStatePropertyAll(t.bg.withValues(alpha: 0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(target, target)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8)),
          shape: const WidgetStatePropertyAll(shape),
          textStyle: WidgetStatePropertyAll(buttonText),
          foregroundColor: WidgetStatePropertyAll(t.accent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(target, target)),
          shape: const WidgetStatePropertyAll(shape),
          foregroundColor: WidgetStatePropertyAll(t.ink),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        labelStyle: OType.text(OType.body, t.muted),
        floatingLabelStyle: OType.text(OType.secondary, t.muted),
        hintStyle: OType.text(OType.body, t.muted),
        helperStyle: OType.text(OType.caption, t.muted),
        errorStyle: OType.text(OType.caption, t.dangerInk),
        errorMaxLines: 3,
        prefixIconColor: t.muted,
        suffixIconColor: t.muted,
        border: field(t.hairline),
        enabledBorder: field(t.hairline),
        disabledBorder: field(t.hairline),
        focusedBorder: field(t.ink, 1.5),
        errorBorder: field(t.dangerInk),
        focusedErrorBorder: field(t.dangerInk, 1.5),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: shape,
        side: BorderSide(color: t.ink, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? t.primaryFill
                : t.bg.withValues(alpha: 0)),
        checkColor: WidgetStatePropertyAll(t.primaryInk),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.ink,
        refreshBackgroundColor: t.surface,
        linearTrackColor: t.hairline,
        circularTrackColor: t.bg.withValues(alpha: 0),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
        backgroundColor: t.surface,
        modalBackgroundColor: t.surface,
        surfaceTintColor: t.bg.withValues(alpha: 0),
        shadowColor: t.bg.withValues(alpha: 0),
        modalBarrierColor: t.scrim,
        constraints: const BoxConstraints(minWidth: double.infinity),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: t.hairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: t.surface,
        surfaceTintColor: t.bg.withValues(alpha: 0),
        shadowColor: t.bg.withValues(alpha: 0),
        barrierColor: t.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: t.hairline),
        ),
        titleTextStyle: OType.display(22, t.ink, weight: FontWeight.w600),
        contentTextStyle: OType.text(OType.body, t.ink, height: 1.5),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        contentTextStyle: OType.text(OType.body, t.bg),
        shape: shape,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.ink,
        selectionColor: t.accent.withValues(alpha: 0.24),
        selectionHandleColor: t.accent,
      ),
    );
  }
}
