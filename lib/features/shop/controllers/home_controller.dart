import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

/// Tableau de bord : mêmes données et mêmes statuts que l'onglet Commandes
/// (affectations du tailleur), pour que les chiffres correspondent.
class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Observables
  final isLoading = false.obs;
  final hasError = false.obs;
  final pendingCount = 0.obs;
  final acceptedCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final recentOrders = <TailorOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await TailorOrdersService.getMyOrders();
      final orders = response
          .whereType<Map>()
          .map((e) => TailorOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      pendingCount.value =
          orders.where((o) => o.status == TailorOrderStatus.pending).length;
      acceptedCount.value =
          orders.where((o) => o.status == TailorOrderStatus.accepted).length;
      inProgressCount.value =
          orders.where((o) => o.status == TailorOrderStatus.inProgress).length;
      completedCount.value =
          orders.where((o) => o.status == TailorOrderStatus.completed).length;

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentOrders.assignAll(orders.take(5));
    } catch (e) {
      hasError.value = true;
      debugPrint('Error fetching dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
