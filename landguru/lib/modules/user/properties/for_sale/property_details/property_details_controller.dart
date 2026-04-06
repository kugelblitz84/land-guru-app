import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../core/services/services.dart';
import '../../../model/payment_models.dart';
import '../../../model/unlock_features_models.dart';
import '../../services/models/sell_post_details_payload.dart';
import '../../services/models/sell_post_request_payloads.dart';
import '../../wanted_and_needs/models/models.dart';
import '../../widgets/metrics_conversion_row.dart';
import 'models/property_details_models.dart';

/// Controller for Property Details screen (Locked and Unlocked views)
class PropertyDetailsController extends GetxController {
  PropertyDetailsController({Map<String, dynamic>? initialArguments})
    : _initialArguments = initialArguments == null
          ? null
          : Map<String, dynamic>.from(initialArguments);

  final Map<String, dynamic>? _initialArguments;

  final SellPostDetailsService _sellPostDetailsService =
      Get.find<SellPostDetailsService>();
  final BuyPostOfferService _buyPostOfferService =
      Get.find<BuyPostOfferService>();
  final PaymentServices _paymentServices = Get.find<PaymentServices>();
  final UnlockFeaturesService _unlockFeaturesService =
      Get.find<UnlockFeaturesService>();
  final UserProfileStore? _userProfileStore =
      Get.isRegistered<UserProfileStore>()
      ? Get.find<UserProfileStore>()
      : null;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isLocked = true.obs;
  final RxBool hasRequestedAppointment = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxBool isUnlocking = false.obs;

  // Offer from Existing flow state
  final RxBool isOfferFromExisting = false.obs;
  final RxString buyPostId = ''.obs;
  final RxString pageTitle = 'Property Details'.obs;

  // Property data
  final Rxn<PropertyDetails> property = Rxn<PropertyDetails>();
  final RxString propertyId = ''.obs;
  final Rxn<UnlockFeaturesSummary> unlockSummary = Rxn<UnlockFeaturesSummary>();
  final RxnString propertyVideoUrl = RxnString();
  final RxnString pentagraphMapUrl = RxnString();

  // Metrics/Land Unit state
  final Rx<LandUnit> selectedLandUnit = LandUnit.katha.obs;

  // Unlocked features expansion state
  final RxMap<int, bool> featureExpansionState = <int, bool>{}.obs;

  // Locked features list
  final List<LockedFeature> lockedFeatures = [
    const LockedFeature(
      title: 'Risk & Due Diligence Checklist',
      subtitle: 'Get further verification about this property',
      icon: Icons.checklist_rounded,
      iconColor: Color(0xFF3B6CF5),
    ),
    const LockedFeature(
      title: 'Property Video',
      subtitle: 'Get a video tour of the property before buying',
      icon: Icons.videocam_outlined,
      iconColor: Color(0xFF3B6CF5),
    ),
    const LockedFeature(
      title: 'Ownership History',
      subtitle: 'Get to know the connected owners history',
      icon: Icons.history,
      iconColor: Color(0xFF9E9E9E),
    ),
    const LockedFeature(
      title: 'Validated Legal Documents',
      subtitle: 'Get to see which documents will be provided',
      icon: Icons.description_outlined,
      iconColor: Color(0xFF3B6CF5),
    ),
    const LockedFeature(
      title: 'Pentagraph Map',
      subtitle: 'Detailed Mouza map of the area',
      icon: Icons.map_outlined,
      iconColor: Color(0xFF3B6CF5),
    ),
    const LockedFeature(
      title: 'Services Taken',
      subtitle: 'Get to see which services was taken by the user',
      icon: Icons.miscellaneous_services_outlined,
      iconColor: Color(0xFFFF9800),
    ),
  ];

  // Ownership history data (mock)
  final List<OwnershipHistoryEntry> ownershipHistory = [];

  // Legal documents
  final List<LegalDocumentItem> legalDocuments = [];

  // Service verifications (mock)
  final List<ServiceVerification> serviceVerifications = [];

  // Due diligence checklist items (mock)
  final List<String> dueDiligenceItems = [];

