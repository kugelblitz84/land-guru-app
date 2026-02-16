import 'package:get/get.dart';

import '../../modules/user/profile/models/profile_model.dart';
import '../../modules/user/profile/profile_services.dart';
import 'api_error_handler.dart';
import 'auth_service.dart';

class UserProfileStore extends GetxService {
  final RxBool isLoading = false.obs;
  final RxBool isOnline = true.obs;
  final RxInt unreadNotificationCount = 0.obs;

  final RxString userName = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userAddress = ''.obs;
  final RxString profileImage = ''.obs;
  final RxBool isVerified = false.obs;

  final RxString memberSince = '--'.obs;
  final RxInt activeDeals = 0.obs;
  final RxInt propertiesListed = 0.obs;

  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString upazilla = ''.obs;
  final RxString pouroshova = ''.obs;
  final RxString wardNo = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString fullAddress = ''.obs;

  final RxString nidNumber = 'Not provided'.obs;
  final RxBool isNidVerified = false.obs;
  final RxString tinNumber = 'Not provided'.obs;
  final RxBool isTinVerified = false.obs;

  final _authService = Get.find<AuthService>();
  final _profileServices = Get.find<ProfileServices>();

  void hydrateFromSession() {
    final user = _authService.user;
    if (user == null) {
      return;
    }

    final fullName = _readString(user, const ['fullName', 'name']);
    if (fullName.isNotEmpty) {
      userName.value = fullName;
    }

    final email = _readString(user, const ['email']);
    if (email.isNotEmpty) {
      userEmail.value = email;
    }

    final phone = _readString(user, const ['phone']);
    if (phone.isNotEmpty) {
      userPhone.value = phone;
    }

    final avatar = _readString(user, const ['photoUrl', 'image']);
    if (avatar.isNotEmpty) {
      profileImage.value = avatar;
    }

    isVerified.value = _readBool(user, const ['isVerified']);
  }

  Future<void> refreshProfile({
    bool forceRefresh = false,
    bool showError = true,
  }) async {
    if (isLoading.value && !forceRefresh) {
      return;
    }

    isLoading.value = true;
    try {
      final profileResponse = await ApiErrorHandler.call(
        () => _profileServices.fetchUserProfile(),
        showError: showError,
      );

      if (profileResponse.isSuccess && profileResponse.data != null) {
        _applyProfile(profileResponse.data!);
      }

      final summaryResponse = await ApiErrorHandler.call(
        () => _profileServices.fetchAccountSummary(),
        showError: false,
      );

      if (summaryResponse.isSuccess && summaryResponse.data != null) {
        _applySummary(summaryResponse.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void updateUnreadCount(int count) {
    unreadNotificationCount.value = count;
  }

  void clearUnreadCount() {
    unreadNotificationCount.value = 0;
  }

  void clear() {
    userName.value = '';
    userPhone.value = '';
    userEmail.value = '';
    userAddress.value = '';
    profileImage.value = '';
    isVerified.value = false;

    memberSince.value = '--';
    activeDeals.value = 0;
    propertiesListed.value = 0;

    division.value = '';
    district.value = '';
    upazilla.value = '';
    pouroshova.value = '';
    wardNo.value = '';
    postalCode.value = '';
    fullAddress.value = '';

    nidNumber.value = 'Not provided';
    isNidVerified.value = false;
    tinNumber.value = 'Not provided';
    isTinVerified.value = false;

    unreadNotificationCount.value = 0;
  }

  void _applyProfile(ProfileModel profile) {
    userName.value = profile.fullName;
    userEmail.value = profile.email;
    userPhone.value = profile.phone;
    profileImage.value = profile.photoUrl;
    isVerified.value = profile.isVerified;

    division.value = profile.address.division;
    district.value = profile.address.district;
    upazilla.value = profile.address.upazila;
    pouroshova.value = profile.address.unionOrCityCorp;
    wardNo.value = profile.address.wardNo;
    postalCode.value = profile.address.postalCode;
    fullAddress.value = profile.address.fullAddress;
    userAddress.value = profile.address.fullAddress;

    nidNumber.value = _maskSensitive(profile.verification.nidNumber);
    isNidVerified.value = profile.verification.nidVerified;
    tinNumber.value = _maskSensitive(profile.verification.tinNumber);
    isTinVerified.value = profile.verification.tinVerified;

    _authService.updateUserFields({
      'fullName': profile.fullName,
      'email': profile.email,
      'phone': profile.phone,
      'photoUrl': profile.photoUrl,
      'isVerified': profile.isVerified,
    });
  }

  void _applySummary(AccountSummaryModel summary) {
    memberSince.value = summary.memberSince;
    activeDeals.value = summary.activeDeals;
    propertiesListed.value = summary.propertiesListed;
  }

  String _maskSensitive(String value) {
    final input = value.trim();
    if (input.isEmpty) {
      return 'Not provided';
    }

    if (input.length <= 4) {
      return input;
    }

    final start = input.substring(0, 2);
    final end = input.substring(input.length - 2);
    return '$start***$end';
  }

  String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  bool _readBool(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
    }
    return false;
  }
}
