import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/order_item_section.dart';
import 'package:osho/common/widgets/atelier/status_tones.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/services/assignment_service.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

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
        OLoaders.errorSnackBar(title: 'Commande indisponible.');
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
      OLoaders.successSnackBar(title: successMessage);

      if (Get.isRegistered<TailorOrdersController>()) {
        await Get.find<TailorOrdersController>().fetchOrders();
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchDashboardData();
      }

      await _loadOrder();
    } catch (e) {
      debugPrint('Assignment update failed: $e');
      OLoaders.errorSnackBar(title: 'Action impossible. Réessayez.');
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
      appBar: AppBar(
        title: const Text('Commande'),
        actions: [
          OIconButton(
            icon: OIcons.refresh,
            tooltip: 'Actualiser',
            onPressed: _isLoading ? null : _loadOrder,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: order == null
          ? (_isLoading
              ? const OLoader(size: 28)
              : Center(
                  child: OEmptyState(
                    'Impossible d’afficher cette commande.',
                    action: TextButton(
                      onPressed: _loadOrder,
                      child: const Text('Réessayer'),
                    ),
                  ),
                ))
          : RefreshIndicator(
              onRefresh: _loadOrder,
              child: ListView(
                // Without an action bar, keep clear of the system nav bar.
                padding: EdgeInsets.fromLTRB(kGutter, 20, kGutter,
                    32 + MediaQuery.paddingOf(context).bottom),
                children: [
                  _buildHeader(context, order),
                  if (order.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const OSectionLabel('Notes'),
                    const SizedBox(height: 8),
                    Text(order.notes.trim(),
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                  if (order.orderItems.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    OSectionLabel(order.orderItems.length > 1
                        ? 'Articles (${order.orderItems.length})'
                        : 'Article'),
                    const SizedBox(height: 4),
                    const OHairline(),
                    for (final item in order.orderItems)
                      OrderItemSection(item: item),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: order == null ? null : _buildActions(order),
    );
  }

  Widget _buildHeader(BuildContext context, TailorOrder order) {
    final t = context.osho;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            OStatusTag(order.statusLabel, order.status.tone),
            const Spacer(),
            Text('N° ${shortRef(order.orderId)}',
                style: OType.text(OType.caption, t.muted).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(order.clientName,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 4),
        Text(order.modelName, style: OType.text(OType.body, t.muted)),
        const SizedBox(height: 12),
        Text(formatFcfa(order.amount), style: OType.price(24, t.ink)),
        const SizedBox(height: 16),
        const OHairline(),
        OSpecRow(label: 'Reçue le', value: _formatDate(order.createdAt)),
        OSpecRow(label: 'Téléphone', value: order.clientPhone, tabular: true),
      ],
    );
  }

  Widget? _buildActions(TailorOrder order) {
    if (order.assignmentId.isEmpty) {
      return null;
    }

    if (order.canAcceptOrReject) {
      return OActionBar(children: [
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (!await confirmReject(context)) return;
                  await _updateAssignment(
                    action: () =>
                        AssignmentService.rejectOrder(order.assignmentId),
                    successMessage: 'Commande refusée.',
                  );
                },
          child: const Text('Refuser'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () => _updateAssignment(
                    action: () =>
                        AssignmentService.acceptOrder(order.assignmentId),
                    successMessage: 'Commande acceptée.',
                  ),
          child: const Text('Accepter'),
        ),
      ]);
    }

    if (order.canStart) {
      return OActionBar(children: [
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () => _updateAssignment(
                    action: () =>
                        AssignmentService.startOrder(order.assignmentId),
                    successMessage: 'Confection démarrée.',
                  ),
          child: const Text('Commencer'),
        ),
      ]);
    }

    if (order.canComplete) {
      return OActionBar(children: [
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () => _updateAssignment(
                    action: () =>
                        AssignmentService.completeOrder(order.assignmentId),
                    successMessage: 'Commande terminée.',
                  ),
          child: const Text('Terminer'),
        ),
      ]);
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(date.toLocal());
  }
}
