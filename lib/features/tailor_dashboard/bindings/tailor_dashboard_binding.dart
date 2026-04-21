import 'package:get/get.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';

class TailorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TailorOrdersController());
  }
}
