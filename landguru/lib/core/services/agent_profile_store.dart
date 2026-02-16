import 'package:get/get.dart';

import '../../modules/agent/profile/agent_profile_services.dart';
import '../../modules/agent/profile/models/profile_model.dart';
import 'api_error_handler.dart';
import 'auth_service.dart';

class AgentProfileStore extends GetxService {
  final RxBool isLoading = false.obs;
  final RxBool isOnline = true.obs;
  final RxInt unreadNotificationCount = 0.obs;

  final RxString agentName = ''.obs;
  final RxString agentTitle = ''.obs;
  final RxString agentId = ''.obs;
  final RxString agentType = ''.obs;
  final RxBool isVerified = false.obs;
  final RxString profileImage = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;

  final RxInt totalTasksCompleted = 0.obs;
  final RxDouble totalEarned = 0.0.obs;

  final RxString assignedLocation = ''.obs;
  final RxList<String> servicesProvided = <String>[].obs;

  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString upazilla = ''.obs;
  final RxString pouroshova = ''.obs;
  final RxString wardNo = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString fullAddress = ''.obs;

  final RxString nidNumber = 'Not provided'.obs;
  final RxString tinNumber = 'Not provided'.obs;
  final RxBool isNidVerified = false.obs;
  final RxBool isTinVerified = false.obs;

  final RxString bankName = ''.obs;
  final RxString bankAccountNo = ''.obs;
  final RxString swiftCode = ''.obs;
  final RxString routingNo = ''.obs;

  final _authService = Get.find<AuthService>();
  final _profileServices = Get.find<AgentProfileServices>();

  String get displayName {
    if (agentTitle.value.isNotEmpty) {
      return '${agentTitle.value} ${agentName.value}';
    }
    return agentName.value;
  }

  void hydrateFromSession() {
    final user = _authService.user;
    if (user == null) {
      return;
    }

    final fullName = _readString(user, const ['fullName', 'name']);
    if (fullName.isNotEmpty) {
      agentName.value = fullName;
    }

    final title = _readString(user, const ['title', 'agentTitle']);
    if (title.isNotEmpty) {
      agentTitle.value = title;
    }

    final id = _readString(user, const ['agentIdDisplay', 'agentId', 'id']);
    if (id.isNotEmpty) {
      agentId.value = id;
    }

    final roleType = _readString(user, const ['agentType']);
    if (roleType.isNotEmpty) {
      agentType.value = _formatAgentType(roleType);
    }

    final avatar = _readString(user, const ['photoUrl', 'image']);
    if (avatar.isNotEmpty) {
      profileImage.value = avatar;
    }

    final userEmail = _readString(user, const ['email']);
    if (userEmail.isNotEmpty) {
      email.value = userEmail;
    }

    final userPhone = _readString(user, const ['phone']);
    if (userPhone.isNotEmpty) {
      phone.value = userPhone;
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
    unreadNotificationCount.value = count;
  }

  void clearUnreadCount() {
    unreadNotificationCount.value = 0;
  }

  void clear() {
    agentName.value = '';
    agentTitle.value = '';
    agentId.value = '';
    agentType.value = '';
    isVerified.value = false;
    profileImage.value = '';
    email.value = '';
    phone.value = '';

    totalTasksCompleted.value = 0;
    totalEarned.value = 0.0;

    assignedLocation.value = '';
    servicesProvided.clear();

    division.value = '';
    district.value = '';
    upazilla.value = '';
    pouroshova.value = '';
    wardNo.value = '';
    postalCode.value = '';
    fullAddress.value = '';

    nidNumber.value = 'Not provided';
    tinNumber.value = 'Not provided';
    isNidVerified.value = false;
    isTinVerified.value = false;

    bankName.value = '';
    bankAccountNo.value = '';
    swiftCode.value = '';
    routingNo.value = '';

    unreadNotificationCount.value = 0;
  }

  void _applyProfile(AgentProfileModel profile) {
    agentName.value = profile.fullName;
    agentId.value = profile.agentIdDisplay.isNotEmpty
        ? profile.agentIdDisplay
        : profile.agentId;
    agentType.value = _formatAgentType(profile.agentType);
    isVerified.value = profile.isVerified;
    profileImage.value = profile.photoUrl;
    email.value = profile.email;
    phone.value = profile.phone;
    assignedLocation.value = profile.assignedLocation;
    servicesProvided.assignAll(profile.services);

    division.value = profile.personalDetails.division;
    district.value = profile.personalDetails.district;
    upazilla.value = profile.personalDetails.upazila;
    pouroshova.value = profile.personalDetails.unionOrCityCorp;
    wardNo.value = profile.personalDetails.wardNo;
    postalCode.value = profile.personalDetails.postalCode;
    fullAddress.value = profile.personalDetails.fullAddress;

    nidNumber.value = _maskSensitive(profile.verificationDocs.nidNumber);
    tinNumber.value = _maskSensitive(profile.verificationDocs.tinNumber);
    isNidVerified.value = profile.verificationDocs.isNIDVerified;
    isTinVerified.value = profile.verificationDocs.isTINVerified;

    bankName.value = profile.bankInfo.bankName;
    bankAccountNo.value = profile.bankInfo.bankAccountNo;
    swiftCode.value = profile.bankInfo.bankSwiftCode;
    routingNo.value = profile.bankInfo.bankRoutingNo;

    _applyStats(profile.stats);

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
    totalTasksCompleted.value = stats.totalTaskCompleted;
    totalEarned.value = stats.totalEarned;
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
