import 'package:get/get.dart';

/// Global service to manage the current user type (User or Agent).
/// This determines which UI and features are available.
class UserTypeService extends GetxService {
  // Supported account role types in this codebase: 'user', 'agent'.
  static const String roleUser = 'user';
  static const String roleAgent = 'agent';

  final RxnString _currentType = RxnString();

  /// Current user type
  String? get currentType => _currentType.value;

  /// Check if current user is a regular user
  bool get isUser => _currentType.value == roleUser;

  /// Check if current user is an agent
  bool get isAgent => _currentType.value == roleAgent;

  /// Set the current user type
  void setUserType(String? type) {
    _currentType.value = type?.trim().toLowerCase();
  }

  /// Clear the user type (on logout)
  void clear() {
    _currentType.value = null;
  }
}
