import 'package:get/get.dart';

import '../models/user_system_model.dart';
import '../../modules/user/profile/profile_services.dart';
import 'api_error_handler.dart';
import 'auth_service.dart';

class UserProfileStore extends GetxService {
  final RxBool isLoading = false.obs;
  final Rx<UserProfileStateModel> profileModel =
      UserProfileStateModel.initial().obs;

  final _authService = Get.find<AuthService>();
  final _profileServices = Get.find<ProfileServices>();

  void hydrateFromSession() {
    final user = _authService.user;
    if (user == null) {
      return;
    }

    var nextState = profileModel.value;

    final fullName = _readString(user, const ['fullName', 'name']);
    if (fullName.isNotEmpty) {
      nextState = nextState.copyWith(userName: fullName);
    }

    final email = _readString(user, const ['email']);
    if (email.isNotEmpty) {
      nextState = nextState.copyWith(userEmail: email);
    }

    final phone = _readString(user, const ['phone']);
    if (phone.isNotEmpty) {
      nextState = nextState.copyWith(userPhone: phone);
    }

    final avatar = _readString(user, const ['photoUrl', 'image']);
    if (avatar.isNotEmpty) {
      nextState = nextState.copyWith(profileImage: avatar);
    }

    profileModel.value = nextState.copyWith(
      isVerified: _readBool(user, const ['isVerified']),
    );
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
    profileModel.value = profileModel.value.copyWith(
      unreadNotificationCount: count,
    );
  }

  void clearUnreadCount() {
    updateUnreadCount(0);
  }

  void clear() {
    profileModel.value = UserProfileStateModel.initial();
  }

  void _applyProfile(ProfileModel profile) {
    profileModel.value = profileModel.value.copyWith(
      userName: profile.fullName,
      userEmail: profile.email,
      userPhone: profile.phone,
      profileImage: profile.photoUrl,
      isVerified: profile.isVerified,
      division: profile.address.division,
      district: profile.address.district,
      upazilla: profile.address.upazila,
      pouroshova: profile.address.unionOrCityCorp,
      wardNo: profile.address.wardNo,
      postalCode: profile.address.postalCode,
      fullAddress: profile.address.fullAddress,
      userAddress: profile.address.fullAddress,
      nidNumber: _formatVerificationValue(
        rawValue: profile.verification.nidNumber,
        hasDocument: profile.verification.hasNidDocument,
      ),
      isNidVerified: profile.verification.nidVerified,
      tinNumber: _formatVerificationValue(
        rawValue: profile.verification.tinNumber,
        hasDocument: profile.verification.hasTinDocument,
      ),
      isTinVerified: profile.verification.tinVerified,
    );

    _authService.updateUserFields({
      'fullName': profile.fullName,
      'email': profile.email,
      'phone': profile.phone,
      'photoUrl': profile.photoUrl,
      'isVerified': profile.isVerified,
    });
  }

  void _applySummary(AccountSummaryModel summary) {
    profileModel.value = profileModel.value.copyWith(
      memberSince: summary.memberSince,
      activeDeals: summary.activeDeals,
      propertiesListed: summary.propertiesListed,
    );
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

  String _formatVerificationValue({
    required String rawValue,
    required bool hasDocument,
  }) {
    final masked = _maskSensitive(rawValue);
    if (masked != 'Not provided') {
      return masked;
    }
    if (hasDocument) {
      return 'Document uploaded';
    }
    return 'Not provided';
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
