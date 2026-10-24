import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/services/assignment_service.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

class TailorOrdersController extends GetxController {
  static TailorOrdersController get instance => Get.find();

  /// Reactive properties
  final orders = <TailorOrder>[].obs;
  final isLoading = false.obs;
  final activeTab = 'pending'.obs;

  /// Available tabs
  static const List<String> statusTabs = [
    'pending',
    'accepted',
    'in_progress',
    'completed'
  ];

  /// Tab labels
  static const Map<String, String> tabLabels = {
    'pending': 'En attente',
    'accepted': 'Acceptées',
    'in_progress': 'En cours',
    'completed': 'Terminées',
  };

  @override
  void onInit() {
    // Notifications are set up once, after login (NotificationService).
    fetchOrders();
    super.onInit();
  }

  /// Fetch orders based on active tab or specific status
  Future<void> fetchOrders({String? status}) async {
    try {
      isLoading.value = true;
      final statusToFetch = status ?? activeTab.value;

      final fetchedOrdersRaw =
          await TailorOrdersService.getMyOrders(status: statusToFetch);

      // Tab changed while loading: drop this stale response.
      if (statusToFetch != activeTab.value) return;

      orders.assignAll(fetchedOrdersRaw
          .map((e) => TailorOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList());
          
      debugPrint('✅ Fetched ${orders.length} $statusToFetch orders');
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de charger les commandes',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept order
  Future<void> acceptOrder(String assignmentId) async {
    try {
      isLoading.value = true;
      await AssignmentService.acceptOrder(assignmentId);

      OLoaders.successSnackBar(
        title: 'Succès',
        message: 'Commande acceptée!',
      );

      // Refresh the list and the dashboard figures
      await fetchOrders();
      _refreshDashboard();
    } catch (e) {
      debugPrint('❌ Error accepting order: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible d\'accepter la commande',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start working on order
  Future<void> startOrder(String assignmentId) async {
    try {
      isLoading.value = true;
      await AssignmentService.startOrder(assignmentId);

      OLoaders.successSnackBar(
        title: 'Succès',
        message: 'Commande commencée!',
      );

      // Refresh the list and the dashboard figures
      await fetchOrders();
      _refreshDashboard();
    } catch (e) {
      debugPrint('❌ Error starting order: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de démarrer la commande',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Complete order
  Future<void> completeOrder(String assignmentId) async {
    try {
      isLoading.value = true;
      await AssignmentService.completeOrder(assignmentId);

      OLoaders.successSnackBar(
        title: 'Succès',
        message: 'Commande terminée!',
      );

      // Refresh the list and the dashboard figures
      await fetchOrders();
      _refreshDashboard();
    } catch (e) {
      debugPrint('❌ Error completing order: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de terminer la commande',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject order
  Future<void> rejectOrder(String assignmentId, {String? reason}) async {
    try {
      isLoading.value = true;
      await AssignmentService.rejectOrder(assignmentId, reason: reason);

      OLoaders.successSnackBar(
        title: 'Succès',
        message: 'Commande rejetée',
      );

      // Refresh the list and the dashboard figures
      await fetchOrders();
      _refreshDashboard();
    } catch (e) {
      debugPrint('❌ Error rejecting order: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de rejeter la commande',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshDashboard() {
    if (Get.isRegistered<HomeController>()) {
      HomeController.instance.fetchDashboardData();
    }
  }

  /// Switch tab and fetch orders
  Future<void> switchTab(String tabName) async {
    if (statusTabs.contains(tabName)) {
      if (tabName != activeTab.value) orders.clear();
      activeTab.value = tabName;
      await fetchOrders(status: tabName);
    }
  }
}
