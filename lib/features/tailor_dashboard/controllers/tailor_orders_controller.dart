import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/services/assignment_service.dart';
import 'package:osho/data/services/fcm_service.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:osho/features/tailor_dashboard/models/tailor_order.dart';

class TailorOrdersController extends GetxController {
  static TailorOrdersController get instance => Get.find();

  /// Reactive properties
  final orders = Rx<List<TailorOrder>>([]);
  final isLoading = false.obs;
  final activeTab = 'pending'.obs;

  /// Available tabs
  static const List<String> statusTabs = [
    'pending',
    'accepted',
    'in_progress',
    'completed'
  ];

  /// Tab labels with icons
  static const Map<String, String> tabLabels = {
    'pending': '🔔 Pending',
    'accepted': '✅ Accepted',
    'in_progress': '🏭 In Progress',
    'completed': '✓ Completed',
  };

  @override
  void onInit() {
    _initializeFCM();
    fetchOrders();
    super.onInit();
  }

  /// Initialize FCM service
  Future<void> _initializeFCM() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        final userId = session.user.id;

        // Register tailor token
        await FCMService.registerTailorToken(userId);
        print('✅ FCM token registered');

        // Listen to notifications
        FCMService.listenToNotifications(() {
          print('📬 Notification received, refreshing orders...');
          fetchOrders();
        });
      }
    } catch (e) {
      print('⚠️ FCM initialization warning: $e');
    }
  }

  /// Fetch orders based on active tab or specific status
  Future<void> fetchOrders({String? status}) async {
    try {
      isLoading.value = true;
      final statusToFetch = status ?? activeTab.value;

      final fetchedOrdersRaw =
          await TailorOrdersService.getMyOrders(status: statusToFetch);

      final List<TailorOrder> fetchedOrders = fetchedOrdersRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => TailorOrder.fromJson(json))
          .toList();

      orders.value = fetchedOrders;
      print('✅ Fetched ${fetchedOrders.length} $statusToFetch orders');
    } catch (e) {
      print('❌ Error fetching orders: $e');
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

      // Refresh the list
      await fetchOrders();
    } catch (e) {
      print('❌ Error accepting order: $e');
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

      // Refresh the list
      await fetchOrders();
    } catch (e) {
      print('❌ Error starting order: $e');
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

      // Refresh the list
      await fetchOrders();
    } catch (e) {
      print('❌ Error completing order: $e');
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

      // Refresh the list
      await fetchOrders();
    } catch (e) {
      print('❌ Error rejecting order: $e');
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de rejeter la commande',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch tab and fetch orders
  Future<void> switchTab(String tabName) async {
    if (statusTabs.contains(tabName)) {
      activeTab.value = tabName;
      await fetchOrders(status: tabName);
    }
  }
}
