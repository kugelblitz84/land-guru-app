import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class TokenService extends GetxService {
  TokenService(this._prefs);

  final SharedPreferences _prefs;
  final RxnString _token = RxnString();

  String? get token => _token.value;

  Future<void> loadFromStorage() async {
    final token = _prefs.getString(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _token.value = token;
    } else {
      _token.value = null;
    }
  }

  void setToken(String token) {
    _token.value = token;
    _prefs.setString(AppConstants.tokenKey, token);
  }

  void clear() {
    _token.value = null;
    _prefs.remove(AppConstants.tokenKey);
  }
}
