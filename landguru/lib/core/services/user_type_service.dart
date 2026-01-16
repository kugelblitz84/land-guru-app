import 'package:get/get.dart';
import '../enums/user_type.dart';

/// Global service to manage the current user type (User or Agent).
/// This determines which UI and features are available.
class UserTypeService extends GetxService {
  final Rxn<UserType> _currentType = Rxn<UserType>();

  /// Current user type
  UserType? get currentType => _currentType.value;

  /// Check if current user is a regular user
  bool get isUser => _currentType.value == UserType.user;

  /// Check if current user is an agent
  bool get isAgent => _currentType.value == UserType.agent;

  /// Set the current user type
  void setUserType(UserType? type) {
    _currentType.value = type;
  }

  /// Clear the user type (on logout)
  void clear() {
    _currentType.value = null;
  }
}
