import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/order_item_section.dart';
import 'package:osho/common/widgets/atelier/status_tones.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderStatus currentStatus;
  bool _isSubmitting = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
  }

  Future<void> _updateStatus(OrderStatus status) async {
    setState(() => _isSubmitting = true);
    try {
      await _supabase
          .from('orders')
          .update({'status': status.name}).eq('id', widget.order.id);

      setState(() {
        currentStatus = status;
      });

      HomeController.instance.fetchDashboardData();

      OLoaders.successSnackBar(
        title: 'Succès',
        message: 'Statut mis à jour : ${status.label}',
      );
    } catch (e) {
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de mettre à jour le statut',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final order = widget.order;
    final items = order.orderItems ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Commande')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 20, kGutter, 32),
        children: [
          Row(
            children: [
              OStatusTag(currentStatus.label, currentStatus.tone),
              const Spacer(),
              Text('N° ${shortRef(order.id)}',
                  style: OType.text(OType.caption, t.muted).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OThumb(
                url: order.thumbnailUrl,
                size: 72,
                onTap: order.thumbnailUrl == null
                    ? null
                    : () => showFullImage(context, order.thumbnailUrl!),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(order.modelName,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    const SizedBox(height: 8),
                    Text(formatFcfa(order.amount),
                        style: OType.price(20, t.ink)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const OHairline(),
          OSpecRow(label: 'Client', value: order.customerName),
          OSpecRow(
              label: 'Téléphone', value: order.customerPhone, tabular: true),
          OSpecRow(
            label: 'Reçue le',
            value: DateFormat('d MMM yyyy', 'fr_FR')
                .format(order.createdAt.toLocal()),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 28),
            OSectionLabel(
                items.length > 1 ? 'Articles (${items.length})' : 'Article'),
            const SizedBox(height: 4),
            const OHairline(),
            for (final item in items) OrderItemSection(item: item),
          ],
        ],
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget? _buildActionBar() {
    final busy = _isSubmitting;
    switch (currentStatus) {
      case OrderStatus.newOrder:
        return OActionBar(children: [
          OutlinedButton(
            onPressed: busy ? null : () => _updateStatus(OrderStatus.cancelled),
            child: const Text('Refuser'),
          ),
          ElevatedButton(
            onPressed:
                busy ? null : () => _updateStatus(OrderStatus.processing),
            child: const Text('Accepter'),
          ),
        ]);
      case OrderStatus.processing:
        return OActionBar(children: [
          ElevatedButton(
            onPressed: busy ? null : () => _updateStatus(OrderStatus.completed),
            child: const Text('Marquer comme terminée'),
          ),
        ]);
      case OrderStatus.completed:
        return OActionBar(children: [
          ElevatedButton(
            onPressed: busy ? null : () => _updateStatus(OrderStatus.delivered),
            child: const Text('Confirmer la livraison'),
          ),
        ]);
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}
