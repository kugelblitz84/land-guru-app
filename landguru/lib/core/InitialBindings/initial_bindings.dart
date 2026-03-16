import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../services/upload_service.dart';
import '../services/user_type_service.dart';
import '../../modules/shared/controllers/user_profile_store.dart';
import '../../modules/shared/controllers/agent_profile_store.dart';
import '../../modules/user/properties/create_sell_post/services/sell_post_service.dart';
import '../../modules/user/properties/create_buy_post/services/buy_post_service.dart';
import '../../modules/user/properties/my_posts/services/my_sell_posts_service.dart';
import '../../modules/user/properties/services/sell_post_details_service.dart';
import '../../modules/user/properties/services/sell_post_listing_service.dart';
import '../../modules/user/properties/services/buy_post_listing_service.dart';
import '../../modules/user/properties/wanted_and_needs/services/buy_post_offer_service.dart';
import '../../modules/user/properties/my_posts/buy_posts/services/my_buy_posts_service.dart';
import '../../modules/user/properties/my_posts/offered_posts/services/my_offered_posts_service.dart';
import 'package:landguru/modules/shared/services/user_profile_services.dart';
import 'package:landguru/modules/user/appointments/services/appointment_services.dart';
import 'package:landguru/modules/shared/services/agent_profile_services.dart';
import 'package:landguru/modules/agent/appointments/agent_appointments_services.dart';
import 'package:landguru/modules/agent/my_tasks/agent_task_actions_service.dart';

class InitialBindings extends Bindings {
  InitialBindings(this._prefs);

  final SharedPreferences _prefs;

  @override
  void dependencies() {
    Get.put<UserTypeService>(UserTypeService(), permanent: true);
    Get.put<TokenService>(TokenService(_prefs), permanent: true);
    Get.put<ApiClient>(
      ApiClient(tokenService: Get.find<TokenService>()),
      permanent: true,
    );
    Get.put<AuthService>(
      AuthService(_prefs, Get.find<TokenService>(), Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<UploadService>(
      UploadService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ProfileServices>(
      ProfileServices(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<AppointmentServices>(
      AppointmentServices(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<AgentProfileServices>(
      AgentProfileServices(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<UserProfileStore>(
      UserProfileStore(Get.find<AuthService>(), Get.find<ProfileServices>()),
      permanent: true,
    );
    Get.put<AgentProfileStore>(
      AgentProfileStore(
        Get.find<AuthService>(),
        Get.find<AgentProfileServices>(),
      ),
      permanent: true,
    );
    Get.put<AgentAppointmentsServices>(
      AgentAppointmentsServices(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<AgentTaskActionsService>(
      AgentTaskActionsService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<SellPostService>(
      SellPostService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<BuyPostService>(
      BuyPostService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<SellPostListingService>(
      SellPostListingService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<SellPostDetailsService>(
      SellPostDetailsService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<MySellPostsService>(
      MySellPostsService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<MyBuyPostsService>(
      MyBuyPostsService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<MyOfferedPostsService>(
      MyOfferedPostsService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<BuyPostListingService>(
      BuyPostListingService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<BuyPostOfferService>(
      BuyPostOfferService(Get.find<ApiClient>()),
      permanent: true,
    );
  }
}
