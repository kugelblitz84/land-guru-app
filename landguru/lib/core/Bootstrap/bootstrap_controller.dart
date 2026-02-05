import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/user_type_service.dart';
import '../../routes/app_routes.dart';

class BootstrapController extends GetxController {
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authService = Get.find<AuthService>();
    final userTypeService = Get.find<UserTypeService>();

    await authService.loadFromStorage();

    if (_navigated) return;
    _navigated = true;

    if (authService.isLoggedIn && userTypeService.isAgent) {
      Get.offAllNamed(AppRoutes.AGENT_MAIN);
    } else if (authService.isLoggedIn && userTypeService.isUser) {
      Get.offAllNamed(AppRoutes.MAIN);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}

class BootstrapBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BootstrapController>(BootstrapController());
  }
}
