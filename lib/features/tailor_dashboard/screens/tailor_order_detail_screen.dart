import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/services/assignment_service.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';
import 'package:osho/utils/constants/colors.dart';

class TailorOrderDetailScreen extends StatefulWidget {
  const TailorOrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrderData,
  });

  final String orderId;
  final Map<String, dynamic>? initialOrderData;

  @override
  State<TailorOrderDetailScreen> createState() =>
      _TailorOrderDetailScreenState();
}

class _TailorOrderDetailScreenState extends State<TailorOrderDetailScreen> {
  TailorOrder? _order;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderData != null) {
      _order = TailorOrder.fromJson(widget.initialOrderData!);
    }
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await TailorOrdersService.getOrderById(widget.orderId);
      if (!mounted) {
        return;
      }

      setState(() {
        _order = TailorOrder.fromJson(response);
      });
    } catch (e) {
      debugPrint('Error loading order: $e');
      if (mounted) {
        OLoaders.errorSnackBar(
          title: 'Erreur',
          message: 'Impossible de charger les details de la commande.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAssignment({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await action();
      OLoaders.successSnackBar(title: 'Succes', message: successMessage);

      if (Get.isRegistered<TailorOrdersController>()) {
        await Get.find<TailorOrdersController>().fetchOrders();
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchDashboardData();
      }

      await _loadOrder();
    } catch (e) {
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'La mise a jour a echoue : $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('Détails Commande', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: const Color(0xFFF7F7F9),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Commande introuvable.'))
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeaderCard(context, order),
                      if (order.orderItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildItemsList(order.orderItems),
                      ],
                      if (order.notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          title: 'Notes',
                          children: [
                            Text(
                              order.notes,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: order == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _buildActions(order),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, TailorOrder order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusLabel.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                'REF: #${_shortId(order.orderId).toUpperCase()}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Image du produit au lieu de l'avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: OColors.grey1,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: order.thumbnailUrl != null
                      ? Image.network(order.thumbnailUrl!, fit: BoxFit.cover)
                      : const Icon(Iconsax.image, color: OColors.primary, size: 30),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clientName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            fontSize: 22,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatAmount(order.amount),
                      style: const TextStyle(
                        color: OColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reçu le ${_formatDate(order.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Articles Commandés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        ...items.map((item) => _buildItemDetailCard(item)),
      ],
    );
  }

  Widget _buildItemDetailCard(Map<String, dynamic> item) {
    // Si l'Edge Function joint la table products, les infos seront dans 'product'
    final productData = item['product'] ?? item['products'] ?? {};
    final bool hasProduct = productData is Map && productData.isNotEmpty;

    final title = hasProduct 
        ? (productData['name'] ?? productData['title'] ?? productData['model_name']) 
        : (item['name'] ?? item['model_name'] ?? item['title'] ?? item['product_name'] ?? 'Article Inconnu');
        
    final imageUrl = hasProduct 
        ? (productData['thumbnail'] ?? productData['image'] ?? productData['image_url'] ?? productData['photo']) 
        : (item['thumbnail'] ?? item['image'] ?? item['photo_url']);

    // Si le titre recupéré est encore un Map (multi-langue), on extrait le français
    var finalTitle = title;
    if (finalTitle is Map) {
      finalTitle = finalTitle['fr'] ?? finalTitle['en'] ?? finalTitle.values.first;
    }

    final qty = item['quantity']?.toString() ?? '1';

    // Extraction des colonnes de données avancées
    final config = item['configuration_snapshot'];
    final customization = item['customization_details'];
    final measurements = item['measurement_snapshot'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de l'article avec Photo si disponible
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.8,
                              maxScale: 4.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl.toString(),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                onPressed: () => Get.back(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl.toString(),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finalTitle.toString(),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: OColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qté: $qty',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: OColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
          const SizedBox(height: 16),
          
          if (config != null && config is Map)
            _buildJsonSection('Configuration (Tissu, etc.)', Map<String, dynamic>.from(config)),
            
          if (customization != null && customization is Map)
            _buildJsonSection('Personnalisation', Map<String, dynamic>.from(customization)),
            
          if (measurements != null && measurements is Map)
            _buildJsonSection('Mesures Appliquées', Map<String, dynamic>.from(measurements)),
        ],
      ),
    );
  }

  Widget _buildJsonSection(String title, Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: data.entries.map((e) {
                if (e.value == null || e.value.toString().isEmpty) {
                  return const SizedBox.shrink();
                }
                
                String displayValue = e.value.toString();
                if (e.value is Map) {
                  displayValue = (e.value as Map).entries.map((inner) => '${inner.key}: ${inner.value}').join(',\n');
                } else if (e.value is List) {
                  displayValue = (e.value as List).join(', ');
                }
                
                // Formater la clé ("tissu_id" -> "Tissu Id")
                String displayKey = e.key.replaceAll('_', ' ');
                if (displayKey.isNotEmpty) {
                  displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);
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
                          style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          displayValue,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF333333)),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActions(TailorOrder order) {
    if (order.assignmentId.isEmpty) {
      return null;
    }

    if (order.canAcceptOrReject) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _updateAssignment(
                        action: () =>
                            AssignmentService.rejectOrder(order.assignmentId),
                        successMessage: 'Commande refusee.',
                      ),
              child: const Text('Refuser'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _updateAssignment(
                        action: () =>
                            AssignmentService.acceptOrder(order.assignmentId),
                        successMessage: 'Commande acceptee.',
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: OColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accepter'),
            ),
          ),
        ],
      );
    }

    if (order.canStart) {
      return ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () => _updateAssignment(
                  action: () =>
                      AssignmentService.startOrder(order.assignmentId),
                  successMessage: 'Commande demarree.',
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: const Text('Commencer'),
      );
    }

    if (order.canComplete) {
      return ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () => _updateAssignment(
                  action: () =>
                      AssignmentService.completeOrder(order.assignmentId),
                  successMessage: 'Commande terminee.',
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: const Text('Terminer'),
      );
    }

    return null;
  }

  String _formatAmount(double amount) {
    return '${NumberFormat('#,##0', 'fr_FR').format(amount)} FCFA';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(date.toLocal());
  }

  Color _statusColor(TailorOrderStatus status) {
    switch (status) {
      case TailorOrderStatus.pending:
        return Colors.blue;
      case TailorOrderStatus.accepted:
        return Colors.orange;
      case TailorOrderStatus.inProgress:
        return Colors.purple;
      case TailorOrderStatus.completed:
        return Colors.green;
      case TailorOrderStatus.rejected:
      case TailorOrderStatus.cancelled:
        return Colors.red;
      case TailorOrderStatus.unknown:
        return Colors.grey;
    }
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return '${id.substring(0, 8)}...';
  }
}
