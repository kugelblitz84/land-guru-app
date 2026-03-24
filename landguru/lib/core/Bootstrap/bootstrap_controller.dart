import 'package:get/get.dart';

import '../../modules/shared/controllers/agent_profile_store.dart';
import '../services/auth_service.dart';
import '../../modules/shared/controllers/user_profile_store.dart';
import '../services/user_type_service.dart';
import '../../routes/app_routes.dart';

class BootstrapController extends GetxController {
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authService = Get.find<AuthService>();
    final userTypeService = Get.find<UserTypeService>();

    await authService.loadFromStorage();

    if (_navigated) return;
    _navigated = true;

    if (authService.isLoggedIn && userTypeService.isAgent) {
      final agentProfileStore = Get.find<AgentProfileStore>();
      await agentProfileStore.refreshProfile(showError: false);
      if (!authService.isLoggedIn) {
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }
      Get.offAllNamed(AppRoutes.AGENT_MAIN);
    } else if (authService.isLoggedIn && userTypeService.isUser) {
      final userProfileStore = Get.find<UserProfileStore>();
      await userProfileStore.refreshProfile(showError: false);
      if (!authService.isLoggedIn) {
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }
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
