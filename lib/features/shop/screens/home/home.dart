import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/atelier/status_tones.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';
import 'package:osho/features/tailor_dashboard/screens/tailor_order_detail_screen.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void _openOrders([String? tab]) {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().openOrders(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final t = context.osho;
    final text = Theme.of(context).textTheme;
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());

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
              Text(today[0].toUpperCase() + today.substring(1),
                  style: OType.text(OType.body, t.muted)),
              const SizedBox(height: 24),

              /// Next step first: orders waiting for an answer
              Obx(() {
                final pending = controller.pendingCount.value;
                if (pending == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _PendingCallout(
                    count: pending,
                    onTap: () => _openOrders('pending'),
                  ),
                );
              }),

              Obx(
                () => _KeyFigures(figures: [
                  (
                    label: 'À traiter',
                    value: controller.pendingCount.value,
                    tab: 'pending'
                  ),
                  (
                    label: 'Acceptées',
                    value: controller.acceptedCount.value,
                    tab: 'accepted'
                  ),
                  (
                    label: 'En cours',
                    value: controller.inProgressCount.value,
                    tab: 'in_progress'
                  ),
                  (
                    label: 'Terminées',
                    value: controller.completedCount.value,
                    tab: 'completed'
                  ),
                ], onOpen: _openOrders),
              ),
              const SizedBox(height: 32),
              OSectionLabel(
                'Commandes récentes',
                trailing: TextButton(
                  onPressed: _openOrders,
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
                if (controller.hasError.value &&
                    controller.recentOrders.isEmpty) {
                  return OEmptyState(
                    'Impossible de charger vos commandes.',
                    action: TextButton(
                      onPressed: controller.fetchDashboardData,
                      child: const Text('Réessayer'),
                    ),
                  );
                }
                if (controller.recentOrders.isEmpty) {
                  return const OEmptyState(
                      'Aucune commande pour le moment.\nVous serez notifié dès qu’un client commande.');
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

/// Bandeau « à traiter » : la prochaine action du tailleur, en un toucher.
class _PendingCallout extends StatelessWidget {
  const _PendingCallout({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final label = count > 1
        ? '$count commandes attendent votre réponse'
        : '1 commande attend votre réponse';
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: t.warnBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: t.warnBorder),
          borderRadius: OshoTheme.borderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: OType.text(OType.body, t.warnInk,
                          weight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text('Répondre',
                    style: OType.text(OType.secondary, t.warnInk,
                        weight: FontWeight.w500)),
                const SizedBox(width: 4),
                OIcon(OIcons.chevronRight, size: 18, color: t.warnInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Les chiffres clés, un par onglet de commandes : un chiffre, son libellé
/// en petites capitales, des filets. Chacun ouvre l'onglet correspondant.
class _KeyFigures extends StatelessWidget {
  const _KeyFigures({required this.figures, required this.onOpen});

  final List<({String label, int value, String tab})> figures;
  final void Function(String tab) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    Widget cell(int i) {
      final f = figures[i];
      return Expanded(
        child: Semantics(
          button: true,
          label: '${f.label} : ${f.value}',
          hint: 'Voir ces commandes',
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onOpen(f.tab),
            child: Padding(
              padding: EdgeInsets.fromLTRB(i.isEven ? 0 : 14, 16, 4, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${f.value}',
                            style: OType.display(32, t.ink).copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ])),
                        const SizedBox(height: 6),
                        Text(f.label.toUpperCase(),
                            style: OType.smallCaps(t.muted)),
                      ],
                    ),
                  ),
                  OIcon(OIcons.chevronRight, size: 16, color: t.muted),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget row(int a) => IntrinsicHeight(
          child: Row(children: [
            cell(a),
            VerticalDivider(width: 1, color: t.hairline),
            cell(a + 1),
          ]),
        );

    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: t.hairline)),
      ),
      child: Column(
        children: [row(0), const OHairline(), row(2)],
      ),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({required this.order});

  final TailorOrder order;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    final created = order.createdAt.toLocal();
    // Year only when it is not the current one: keeps the row on one line.
    final date = DateFormat(
            created.year == DateTime.now().year ? 'd MMM' : 'd MMM yyyy',
            'fr_FR')
        .format(created);

    return MergeSemantics(
      child: InkWell(
        onTap: () =>
            Get.to(() => TailorOrderDetailScreen(orderId: order.orderId)),
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
                    Text(order.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OType.text(OType.body, t.ink,
                            weight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('${order.modelName} · $date',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OType.text(OType.secondary, t.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OStatusTag(order.statusLabel, order.status.tone),
            ],
          ),
        ),
      ),
    );
  }
}
