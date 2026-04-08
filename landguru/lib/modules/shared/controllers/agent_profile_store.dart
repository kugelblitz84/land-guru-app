import 'package:get/get.dart';

import '../models/agent_system_model.dart';
import '../../../core/models/models.dart';
import '../services/agent_profile_services.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/auth_service.dart';

class AgentProfileStore extends GetxService {
  AgentProfileStore(this._authService, this._profileServices);

  final RxBool isLoading = false.obs;
  final Rx<AgentProfileStateModel> profileModel =
      AgentProfileStateModel.initial().obs;

  final AuthService _authService;
  final AgentProfileServices _profileServices;

  String get displayName => profileModel.value.displayName;

  void hydrateFromSession() {
    final user = _authService.user;
    if (user == null) {
      return;
    }

    var nextState = profileModel.value;

    final fullName = user.fullName.trim();
    if (fullName.isNotEmpty) {
      nextState = nextState.copyWith(agentName: fullName);
    }

    final title = user.agentTitle.trim();
    if (title.isNotEmpty) {
      nextState = nextState.copyWith(agentTitle: title);
    }

    final id = user.agentIdDisplay.trim().isNotEmpty
        ? user.agentIdDisplay.trim()
        : user.agentId.trim().isNotEmpty
            ? user.agentId.trim()
            : user.id.trim();
    if (id.isNotEmpty) {
      nextState = nextState.copyWith(agentId: id);
    }

    final roleType = user.agentType.trim();
    if (roleType.isNotEmpty) {
      nextState = nextState.copyWith(agentType: _formatAgentType(roleType));
    }

    final avatar = user.photoUrl.trim();
    if (avatar.isNotEmpty) {
      nextState = nextState.copyWith(profileImage: avatar);
    }

    final userEmail = user.email.trim();
    if (userEmail.isNotEmpty) {
      nextState = nextState.copyWith(email: userEmail);
    }

    final userPhone = user.phone.trim();
    if (userPhone.isNotEmpty) {
      nextState = nextState.copyWith(phone: userPhone);
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
        () => _profileServices.fetchAgentProfile(),
        showError: showError,
      );

      if (profileResponse.isUnauthorized) {
        _handleUnauthorizedSession();
        return;
      }

      if (profileResponse.isSuccess && profileResponse.data != null) {
        _applyProfile(profileResponse.data!);
      }

      final statsResponse = await ApiErrorHandler.call(
        () => _profileServices.fetchAgentStats(),
        showError: false,
      );

      if (statsResponse.isUnauthorized) {
        _handleUnauthorizedSession();
        return;
      }

      if (statsResponse.isSuccess && statsResponse.data != null) {
        _applyStats(statsResponse.data!);
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
    profileModel.value = AgentProfileStateModel.initial();
  }

  void _handleUnauthorizedSession() {
    clear();
    _authService.clearSession();
  }

  void _applyProfile(AgentProfileModel profile) {
    profileModel.value = profileModel.value.copyWith(
      agentName: profile.fullName,
      agentId: profile.agentIdDisplay.isNotEmpty
          ? profile.agentIdDisplay
          : profile.agentId,
      agentType: _formatAgentType(profile.agentType),
      isVerified: profile.isVerified,
      profileImage: profile.photoUrl,
      email: profile.email,
      phone: profile.phone,
      assignedLocation: profile.assignedLocation,
      servicesProvided: List<String>.from(profile.services),
      division: profile.personalDetails.division,
      district: profile.personalDetails.district,
      upazilla: profile.personalDetails.upazila,
      pouroshova: profile.personalDetails.unionOrCityCorp,
      wardNo: profile.personalDetails.wardNo,
      postalCode: profile.personalDetails.postalCode,
      fullAddress: profile.personalDetails.fullAddress,
      nidNumber: _formatVerificationValue(
        rawValue: profile.verificationDocs.nidNumber,
        hasDocument: profile.verificationDocs.hasNidDocument,
      ),
      tinNumber: _formatVerificationValue(
        rawValue: profile.verificationDocs.tinNumber,
        hasDocument: profile.verificationDocs.hasTinDocument,
      ),
      isNidVerified: profile.verificationDocs.isNIDVerified,
      isTinVerified: profile.verificationDocs.isTINVerified,
      bankName: profile.bankInfo.bankName,
      bankAccountNo: profile.bankInfo.bankAccountNo,
      swiftCode: profile.bankInfo.bankSwiftCode,
      routingNo: profile.bankInfo.bankRoutingNo,
      totalTasksCompleted: profile.stats.totalTaskCompleted,
      totalEarned: profile.stats.totalEarned,
    );

    final updatedSessionUser = (_authService.user ?? const AuthUserModel())
        .copyWith(
          fullName: profile.fullName,
          email: profile.email,
          phone: profile.phone,
          photoUrl: profile.photoUrl,
          agentType: profile.agentType,
          agentId: profile.agentId,
          agentIdDisplay: profile.agentIdDisplay,
          isVerified: profile.isVerified,
        );
    _authService.updateUser(updatedSessionUser);
  }

  void _applyStats(AgentStats stats) {
    profileModel.value = profileModel.value.copyWith(
      totalTasksCompleted: stats.totalTaskCompleted,
      totalEarned: stats.totalEarned,
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

  String _formatAgentType(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .split('_')
        .map((segment) {
          if (segment.isEmpty) {
            return segment;
          }
          final lower = segment.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

}
