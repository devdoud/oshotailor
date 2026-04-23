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
              const SizedBox(height: 20),
              _buildClientCard(),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(OImages.modelstore, width: 50, height: 50, fit: BoxFit.cover),
            ),
            title: Text(widget.order.modelName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Montant: ${NumberFormat('#,###').format(widget.order.amount)} F"),
          ),
          const Divider(),
          _buildActionTile(Iconsax.image, "Photos de référence", () => Get.to(() => const ModelPhotosScreen())),
        ],
      ),
    );
  }

  Widget _buildClientCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informations Client", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Iconsax.user, size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              Text(widget.order.customerName),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Iconsax.call, size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              Text(widget.order.customerPhone),
            ],
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
