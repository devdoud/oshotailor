import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/order/model_photos.dart';
import 'package:osho/utils/constants/image_strings.dart';
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

  /// METTRE À JOUR LE STATUT RÉEL DANS SUPABASE
  Future<void> _updateStatus(OrderStatus status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status.name})
          .eq('id', widget.order.id);

      setState(() {
        currentStatus = status;
      });

      // Rafraîchir le tableau de bord des commandes à jour
      HomeController.instance.fetchDashboardData();

      Get.snackbar("Succès", "Statut mis à jour : ${status.name}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de mettre à jour le statut");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const OAppBar(
        title: Text('Détails de la Commande', style: TextStyle(fontWeight: FontWeight.bold)),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 20),
              _buildInfoCard(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: _buildActionBottomBar(),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (currentStatus) {
      case OrderStatus.newOrder: color = Colors.blue; text = "Nouvelle"; break;
      case OrderStatus.processing: color = Colors.orange; text = "En cours de confection"; break;
      case OrderStatus.completed: color = Colors.green; text = "Prête / Terminée"; break;
      case OrderStatus.delivered: color = Colors.grey; text = "Livrée"; break;
      case OrderStatus.cancelled: color = Colors.red; text = "Annulée"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.order.thumbnailUrl != null) {
                      Get.dialog(
                        Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              InteractiveViewer(
                                panEnabled: true,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(widget.order.thumbnailUrl!, fit: BoxFit.contain),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Get.back()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: OColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      image: widget.order.thumbnailUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.order.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.order.thumbnailUrl == null
                        ? const Icon(Iconsax.image, color: OColors.primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.modelName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Réf: #${widget.order.id.length > 8 ? widget.order.id.substring(0, 8).toUpperCase() : widget.order.id}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          ..._buildOrderItemsSections(),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItemsSections() {
    if (widget.order.orderItems == null || widget.order.orderItems!.isEmpty) return [];

    final item = widget.order.orderItems!.first;
    final config = item['configuration_snapshot'];
    final customization = item['customization_details'];
    final measurements = item['measurement_snapshot'];

    List<Widget> sections = [];
    if (config != null && config is Map) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildJsonSection('Configuration (Tissu, etc.)', Map<String, dynamic>.from(config)));
    }
    if (customization != null && customization is Map) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildJsonSection('Personnalisation', Map<String, dynamic>.from(customization)));
    }
    if (measurements != null && measurements is Map) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildJsonSection('Mesures Appliquées', Map<String, dynamic>.from(measurements)));
    }
    
    return sections;
  }

  Widget _buildJsonSection(String title, Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF333333)),
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

  Widget _buildActionBottomBar() {
    if (currentStatus == OrderStatus.delivered || currentStatus == OrderStatus.cancelled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          if (currentStatus == OrderStatus.newOrder) ...[
            Expanded(child: _buildButton("Refuser", Colors.red.withOpacity(0.1), Colors.red, () => _updateStatus(OrderStatus.cancelled))),
            const SizedBox(width: 10),
            Expanded(child: _buildButton("Accepter", OColors.primary, Colors.white, () => _updateStatus(OrderStatus.processing))),
          ] else if (currentStatus == OrderStatus.processing) ...[
            Expanded(child: _buildButton("Marquer comme Terminée", Colors.green, Colors.white, () => _updateStatus(OrderStatus.completed))),
          ] else if (currentStatus == OrderStatus.completed) ...[
            Expanded(child: _buildButton("Confirmer la Livraison", Colors.black, Colors.white, () => _updateStatus(OrderStatus.delivered))),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color text, VoidCallback onPress) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: text, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: OColors.primary),
      title: Text(title),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16),
      onTap: onTap,
    );
  }
}
