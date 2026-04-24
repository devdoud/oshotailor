import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';
import 'package:osho/features/tailor_dashboard/screens/tailor_order_detail_screen.dart';
import 'package:osho/utils/constants/colors.dart';

class TailorDashboardScreen extends StatelessWidget {
  const TailorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TailorOrdersController>(
      init: TailorOrdersController(),
      builder: (_) => Obx(
        () => Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              // ── Header Premium ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: OColors.primary,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 22),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.notification, color: Colors.white, size: 24),
                      ),
                      if (_.orders.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: OColors.secondary, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              _.orders.length.toString(),
                              style: const TextStyle(color: OColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Mes Commandes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF181818), Color(0xFF2D2D2D)],
                            ),
                          ),
                        ),
                      ),
                      // Cercles décoratifs subtils
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab Bar (Filtrage) ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: OColors.primary,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: TailorOrdersController.statusTabs.map((tab) {
                              final isSelected = _.activeTab.value == tab;
                              final label = TailorOrdersController.tabLabels[tab] ?? tab;
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () => _.switchTab(tab),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? OColors.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: OColors.primary.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        else
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : OColors.grey2,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Liste des commandes ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: _.isLoading.value
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: OColors.secondary)),
                      )
                    : _.orders.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.box, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune commande trouvée',
                                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final order = _.orders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildOrderCard(context, _, order),
                                );
                              },
                              childCount: _.orders.length,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, TailorOrdersController controller, TailorOrder order) {
    return GestureDetector(
      onTap: () => Get.to(() => TailorOrderDetailScreen(orderId: order.orderId)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Image
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: OColors.grey1,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: order.thumbnailUrl != null
                        ? Image.network(order.thumbnailUrl!, fit: BoxFit.cover)
                        : const Icon(Iconsax.image, color: OColors.primary, size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                // Client Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.modelName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#${_shortId(order.orderId).toUpperCase()}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: TextStyle(color: _statusColor(order.status), fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${NumberFormat.decimalPattern('fr_FR').format(order.amount)} F',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: OColors.primary),
                    ),
                  ],
                ),
              ],
            ),
            
            // Actions dynamiques
            if (order.canAcceptOrReject || order.canStart || order.canComplete) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF0F0F0), height: 1),
              const SizedBox(height: 16),
              _buildActions(controller, order),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(TailorOrdersController controller, TailorOrder order) {
    if (order.canAcceptOrReject) {
      return Row(
        children: [
          Expanded(child: _miniButton('Refuser', Colors.red.withOpacity(0.1), Colors.red, () => controller.rejectOrder(order.assignmentId))),
          const SizedBox(width: 12),
          Expanded(child: _miniButton('Accepter', OColors.primary, Colors.white, () => controller.acceptOrder(order.assignmentId))),
        ],
      );
    }
    if (order.canStart) {
      return _miniButton('Commencer', Colors.blue, Colors.white, () => controller.startOrder(order.assignmentId));
    }
    if (order.canComplete) {
      return _miniButton('Terminer', Colors.green, Colors.white, () => controller.completeOrder(order.assignmentId));
    }
    return const SizedBox.shrink();
  }

  Widget _miniButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(0, 8);

  Color _statusColor(TailorOrderStatus status) {
    switch (status) {
      case TailorOrderStatus.pending: return Colors.orange;
      case TailorOrderStatus.accepted: return Colors.blue;
      case TailorOrderStatus.inProgress: return Colors.purple;
      case TailorOrderStatus.completed: return Colors.green;
      case TailorOrderStatus.cancelled:
      case TailorOrderStatus.rejected: return Colors.red;
      default: return Colors.grey;
    }
  }
}


