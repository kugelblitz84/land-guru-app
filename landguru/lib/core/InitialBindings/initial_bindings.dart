import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../services/upload_service.dart';
import '../services/user_type_service.dart';
import '../../modules/user/properties/create_sell_post/services/sell_post_service.dart';

class InitialBindings extends Bindings {
  InitialBindings(this._prefs);

  final SharedPreferences _prefs;

  @override
  void dependencies() {
    Get.put<UserTypeService>(UserTypeService(), permanent: true);
    Get.put<TokenService>(TokenService(_prefs), permanent: true);
    Get.put<AuthService>(
      AuthService(_prefs, Get.find<TokenService>()),
      permanent: true,
    );
    Get.put<ApiClient>(
      ApiClient(tokenService: Get.find<TokenService>()),
      permanent: true,
    );
    Get.put<UploadService>(
      UploadService(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<SellPostService>(
      SellPostService(Get.find<ApiClient>()),
      permanent: true,
    );
  }
}
