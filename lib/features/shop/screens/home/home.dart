import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/order/order.dart';
import 'package:osho/features/shop/screens/order/order_detail.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(OSizes.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Image(
                        image: AssetImage(OImages.logo),
                        width: 80,
                        height: 35,
                      ),
                      IconButton(
                        onPressed: controller.fetchDashboardData,
                        icon: const Icon(Iconsax.refresh, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tableau de bord',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Gerez vos confections en temps reel',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'En cours',
                            controller.inProgressCount.value.toString(),
                            Iconsax.clock,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Terminees',
                            controller.completedCount.value.toString(),
                            Iconsax.tick_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildStatCard(
                      'Nouvelles (En attente)',
                      controller.newOrdersCount.value.toString(),
                      Iconsax.message_add_1,
                      OColors.primary,
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Commandes recentes',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Get.isRegistered<NavigationController>()) {
                            Get.find<NavigationController>()
                                .selectedIndex
                                .value = 1;
                            return;
                          }
                          Get.to(() => const OrderScreen());
                        },
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.recentOrders.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Iconsax.box, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Aucune commande recente',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final order = controller.recentOrders[index];
                        return GestureDetector(
                          onTap: () => Get.to(
                            () => OrderDetailScreen(order: order),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: OColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    image: order.thumbnailUrl != null && order.thumbnailUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(order.thumbnailUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: order.thumbnailUrl == null || order.thumbnailUrl!.isEmpty
                                      ? const Icon(
                                          Iconsax.image,
                                          color: OColors.primary,
                                          size: 24,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        order.modelName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          letterSpacing: -0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(order.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _statusLabel(order.status),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _statusColor(order.status),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(order.createdAt),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: isFullWidth ? double.infinity : null,
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'En attente';
      case OrderStatus.processing:
        return 'En cours';
      case OrderStatus.completed:
        return 'Terminee';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
