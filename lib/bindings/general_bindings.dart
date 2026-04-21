import 'package:get/get.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/tailor_dashboard/controllers/tailor_orders_controller.dart';
import 'package:osho/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(AuthenticationRepository());
    Get.lazyPut(() => TailorOrdersController());
  }
}