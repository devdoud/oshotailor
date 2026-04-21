import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/order/order_detail.dart';
import 'package:osho/utils/constants/colors.dart';

class OOrderListItems extends StatelessWidget {
  const OOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.instance;

    return Obx(() {
      final orders = controller.recentOrders;

      if (orders.isEmpty) {
        return Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.3,
                child: Icon(
                  Iconsax.document_text5,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune commande pour le moment',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (_, index) {
          final order = orders[index];
          final statusColor = _statusColor(order.status);

          return GestureDetector(
            onTap: () => Get.to(
              () => OrderDetailScreen(order: order),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: OColors.primary.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Iconsax.user,
                                  color: OColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Ref: #${_displayId(order).toUpperCase()}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _statusLabel(order.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modele',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.modelName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Montant',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${NumberFormat('#,###').format(order.amount)} F",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: OColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.calendar_1,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                                'fr_FR',
                              ).format(order.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 14,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  static String _displayId(OrderModel order) {
    final value = order.id;
    if (value.length <= 6) {
      return value;
    }
    return value.substring(0, 6);
  }

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Nouvelle';
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

  static Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return const Color(0xFF3498DB);
      case OrderStatus.processing:
        return const Color(0xFFF39C12);
      case OrderStatus.completed:
        return const Color(0xFF27AE60);
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }
}
