import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          appBar: AppBar(
            title: const Text('📋 Mes Commandes'),
            elevation: 0,
            backgroundColor: OColors.primary,
            foregroundColor: OColors.white,
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Center(
                    child: Badge(
                      label: Text(_.orders.value.length.toString()),
                      backgroundColor: OColors.secondary,
                      textColor: OColors.primary,
                      child: const Icon(Icons.notifications),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 📌 Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: TailorOrdersController.statusTabs
                          .map((tab) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: GestureDetector(
                                  onTap: () => _.switchTab(tab),
                                  child: Chip(
                                    label: Text(
                                      TailorOrdersController.tabLabels[tab] ??
                                          tab,
                                      style: TextStyle(
                                        color: _.activeTab.value == tab
                                            ? OColors.primary
                                            : OColors.grey2,
                                        fontWeight: _.activeTab.value == tab
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    backgroundColor: _.activeTab.value == tab
                                        ? OColors.secondary
                                        : OColors.grey1,
                                    side: BorderSide(
                                      color: _.activeTab.value == tab
                                          ? OColors.secondary
                                          : Colors.transparent,
                                    ),
                                    onDeleted: null,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
              // 📌 Orders List
              Expanded(
                child: _.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: OColors.secondary,
                        ),
                      )
                    : _.orders.value.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: OColors.grey2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Pas de commandes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: OColors.grey2,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _.orders.value.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final TailorOrder order = _.orders.value[index];
                              return _buildOrderCard(context, _, order);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual order premium card
  Widget _buildOrderCard(BuildContext context,
      TailorOrdersController controller, TailorOrder order) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TailorOrderDetailScreen(
              orderId: order.orderId,
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header (Image + Text)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: OColors.primary.withOpacity(0.1),
                    image: order.thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(order.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: order.thumbnailUrl == null
                      ? const Icon(
                          Icons.image,
                          color: OColors.primary,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.modelName,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ref: #${order.orderId.length > 8 ? order.orderId.substring(0, 8).toUpperCase() : order.orderId}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: _getStatusColor(order.status.name),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            // Actions (Optional based on status)
            if (order.canAcceptOrReject ||
                order.canStart ||
                order.canComplete) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildActionButtons(controller, order)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Action buttons mapped dynamically to order status using existing TailorOrder helpers
  Widget _buildActionButtons(
      TailorOrdersController controller, TailorOrder order) {
    if (order.canAcceptOrReject) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.rejectOrder(order.assignmentId),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Refuser',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.acceptOrder(order.assignmentId),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: OColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Accepter',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } else if (order.canStart) {
      return ElevatedButton.icon(
        onPressed: () => controller.startOrder(order.assignmentId),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Commencer',
            style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } else if (order.canComplete) {
      return ElevatedButton.icon(
        onPressed: () => controller.completeOrder(order.assignmentId),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.done_all),
        label: const Text('Terminer la commande',
            style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  /// Get color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'inprogress':
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return OColors.grey2;
    }
  }
}
