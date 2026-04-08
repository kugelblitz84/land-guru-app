import 'package:get/get.dart';

import '../models/user_system_model.dart';
import '../../../core/models/models.dart';
import '../services/user_profile_services.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/auth_service.dart';

class UserProfileStore extends GetxService {
  UserProfileStore(this._authService, this._profileServices);

  final RxBool isLoading = false.obs;
  final Rx<UserProfileStateModel> profileModel =
      UserProfileStateModel.initial().obs;

  final AuthService _authService;
  final ProfileServices _profileServices;

  void hydrateFromSession() {
    final user = _authService.user;
    if (user == null) {
      return;
    }

    var nextState = profileModel.value;

    final fullName = user.fullName.trim();
    if (fullName.isNotEmpty) {
      nextState = nextState.copyWith(userName: fullName);
    }

    final email = user.email.trim();
    if (email.isNotEmpty) {
      nextState = nextState.copyWith(userEmail: email);
    }

    final phone = user.phone.trim();
    if (phone.isNotEmpty) {
      nextState = nextState.copyWith(userPhone: phone);
    }

    final avatar = user.photoUrl.trim();
    if (avatar.isNotEmpty) {
      nextState = nextState.copyWith(profileImage: avatar);
    }

    profileModel.value = nextState.copyWith(isVerified: user.isVerified);
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

      if (profileResponse.isUnauthorized) {
        _handleUnauthorizedSession();
        return;
      }

      if (profileResponse.isSuccess && profileResponse.data != null) {
        _applyProfile(profileResponse.data!);
      }

      final summaryResponse = await ApiErrorHandler.call(
        () => _profileServices.fetchAccountSummary(),
        showError: false,
      );

      if (summaryResponse.isUnauthorized) {
        _handleUnauthorizedSession();
        return;
      }

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

  void _handleUnauthorizedSession() {
    clear();
    _authService.clearSession();
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

    final updatedSessionUser = (_authService.user ?? const AuthUserModel())
        .copyWith(
          fullName: profile.fullName,
          email: profile.email,
          phone: profile.phone,
          photoUrl: profile.photoUrl,
          isVerified: profile.isVerified,
        );
    _authService.updateUser(updatedSessionUser);
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

}
