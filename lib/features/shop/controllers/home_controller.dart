import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/data/services/tailor_orders_service.dart';
import '../models/order_model.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final _supabase = Supabase.instance.client;
  
  // Observables
  final isLoading = false.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final newOrdersCount = 0.obs;
  final monthlyRevenue = 0.0.obs;
  final recentOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Fetch Orders for Stats using the tailor orders edge function
      final response = await TailorOrdersService.getMyOrders();

      final List<OrderModel> allOrders = (response as List).map((data) {
        if (data is Map<String, dynamic>) {
          final orderData = data['order'] ?? data;
          if (orderData is Map<String, dynamic>) {
            return OrderModel.fromJson(orderData);
          }
        }
        return OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
      }).toList();

      // 2. Calculate Stats
      inProgressCount.value = allOrders.where((o) => o.status == OrderStatus.processing).length;
      completedCount.value = allOrders.where((o) => o.status == OrderStatus.completed).length;
      newOrdersCount.value = allOrders.where((o) => o.status == OrderStatus.newOrder).length;
      
      // Calculate Revenue (Example: Current Month)
      final now = DateTime.now();
      monthlyRevenue.value = allOrders
          .where((o) => o.createdAt.month == now.month && o.createdAt.year == now.year)
          .fold(0, (sum, item) => sum + item.amount);

      // 3. Get Recent Orders (Top 5)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentOrders.assignAll(allOrders.take(5).toList());

    } catch (e) {
      print("Error fetching dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
