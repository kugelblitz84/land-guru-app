import 'package:get/get.dart';

import '../models/agent_system_model.dart';
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

    final fullName = _readString(user, const ['fullName', 'name']);
    if (fullName.isNotEmpty) {
      nextState = nextState.copyWith(agentName: fullName);
    }

    final title = _readString(user, const ['title', 'agentTitle']);
    if (title.isNotEmpty) {
      nextState = nextState.copyWith(agentTitle: title);
    }

    final id = _readString(user, const ['agentIdDisplay', 'agentId', 'id']);
    if (id.isNotEmpty) {
      nextState = nextState.copyWith(agentId: id);
    }

    final roleType = _readString(user, const ['agentType']);
    if (roleType.isNotEmpty) {
      nextState = nextState.copyWith(agentType: _formatAgentType(roleType));
    }

    final avatar = _readString(user, const ['photoUrl', 'image']);
    if (avatar.isNotEmpty) {
      nextState = nextState.copyWith(profileImage: avatar);
    }

    final userEmail = _readString(user, const ['email']);
    if (userEmail.isNotEmpty) {
      nextState = nextState.copyWith(email: userEmail);
    }

    final userPhone = _readString(user, const ['phone']);
    if (userPhone.isNotEmpty) {
      nextState = nextState.copyWith(phone: userPhone);
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
        () => _profileServices.fetchAgentProfile(),
        showError: showError,
      );

      if (profileResponse.isSuccess && profileResponse.data != null) {
        _applyProfile(profileResponse.data!);
      }

      final statsResponse = await ApiErrorHandler.call(
        () => _profileServices.fetchAgentStats(),
        showError: false,
      );

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

    _authService.updateUserFields({
      'fullName': profile.fullName,
      'email': profile.email,
      'phone': profile.phone,
      'photoUrl': profile.photoUrl,
      'agentType': profile.agentType,
      'agentId': profile.agentId,
      'agentIdDisplay': profile.agentIdDisplay,
      'isVerified': profile.isVerified,
    });
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
