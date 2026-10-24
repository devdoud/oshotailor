import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';

/// Montant en FCFA, tel qu'établi à l'atelier.
/// Fraunces n'a pas d'espace fine (U+202F) : on prend l'insécable U+00A0.
String formatFcfa(double amount) =>
    '${NumberFormat('#,##0', 'fr_FR').format(amount).replaceAll(' ', ' ')} FCFA';

/// Référence courte d'une commande.
String shortRef(String id) =>
    (id.length <= 8 ? id : id.substring(0, 8)).toUpperCase();

/// Un article de commande : photo, nom, quantité, puis configuration,
/// personnalisation et mesures en tableaux de valeurs.
class OrderItemSection extends StatelessWidget {
  const OrderItemSection({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final product = item['product'] ?? item['products'];
    final hasProduct = product is Map && product.isNotEmpty;

    final title = _resolveText(hasProduct
            ? (product['name'] ?? product['title'] ?? product['model_name'])
            : (item['name'] ??
                item['model_name'] ??
                item['title'] ??
                item['product_name'])) ??
        'Article sans nom';

    final imageUrl = _resolveText(hasProduct
        ? (product['thumbnail'] ??
            product['image'] ??
            product['image_url'] ??
            product['photo'])
        : (item['thumbnail'] ?? item['image'] ?? item['photo_url']));

    final qty = item['quantity']?.toString();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OThumb(
                url: imageUrl,
                size: 72,
                semanticLabel: 'Agrandir la photo de $title',
                onTap: imageUrl == null
                    ? null
                    : () => showFullImage(context, imageUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: OType.display(18, t.ink, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OSpecRow(label: 'Quantité', value: qty, tabular: true),
          _DataTable(title: 'Configuration', data: item['configuration_snapshot']),
          _DataTable(
              title: 'Personnalisation', data: item['customization_details']),
          _DataTable(
              title: 'Mesures', data: item['measurement_snapshot'], tabular: true),
        ],
      ),
    );
  }

  static String? _resolveText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    if (value is Map) {
      final lang = Get.locale?.languageCode;
      for (final key in [lang, 'fr', 'en']) {
        final v = value[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      for (final v in value.values) {
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({required this.title, required this.data, this.tabular = false});

  final String title;
  final dynamic data;
  final bool tabular;

  static String _label(String key) {
    final s = key.replaceAll('_', ' ').trim();
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  static String? _value(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v ? 'Oui' : 'Non';
    if (v is Map) {
      final parts = v.entries
          .where((e) => !OSpecRow.isEmptyValue(_value(e.value)))
          .map((e) => '${_label(e.key.toString())} : ${_value(e.value)}');
      return parts.isEmpty ? null : parts.join(', ');
    }
    if (v is List) {
      final parts = v.map(_value).where((s) => !OSpecRow.isEmptyValue(s));
      return parts.isEmpty ? null : parts.join(', ');
    }
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (data is! Map) return const SizedBox.shrink();
    final rows = (data as Map)
        .entries
        .map((e) => (label: _label(e.key.toString()), value: _value(e.value)))
        .where((r) => !OSpecRow.isEmptyValue(r.value))
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OSectionLabel(title),
          const SizedBox(height: 4),
          for (final r in rows)
            OSpecRow(label: r.label, value: r.value, tabular: tabular),
        ],
      ),
    );
  }
}

/// Photo en plein écran, zoomable.
void showFullImage(BuildContext context, String url) {
  final t = context.osho;
  showDialog<void>(
    context: context,
    barrierColor: t.scrim,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(kGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OIconButton(
            icon: OIcons.close,
            tooltip: 'Fermer',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          Flexible(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
