import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/status_tones.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/order/order.dart';
import 'package:osho/features/tailor_dashboard/screens/tailor_order_detail_screen.dart';
import 'package:osho/navigation_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final t = context.osho;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(kGutter, 8, kGutter, 32),
            children: [
              Row(
                children: [
                  const OshoLogo(height: 24),
                  const Spacer(),
                  OIconButton(
                    icon: OIcons.refresh,
                    tooltip: 'Actualiser',
                    onPressed: controller.fetchDashboardData,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text('Tableau de bord', style: text.headlineMedium),
              ),
              const SizedBox(height: 4),
              Text('Gérez vos confections en temps réel',
                  style: OType.text(OType.body, t.muted)),
              const SizedBox(height: 24),
              Obx(
                () => _KeyFigures(figures: [
                  (label: 'Nouvelles', value: controller.newOrdersCount.value),
                  (label: 'En cours', value: controller.inProgressCount.value),
                  (label: 'Terminées', value: controller.completedCount.value),
                ]),
              ),
              const SizedBox(height: 32),
              OSectionLabel(
                'Commandes récentes',
                trailing: TextButton(
                  onPressed: () {
                    if (Get.isRegistered<NavigationController>()) {
                      Get.find<NavigationController>().selectedIndex.value = 1;
                      return;
                    }
                    Get.to(() => const OrderScreen());
                  },
                  child: const Text('Voir tout'),
                ),
              ),
              const OHairline(),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.recentOrders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: OLoader(size: 28),
                  );
                }
                if (controller.recentOrders.isEmpty) {
                  return const OEmptyState('Aucune commande récente.');
                }
                return Column(
                  children: [
                    for (final order in controller.recentOrders)
                      _RecentOrderRow(order: order),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Les chiffres clés : un chiffre, son libellé en petites capitales, un filet.
class _KeyFigures extends StatelessWidget {
  const _KeyFigures({required this.figures});

  final List<({String label, int value})> figures;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: t.hairline)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < figures.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, color: t.hairline),
              Expanded(
                child: MergeSemantics(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(i == 0 ? 0 : 14, 16, 8, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${figures[i].value}',
                            style: OType.display(36, t.ink).copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ])),
                        const SizedBox(height: 6),
                        Text(figures[i].label.toUpperCase(),
                            style: OType.smallCaps(t.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final date = DateFormat('d MMM yyyy', 'fr_FR').format(order.createdAt);
    final meta = [
      if (order.customerName.trim().isNotEmpty) order.customerName.trim(),
      date,
    ].join(' · ');

    return MergeSemantics(
      child: InkWell(
        onTap: () => Get.to(() => TailorOrderDetailScreen(orderId: order.id)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.hairline)),
          ),
          child: Row(
            children: [
              OThumb(url: order.thumbnailUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.modelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OType.text(OType.body, t.ink,
                            weight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OType.text(OType.secondary, t.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OStatusTag(order.status.label, order.status.tone),
            ],
          ),
        ),
      ),
    );
  }
}