  // User data for appointment form
  final RxString userName = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Accept only the minimum route data and always fetch by id.
    final routeArguments = _initialArguments ?? Get.arguments;
    if (routeArguments != null) {
      _loadFromArguments(routeArguments);
    }

    loadPropertyDetails();
    loadUnlockFeaturesSummary();
  }

  String get unlockAmountDisplay {
    final amount = unlockSummary.value?.unlockFeaturesAmount;
    if (amount == null || amount <= 0) {
      return '4000';
    }

    final isWhole = amount == amount.roundToDouble();
    return isWhole ? amount.toInt().toString() : amount.toStringAsFixed(2);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateUserProfileData();
      _refreshUserProfileData();
    });
  }

  void _hydrateUserProfileData() {
    if (_userProfileStore == null) {
      return;
    }

    _userProfileStore.hydrateFromSession();
    final profile = _userProfileStore.profileModel.value;

    if (profile.userName.trim().isNotEmpty) {
      userName.value = profile.userName.trim();
    }
    if (profile.userPhone.trim().isNotEmpty) {
      userPhone.value = profile.userPhone.trim();
    }

    final profileAddress = profile.userAddress.trim().isNotEmpty
        ? profile.userAddress.trim()
        : profile.fullAddress.trim();
    if (profileAddress.isNotEmpty) {
      userAddress.value = profileAddress;
    }
  }

  Future<void> _refreshUserProfileData() async {
    if (_userProfileStore == null) {
      return;
    }

    try {
      await _userProfileStore.refreshProfile(showError: false);
      _hydrateUserProfileData();
    } catch (_) {
      // Keep locally hydrated data when background refresh fails.
    }
  }

  Future<void> loadUnlockFeaturesSummary({bool showError = false}) async {
    final result = await ApiErrorHandler.call(
      _unlockFeaturesService.getUnlockFeaturesSummary,
      showError: showError,
      errorTitle: 'Unlock Features',
    );

    if (!result.isSuccess || result.data == null) {
      return;
    }

    unlockSummary.value = result.data;
    isLocked.value = result.data!.isLimited;

    final currentProperty = property.value;
    if (currentProperty != null && currentProperty.isLocked != isLocked.value) {
      property.value = currentProperty.copyWith(isLocked: isLocked.value);
    }
  }

  /// Load property route metadata from arguments.
  void _loadFromArguments(dynamic rawArgs) {
    if (rawArgs is! Map) {
      return;
    }

    final args = Map<String, dynamic>.from(rawArgs);
    propertyId.value = _asString(args['id']);
    if (propertyId.value.isEmpty) {
      propertyId.value = _asString(args['sellPostId']);
    }
    if (propertyId.value.isEmpty) {
      propertyId.value = _asString(args['postId']);
    }

    isLocked.value = _asBool(args['isLocked'], fallback: true);
    isOfferFromExisting.value = _asBool(
      args['isOfferFromExisting'],
      fallback: false,
    );
    buyPostId.value = _asString(args['buyPostId']);
    pageTitle.value = _asString(
      args['pageTitle'],
      fallback: 'Property Details',
    );
  }

  String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  /// Load property details by id from API.
  Future<void> loadPropertyDetails() async {
    property.value = null;
    propertyVideoUrl.value = null;
    pentagraphMapUrl.value = null;

    if (propertyId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Property ID is missing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _sellPostDetailsService.getSellPostById(propertyId.value),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final payload = result.data!;
      final photos = payload.photos;
      propertyVideoUrl.value = payload.videoUrl;
      pentagraphMapUrl.value = payload.pentagraphMapFiles.isNotEmpty
          ? payload.pentagraphMapFiles.first
          : null;

      _hydrateUnlockedFeatureData(payload);

      property.value = PropertyDetails(
        id: payload.id,
        postId: payload.postId,
        title: payload.title,
        price: payload.priceFormatted,
        propertyType: _toDisplayPropertyType(payload.propertyTypeRaw),
        postType: 'Sell Post',
        isVerified: payload.isVerified,
        isLocked: isLocked.value,
        description: payload.description,
        location: payload.location,
        sellableLandAmount: payload.sellableLandAmount,
        plotSize: payload.plotSize,
        shareUnit: payload.shareUnit,
        distanceFromRoadMin: payload.distanceFromRoadMin,
        distanceFromRoadMax: payload.distanceFromRoadMax,
        landShapeImageUrl: payload.otherFiles.isNotEmpty
            ? payload.otherFiles.first
            : null,
        propertyPhotos: photos,
        postedBy: payload.sellerName,
        postedByAvatarUrl: payload.sellerAvatarUrl,
        postedByVerified: payload.sellerVerified,
        postedTime: payload.postedTime,
        hasRequestedAppointment: hasRequestedAppointment.value,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load property details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _toDisplayPropertyType(String rawType) {
    final normalized = rawType.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    switch (normalized) {
      case 'plainland':
      case 'land':
        return 'Plain Land';
      case 'waterland':
      case 'water':
        return 'Water Land';
      case 'commercial':
        return 'Commercial';
      case 'residential':
        return 'Residential';
      case 'flat':
        return 'Flat';
      default:
        return _toTitleCase(rawType);
    }
  }

  void _hydrateUnlockedFeatureData(SellPostDetailsPayload payload) {
    dueDiligenceItems
      ..clear()
      ..addAll(
        payload.riskChecklistItems
            .map((item) {
              final label = (item['label'] ?? '').toString().trim();
              if (label.isEmpty) {
                return '';
              }
              final isChecked = item['isChecked'] == true;
              return isChecked ? label : '$label (Pending)';
            })
            .where((item) => item.isNotEmpty),
      );

    ownershipHistory
      ..clear()
      ..addAll(
        payload.ownershipHistoryItems
            .map((item) {
              final name = (item['ownerName'] ?? item['name'] ?? '')
                  .toString()
                  .trim();
              final period = (item['duration'] ?? item['period'] ?? '')
                  .toString()
                  .trim();
              final isCurrent = item['isCurrent'] == true;

              if (name.isEmpty) {
                return const OwnershipHistoryEntry(
                  name: '',
                  period: '',
                  role: '',
                );
              }

              return OwnershipHistoryEntry(
                name: name,
                period: period,
                role: isCurrent ? 'Current' : '',
                isCurrent: isCurrent,
              );
            })
            .where((entry) => entry.name.isNotEmpty),
      );

    serviceVerifications
      ..clear()
      ..addAll(
        payload.selectedServiceItems
            .map((item) {
              final key = (item['serviceKey'] ?? '').toString().trim();
              if (key.isEmpty) {
                return const ServiceVerification(
                  serviceName: '',
                  assignedAgent: '',
                  agentRole: '',
                );
              }

              return ServiceVerification(
                serviceName: _humanizeServiceKey(key),
                assignedAgent: 'Assigned Agent',
                agentRole: '',
                isVerified: item['isVerified'] == true,
              );
            })
            .where((item) => item.serviceName.isNotEmpty),
      );

    legalDocuments
      ..clear()
      ..addAll(_buildLegalDocumentItems(payload));
  }

  List<LegalDocumentItem> _buildLegalDocumentItems(
    SellPostDetailsPayload payload,
  ) {
    final fromDocuments = payload.legalDocumentItems
        .where(
          (item) =>
              item['category'] != 'VIDEO' &&
              item['category'] != 'PENTAGRAPH_MAP',
        )
        .map((item) {
          final category = item['category'] ?? 'OTHER';
          final url = item['url'] ?? '';
          if (url.isEmpty) {
            return null;
          }
          return LegalDocumentItem(
            title: '${_documentCategoryTitle(category)}: ${_fileName(url)}',
            url: url,
            category: category,
          );
        })
        .whereType<LegalDocumentItem>()
        .toList();

    if (fromDocuments.isNotEmpty) {
      return fromDocuments;
    }

    return [
      ...payload.deedFiles.map(
        (file) => LegalDocumentItem(
          title: 'Deed: ${_fileName(file)}',
          url: file,
          category: 'DEED',
        ),
      ),
      ...payload.khatianFiles.map(
        (file) => LegalDocumentItem(
          title: 'Khatian: ${_fileName(file)}',
          url: file,
          category: 'KHATIAN',
        ),
      ),
      ...payload.otherFiles.map(
        (file) => LegalDocumentItem(
          title: 'Other: ${_fileName(file)}',
          url: file,
          category: 'OTHER',
        ),
      ),
    ];
  }

  String _documentCategoryTitle(String category) {
    switch (category.toUpperCase()) {
      case 'DEED':
        return 'Deed';
      case 'KHATIAN':
        return 'Khatian';
      case 'PENTAGRAPH_MAP':
        return 'Pentagraph Map';
      case 'OTHER':
        return 'Other';
      default:
        return _toTitleCase(category);
    }
  }

  String _humanizeServiceKey(String key) {
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _toTitleCase(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return 'Property';
    }

    return normalized
        .split(RegExp(r'[\s_]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    final value = parts.isNotEmpty ? parts.last.trim() : '';
    return value.isEmpty ? path : value;
  }

  /// Toggle description expanded
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  /// Toggle feature expansion
  void toggleFeatureExpansion(int index) {
    final currentState = featureExpansionState[index] ?? false;
    featureExpansionState[index] = !currentState;
  }

  /// Check if feature is expanded
  bool isFeatureExpanded(int index) {
    return featureExpansionState[index] ?? false;
  }

  /// Unlock property (pay to see owner details)
  Future<void> unlockProperty() async {
    if (isUnlocking.value || property.value == null) {
      return;
    }

    isUnlocking.value = true;
    try {
      final summaryResult = await ApiErrorHandler.call(
        _unlockFeaturesService.getUnlockFeaturesSummary,
        errorTitle: 'Unlock Features',
      );

      final summary = summaryResult.data;
      if (!summaryResult.isSuccess || summary == null) {
        return;
      }

      unlockSummary.value = summary;

      if (!summary.isLimited) {
        _applyUnlockedState();
        return;
      }

      final sessionResult = await ApiErrorHandler.call(
        _unlockFeaturesService.createUnlockFeaturesSession,
        errorTitle: 'Payment Failed',
      );

      final session = sessionResult.data;
      if (!sessionResult.isSuccess || session == null) {
        return;
      }

      final sessionTranId = session.tranId?.trim() ?? '';
      if (sessionTranId.isEmpty) {
        Get.snackbar(
          'Payment Failed',
          'Missing transaction ID from payment session.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final gatewayResult = await _paymentServices.openPaymentGateway(
        session.gatewayUrl,
      );

      if (gatewayResult.status != PaymentGatewayStatus.success) {
        return;
      }

      final statusResult = await ApiErrorHandler.call(
        () => _unlockFeaturesService.getPaymentStatus(tranId: sessionTranId),
        errorTitle: 'Payment Validation Failed',
      );

      final paymentStatus = statusResult.data;
      if (!statusResult.isSuccess ||
          paymentStatus == null ||
          !paymentStatus.isValidated) {
        Get.snackbar(
          'Payment Pending',
          'Payment is not validated yet. Please try again shortly.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final confirmedTranId = (paymentStatus.tranId?.trim().isNotEmpty ?? false)
          ? paymentStatus.tranId!.trim()
          : sessionTranId;

      final confirmResult = await ApiErrorHandler.call(
        () => _unlockFeaturesService.confirmUnlockFeatures(
          tranId: confirmedTranId,
        ),
        errorTitle: 'Unlock Confirmation Failed',
      );

      final access = confirmResult.data;
      if (!confirmResult.isSuccess || access == null) {
        return;
      }

      if (access.isLimited) {
        Get.snackbar(
          'Unlock Failed',
          'Your account is still limited after confirmation.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await loadUnlockFeaturesSummary(showError: false);
      _applyUnlockedState();

      Get.snackbar(
        'Features Unlocked',
        'All premium property features are now available.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUnlocking.value = false;
    }
  }

  void _applyUnlockedState() {
    isLocked.value = false;
    final current = property.value;
    if (current == null) {
      return;
    }
    property.value = current.copyWith(isLocked: false);
  }

  /// Submit appointment request
  Future<bool> submitAppointmentRequest({
    required String phone,
    required String address,
  }) async {
    final normalizedPhone = phone.trim();
    final normalizedAddress = address.trim();

    if (propertyId.value.trim().isEmpty) {
      Get.snackbar(
        'Missing Data',
        'Property information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (normalizedPhone.isEmpty || normalizedAddress.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Phone number and address are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final buyerName = userName.value.trim().isNotEmpty
        ? userName.value.trim()
        : 'Buyer';

    final result = await ApiErrorHandler.call(
      () => _sellPostDetailsService.requestAppointment(
        payload: RequestSellPostAppointmentPayload(
          sellPostId: propertyId.value.trim(),
          buyerName: buyerName,
          buyerPhone: normalizedPhone,
          buyerAddress: normalizedAddress,
        ),
      ),
    );

    if (!result.isSuccess) {
      return false;
    }

    hasRequestedAppointment.value = true;
    userPhone.value = normalizedPhone;
    userAddress.value = normalizedAddress;

    return true;
  }

  /// Submit offer (for Offer from Existing flow)
  /// This skips the appointment dialog and directly submits the offer
  Future<bool> submitOffer() async {
    if (buyPostId.value.isEmpty || propertyId.value.isEmpty) {
      Get.snackbar(
        'Missing Data',
        'Buy post or sell post information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final result = await ApiErrorHandler.call(
      () => _buyPostOfferService.makeOfferFromExisting(
        buyPostId: buyPostId.value,
        payload: MakeOfferFromExistingPayload(sellPostId: propertyId.value),
      ),
    );

    if (!result.isSuccess) {
      return false;
    }

    hasRequestedAppointment.value = true;
    return true;
  }

  /// Navigate back (uses nested navigation if available)
  void goBack() {
    NestedNavigationService.back();
  }

  /// Parse land amount string to get numeric value
  /// e.g., "5 Katha" -> 5.0, "1800 sqft" -> 1800.0
  double parseLandAmount(String landAmountStr) {
    // Remove any commas and extract the numeric part
    final cleanStr = landAmountStr.replaceAll(',', '');
    final match = RegExp(r'[\d.]+').firstMatch(cleanStr);
    if (match != null) {
      return double.tryParse(match.group(0) ?? '0') ?? 0;
    }
    return 0;
  }

  /// Detect the original unit from the land amount string
  LandUnit detectOriginalUnit(String landAmountStr) {
    final lowerStr = landAmountStr.toLowerCase();
    if (lowerStr.contains('sqft') || lowerStr.contains('sq ft')) {
      return LandUnit.sqft;
    } else if (lowerStr.contains('katha')) {
      return LandUnit.katha;
    } else if (lowerStr.contains('decimal')) {
      return LandUnit.decimal;
    } else if (lowerStr.contains('acre')) {
      return LandUnit.acre;
    } else if (lowerStr.contains('bigha')) {
      return LandUnit.bigha;
    }
    // Default to katha if not detected
    return LandUnit.katha;
  }

  /// Get the land amount converted to the selected unit
  String getConvertedLandAmount(String originalAmount) {
    final value = parseLandAmount(originalAmount);
    if (value == 0) return originalAmount;

    final originalUnit = detectOriginalUnit(originalAmount);

    // Convert to selected unit
    final convertedValue = LandUnitConverter.convert(
      value,
      originalUnit,
      selectedLandUnit.value,
    );

    // Format the value
    String formattedValue;
    if (convertedValue >= 1000) {
      formattedValue = convertedValue.toStringAsFixed(0);
    } else if (convertedValue >= 1) {
      formattedValue = convertedValue.toStringAsFixed(2);
    } else {
      formattedValue = convertedValue.toStringAsFixed(4);
    }

    return '$formattedValue ${selectedLandUnit.value.label}';
  }

  /// Get all conversions for a land amount
  Map<LandUnit, double> getAllConversions(String originalAmount) {
    final value = parseLandAmount(originalAmount);
    if (value == 0) return {};

    final originalUnit = detectOriginalUnit(originalAmount);
    return LandUnitConverter.getAllConversions(value, originalUnit);
  }

  /// Share property
  void shareProperty() {
    Get.snackbar(
      'Share',
      'Share functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
