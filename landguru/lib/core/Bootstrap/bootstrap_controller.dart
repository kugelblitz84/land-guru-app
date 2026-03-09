import 'package:get/get.dart';

import '../services/api_error_handler.dart';
import '../services/agent_profile_store.dart';
import '../services/auth_service.dart';
import '../services/user_profile_store.dart';
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
      final agentProfileStore = Get.find<AgentProfileStore>();
      agentProfileStore.hydrateFromSession();
      await ApiErrorHandler.call(
        () => agentProfileStore.refreshProfile(showError: false),
        showError: false,
      );
      Get.offAllNamed(AppRoutes.AGENT_MAIN);
    } else if (authService.isLoggedIn && userTypeService.isUser) {
      final userProfileStore = Get.find<UserProfileStore>();
      userProfileStore.hydrateFromSession();
      await ApiErrorHandler.call(
        () => userProfileStore.refreshProfile(showError: false),
        showError: false,
      );
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
