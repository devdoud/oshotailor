import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderStatus currentStatus;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
  }

  Future<void> _updateStatus(OrderStatus status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status.name}).eq('id', widget.order.id);

      setState(() {
        currentStatus = status;
      });

      HomeController.instance.fetchDashboardData();

      Get.snackbar(
        'Succès',
        'Statut mis à jour : ${status.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text(
          'Détails de la Commande',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFF7F7F9),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── Statut ──────────────────────────────────────────────
          _buildStatusBadge(),
          const SizedBox(height: 16),

          // ── Résumé de la commande ────────────────────────────────
          _buildOrderSummaryCard(),
          const SizedBox(height: 16),

          // ── Articles commandés ───────────────────────────────────
          if (widget.order.orderItems != null &&
              widget.order.orderItems!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Articles Commandés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            ...widget.order.orderItems!.map((item) => _buildItemCard(item)),
            const SizedBox(height: 4),
          ],
        ],
      ),
      bottomNavigationBar: _buildActionBottomBar(),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // WIDGETS
  // ────────────────────────────────────────────────────────────────

  Widget _buildStatusBadge() {
    final config = _statusConfig(currentStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: config.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final hasNetworkImage = widget.order.thumbnailUrl != null &&
        widget.order.thumbnailUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: hasNetworkImage
                ? Image.network(
                    widget.order.thumbnailUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                : _fallbackImage(),
          ),
          const SizedBox(width: 16),
          // Nom + Montant + Ref
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.modelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Iconsax.money, size: 15, color: OColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormat('#,###', 'fr_FR').format(widget.order.amount)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: OColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Réf : #${_shortId(widget.order.id).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Iconsax.calendar, size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy', 'fr_FR')
                          .format(widget.order.createdAt.toLocal()),
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Carte pour un article de commande
  Widget _buildItemCard(Map<String, dynamic> item) {
    final productData = item['product'] ?? item['products'] ?? {};
    final bool hasProduct =
        productData is Map && productData.isNotEmpty;

    // Nom
    dynamic rawTitle = hasProduct
        ? (productData['name'] ??
            productData['title'] ??
            productData['model_name'])
        : (item['name'] ??
            item['model_name'] ??
            item['title'] ??
            item['product_name']);
    String title = _resolveMultiLang(rawTitle) ?? 'Article inconnu';

    // Image
    final String? imageUrl = hasProduct
        ? _nonEmpty(productData['thumbnail'] ??
            productData['image'] ??
            productData['image_url'] ??
            productData['photo'])
        : _nonEmpty(
            item['thumbnail'] ?? item['image'] ?? item['photo_url']);

    final qty = item['quantity']?.toString() ?? '1';

    final config = item['configuration_snapshot'];
    final customization = item['customization_details'];
    final measurements = item['measurement_snapshot'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête article
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null) ...[
                GestureDetector(
                  onTap: () => _showFullImage(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(size: 64),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: OColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qté : $qty',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: OColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sections détails
          if (_hasData(config) || _hasData(customization) || _hasData(measurements)) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF0F0F0), height: 1),
            const SizedBox(height: 14),
          ],

          if (_hasData(config))
            _buildDataSection(
              icon: Iconsax.brush_2,
              title: 'Configuration (tissu, etc.)',
              data: Map<String, dynamic>.from(config as Map),
            ),

          if (_hasData(customization))
            _buildDataSection(
              icon: Iconsax.edit,
              title: 'Personnalisation',
              data: Map<String, dynamic>.from(customization as Map),
            ),

          if (_hasData(measurements))
            _buildDataSection(
              icon: Iconsax.ruler,
              title: 'Mesures Appliquées',
              data: Map<String, dynamic>.from(measurements as Map),
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildDataSection({
    required IconData icon,
    required String title,
    required Map<String, dynamic> data,
    bool isLast = false,
  }) {
    final entries = data.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: entries.map((e) {
                String displayKey = e.key.replaceAll('_', ' ');
                if (displayKey.isNotEmpty) {
                  displayKey =
                      displayKey[0].toUpperCase() + displayKey.substring(1);
                }
                String displayValue;
                if (e.value is Map) {
                  displayValue = (e.value as Map)
                      .entries
                      .map((inner) => '${inner.key}: ${inner.value}')
                      .join(', ');
                } else if (e.value is List) {
                  displayValue = (e.value as List).join(', ');
                } else {
                  displayValue = e.value.toString();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          displayKey,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          displayValue,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF333333)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }



  Widget? _buildActionBottomBar() {
    if (currentStatus == OrderStatus.delivered ||
        currentStatus == OrderStatus.cancelled) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          if (currentStatus == OrderStatus.newOrder) ...[
            Expanded(
              child: _actionButton(
                'Refuser',
                Colors.red.shade50,
                Colors.red,
                () => _updateStatus(OrderStatus.cancelled),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                'Accepter',
                OColors.primary,
                Colors.white,
                () => _updateStatus(OrderStatus.processing),
              ),
            ),
          ] else if (currentStatus == OrderStatus.processing) ...[
            Expanded(
              child: _actionButton(
                'Marquer comme Terminée',
                Colors.green,
                Colors.white,
                () => _updateStatus(OrderStatus.completed),
              ),
            ),
          ] else if (currentStatus == OrderStatus.completed) ...[
            Expanded(
              child: _actionButton(
                'Confirmer la Livraison',
                Colors.black,
                Colors.white,
                () => _updateStatus(OrderStatus.delivered),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────

  Widget _actionButton(
      String label, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }

  Widget _fallbackImage({double size = 72}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Iconsax.image, color: OColors.primary, size: 28),
    );
  }

  void _showFullImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color color, String label}) _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return (color: Colors.blue, label: 'Nouvelle commande');
      case OrderStatus.processing:
        return (color: Colors.orange, label: 'En cours de confection');
      case OrderStatus.completed:
        return (color: Colors.green, label: 'Prête / Terminée');
      case OrderStatus.delivered:
        return (color: Colors.grey, label: 'Livrée');
      case OrderStatus.cancelled:
        return (color: Colors.red, label: 'Annulée');
    }
  }

  String? _resolveMultiLang(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    if (value is Map) {
      final fr = value['fr'];
      if (fr is String && fr.trim().isNotEmpty) return fr.trim();
      final en = value['en'];
      if (en is String && en.trim().isNotEmpty) return en.trim();
      for (final v in value.values) {
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  String? _nonEmpty(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _hasData(dynamic value) =>
      value != null && value is Map && value.isNotEmpty;

  String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}...';
}
