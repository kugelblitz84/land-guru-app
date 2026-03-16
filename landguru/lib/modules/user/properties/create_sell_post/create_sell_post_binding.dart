import 'package:get/get.dart';

import '../services/sell_post_details_service.dart';
import 'create_sell_post_controller.dart';
import 'services/sell_post_service.dart';

class CreateSellPostBinding extends Bindings {
  CreateSellPostBinding({this.resetController = false});

  final bool resetController;

  @override
  void dependencies() {
    if (resetController && Get.isRegistered<CreateSellPostController>()) {
      Get.delete<CreateSellPostController>(force: true);
    }

    if (!Get.isRegistered<CreateSellPostController>()) {
      Get.put<CreateSellPostController>(
        CreateSellPostController(
          Get.find<SellPostService>(),
          Get.find<SellPostDetailsService>(),
        ),
      );
    }
  }
}
