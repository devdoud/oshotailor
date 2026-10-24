import 'package:flutter/material.dart';
import 'package:osho/common/widgets/atelier/o_icon.dart';
import 'package:osho/utils/theme/osho_tokens.dart';
import 'package:osho/utils/theme/osho_type.dart';
import 'package:osho/utils/theme/theme.dart';

export 'package:osho/common/widgets/atelier/o_icon.dart';
export 'package:osho/common/widgets/atelier/osho_logo.dart';
export 'package:osho/utils/theme/osho_tokens.dart';
export 'package:osho/utils/theme/osho_type.dart';

/// Gouttière latérale de toutes les pages.
const double kGutter = 16;

/// Filet de 1 px. La hiérarchie vient des filets, jamais d'une ombre.
class OHairline extends StatelessWidget {
  const OHairline({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: EdgeInsets.only(left: indent),
        color: context.osho.hairline,
      );
}

/// Intitulé de section en petites capitales.
class OSectionLabel extends StatelessWidget {
  const OSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(text.toUpperCase(),
                style: OType.smallCaps(context.osho.muted)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Ligne de spécification : libellé à gauche, valeur à droite, filet dessous.
/// Si la valeur est vide, la ligne entière disparaît.
class OSpecRow extends StatelessWidget {
  const OSpecRow({
    super.key,
    required this.label,
    required this.value,
    this.tabular = false,
    this.onTap,
    this.tapHint,
  });

  final String label;
  final String? value;

  /// Chiffres tabulaires, pour un tableau de mesures.
  final bool tabular;
  final VoidCallback? onTap;

  /// Libellé d'action lu par le lecteur d'écran quand la ligne est touchable.
  final String? tapHint;

  static bool isEmptyValue(String? v) {
    final s = v?.trim() ?? '';
    return s.isEmpty || s == 'null' || s == '-' || s == '—';
  }

  @override
  Widget build(BuildContext context) {
    if (isEmptyValue(value)) return const SizedBox.shrink();
    final t = context.osho;
    var valueStyle = OType.text(OType.body, t.ink, weight: FontWeight.w500);
    if (tabular) {
      valueStyle = valueStyle
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    }

    final row = Container(
      constraints: BoxConstraints(
          minHeight: onTap != null ? OshoTheme.target : 0),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: OType.text(OType.secondary, t.muted)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(value!.trim(),
                textAlign: TextAlign.right, style: valueStyle),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: OIcon(OIcons.chevronRight, size: 18, color: t.muted),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return MergeSemantics(child: row);
    return Semantics(
      button: true,
      hint: tapHint,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

enum OTone { warn, accent, ok, danger, neutral, quiet }

/// Étiquette de statut : rectangle à 2 px, fond, bordure et encre du même jeu.
/// Le libellé porte toujours le sens ; la couleur ne fait que l'appuyer.
class OStatusTag extends StatelessWidget {
  const OStatusTag(this.label, this.tone, {super.key});

  final String label;
  final OTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final (bg, border, ink) = switch (tone) {
      OTone.warn => (t.warnBg, t.warnBorder, t.warnInk),
      OTone.accent => (t.accentBg, t.accentBorder, t.accentInk),
      OTone.ok => (t.okBg, t.okBorder, t.okInk),
      OTone.danger => (t.dangerBg, t.dangerBorder, t.dangerInk),
      OTone.neutral => (t.surface, t.ink, t.ink),
      OTone.quiet => (t.bg, t.hairline, t.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: OshoTheme.borderRadius,
      ),
      child: Text(label,
          maxLines: 1,
          style: OType.text(OType.caption, ink,
              weight: FontWeight.w600, height: 1.3)),
    );
  }
}

/// Barre d'action en bas d'écran : filet en haut, fond `surface`,
/// zone sûre du bas respectée.
class OActionBar extends StatelessWidget {
  const OActionBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kGutter, 12, kGutter, 12),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: children[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Vignette d'image, angles à 2 px. Vide, elle montre l'emplacement.
class OThumb extends StatelessWidget {
  const OThumb({
    super.key,
    required this.url,
    this.size = 56,
    this.asset = false,
    this.onTap,
    this.semanticLabel,
  });

  final String? url;
  final double size;
  final bool asset;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final empty = Container(
      width: size,
      height: size,
      color: t.placeholder,
      alignment: Alignment.center,
      child: OIcon(OIcons.image, size: size * 0.38, color: t.placeholderInk),
    );
    final hasImage = url != null && url!.trim().isNotEmpty;
    final Widget image = !hasImage
        ? empty
        : asset
            ? Image.asset(url!, width: size, height: size, fit: BoxFit.cover)
            : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => empty,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : empty,
              );

    final framed = ClipRRect(
      borderRadius: OshoTheme.borderRadius,
      child: SizedBox(width: size, height: size, child: image),
    );

    if (onTap == null || !hasImage) {
      return Semantics(
        image: hasImage,
        label: hasImage ? semanticLabel : null,
        excludeSemantics: true,
        child: framed,
      );
    }
    return Semantics(
      button: true,
      label: semanticLabel ?? 'Agrandir la photo',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: OshoTheme.borderRadius,
        child: framed,
      ),
    );
  }
}

/// Une ligne de menu : titre, sous-titre, chevron, filet.
/// Sans `onTap`, la ligne est désactivée et l'indique par `trailingText`.
class OMenuRow extends StatelessWidget {
  const OMenuRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailingText,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.hairline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: OType.text(
                            OType.body, enabled ? t.ink : t.muted,
                            weight: FontWeight.w500)),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: OType.text(OType.secondary, t.muted)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (trailingText != null)
                Text(trailingText!,
                    style: OType.text(OType.caption, t.muted,
                        weight: FontWeight.w500))
              else if (enabled)
                OIcon(OIcons.chevronRight, size: 18, color: t.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Message d'état vide ou d'erreur : du texte, pas d'illustration.
class OEmptyState extends StatelessWidget {
  const OEmptyState(this.message, {super.key, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              textAlign: TextAlign.center,
              style: OType.text(OType.body, context.osho.muted)),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

/// Bouton-icône seul : toujours nommé par un `tooltip`, cible de 48 px.
class OIconButton extends StatelessWidget {
  const OIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: OIcon(icon,
          color: onPressed == null ? context.osho.muted : context.osho.ink),
    );
  }
}

/// Demande de confirmation avant une action irréversible ou engageante.
/// Renvoie `true` seulement si l'utilisateur confirme.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final t = context.osho;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(foregroundColor: t.ink),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(
              foregroundColor: destructive ? t.dangerInk : t.accent),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Refuser une commande est définitif : toujours confirmé.
Future<bool> confirmReject(BuildContext context) => confirmAction(
      context,
      title: 'Refuser cette commande ?',
      message: 'Vous ne pourrez plus l’accepter ensuite.',
      confirmLabel: 'Refuser',
      destructive: true,
    );
