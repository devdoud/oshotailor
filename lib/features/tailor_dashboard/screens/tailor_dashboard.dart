import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/order_item_section.dart';
import 'package:osho/common/widgets/atelier/status_tones.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';
import 'package:osho/features/tailor_dashboard/screens/tailor_order_detail_screen.dart';

class TailorDashboardScreen extends StatelessWidget {
  const TailorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GetBuilder<TailorOrdersController>(
      init: TailorOrdersController(),
      builder: (c) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(kGutter, 16, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Commandes', style: text.headlineMedium),
                      ),
                    ),
                    Obx(() => OIconButton(
                          icon: OIcons.refresh,
                          tooltip: 'Actualiser',
                          onPressed:
                              c.isLoading.value ? null : () => c.fetchOrders(),
                        )),
                  ],
                ),
              ),
              Obx(() => _StatusTabs(
                    active: c.activeTab.value,
                    onSelect: c.switchTab,
                  )),
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value && c.orders.isEmpty) {
                    return const OLoader(size: 28);
                  }
                  return RefreshIndicator(
                    onRefresh: () => c.fetchOrders(),
                    child: c.orders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              OEmptyState('Aucune commande dans cet onglet.'),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                                kGutter, 0, kGutter, 24),
                            itemCount: c.orders.length,
                            itemBuilder: (context, index) => _OrderRow(
                              order: c.orders[index],
                              controller: c,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filtres par statut : l'onglet actif est souligné d'un trait d'encre.
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.active, required this.onSelect});

  final String active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kGutter - 4),
        child: Row(
          children: [
            for (final tab in TailorOrdersController.statusTabs)
              Semantics(
                button: true,
                selected: tab == active,
                child: InkWell(
                  onTap: () => onSelect(tab),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: tab == active
                              ? t.ink
                              : t.bg.withValues(alpha: 0),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      TailorOrdersController.tabLabels[tab] ?? tab,
                      style: OType.text(
                        OType.secondary,
                        tab == active ? t.ink : t.muted,
                        weight:
                            tab == active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.controller});

  final TailorOrder order;
  final TailorOrdersController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final hasActions =
        order.canAcceptOrReject || order.canStart || order.canComplete;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.hairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: InkWell(
              onTap: () => Get.to(
                  () => TailorOrderDetailScreen(orderId: order.orderId)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OThumb(url: order.thumbnailUrl, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OType.text(OType.body, t.ink,
                                weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(order.modelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OType.text(OType.secondary, t.muted)),
                        const SizedBox(height: 6),
                        OStatusTag(order.statusLabel, order.status.tone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatFcfa(order.amount),
                          style: OType.price(16, t.ink)),
                      const SizedBox(height: 4),
                      Text('N° ${shortRef(order.orderId)}',
                          style: OType.text(OType.caption, t.muted)
                              .copyWith(fontFeatures: const [
                            FontFeature.tabularFigures()
                          ])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (hasActions) ...[
            const SizedBox(height: 12),
            _actions(),
          ],
        ],
      ),
    );
  }

  Widget _actions() {
    final busy = controller.isLoading.value;
    if (order.canAcceptOrReject) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  busy ? null : () => controller.rejectOrder(order.assignmentId),
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Refuser'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  busy ? null : () => controller.acceptOrder(order.assignmentId),
              style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Accepter'),
            ),
          ),
        ],
      );
    }
    return ElevatedButton(
      onPressed: busy
          ? null
          : order.canStart
              ? () => controller.startOrder(order.assignmentId)
              : () => controller.completeOrder(order.assignmentId),
      style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
      child: Text(order.canStart ? 'Commencer' : 'Terminer'),
    );
  }
}
