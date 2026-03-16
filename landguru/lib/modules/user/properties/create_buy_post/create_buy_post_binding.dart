import 'package:get/get.dart';

import 'create_buy_post_controller.dart';
import 'services/buy_post_service.dart';

class CreateBuyPostBinding extends Bindings {
  CreateBuyPostBinding({this.resetController = false});

  final bool resetController;

  @override
  void dependencies() {
    if (resetController && Get.isRegistered<CreateBuyPostController>()) {
      Get.delete<CreateBuyPostController>(force: true);
    }

    if (!Get.isRegistered<CreateBuyPostController>()) {
      Get.put<CreateBuyPostController>(
        CreateBuyPostController(Get.find<BuyPostService>()),
      );
    }
  }
}
