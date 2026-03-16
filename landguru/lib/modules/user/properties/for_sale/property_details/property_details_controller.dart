import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../core/services/services.dart';
import '../../widgets/metrics_conversion_row.dart';
import 'models/property_details_models.dart';

/// Controller for Property Details screen (Locked and Unlocked views)
class PropertyDetailsController extends GetxController {
  final SellPostDetailsService _sellPostDetailsService =
      Get.find<SellPostDetailsService>();
  final BuyPostOfferService _buyPostOfferService =
      Get.find<BuyPostOfferService>();
  final UserProfileStore? _userProfileStore =
      Get.isRegistered<UserProfileStore>()
      ? Get.find<UserProfileStore>()
      : null;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isLocked = true.obs;
  final RxBool hasRequestedAppointment = false.obs;
  final RxBool isDescriptionExpanded = false.obs;

  // Offer from Existing flow state
  final RxBool isOfferFromExisting = false.obs;
  final RxString buyPostId = ''.obs;
  final RxString pageTitle = 'Property Details'.obs;

  // Property data
  final Rxn<PropertyDetails> property = Rxn<PropertyDetails>();
  final RxString propertyId = ''.obs;

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
  final List<OwnershipHistoryEntry> ownershipHistory = [
    const OwnershipHistoryEntry(
      name: 'Farhan',
      period: '2022 - Present',
      role: 'Current',
      isCurrent: true,
    ),
    const OwnershipHistoryEntry(
      name: 'Mihtab Azhar',
      period: '2019 - 2022',
      role: '',
    ),
    const OwnershipHistoryEntry(
      name: 'Trusted Developer',
      period: '',
      role: '',
    ),
  ];

  // Legal documents (mock)
  final List<String> legalDocuments = [
    'Deed documents',
    'Khatian documents',
    'Tax documents',
    'Ownership history documents',
  ];

  // Service verifications (mock)
  final List<ServiceVerification> serviceVerifications = [
    const ServiceVerification(
      serviceName: 'Ownership History Validation',
      assignedAgent: 'Rahman',
      agentRole: 'Lawyer',
      isVerified: true,
    ),
    const ServiceVerification(
      serviceName: 'Pentagraph Map Validation',
      assignedAgent: 'Abrar',
      agentRole: 'Land Assistant',
      isVerified: true,
    ),
    const ServiceVerification(
      serviceName: 'Deed Writing Service',
      assignedAgent: 'Sohel',
      agentRole: '',
      isVerified: true,
    ),
    const ServiceVerification(
      serviceName: 'Document Organization',
      assignedAgent: 'Janangir',
      agentRole: '',
      isVerified: true,
    ),
    const ServiceVerification(
      serviceName: 'Namjari/DCR Record',
      assignedAgent: 'Forhad',
      agentRole: 'Lawyer',
      isVerified: true,
    ),
  ];

  // Due diligence checklist items (mock)
  final List<String> dueDiligenceItems = [
    'Fraud Detection Passed',
    'Inheritance dispute analysis checked',
    '4A digital ownership checked',
    'Duplicate sale acquisition fail checked',
    'Court case verification passed',
  ];

  // User data for appointment form
  final RxString userName = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get property data from arguments
    if (Get.arguments != null) {
      _loadFromArguments(Get.arguments);
    }

    loadPropertyDetails();
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

  /// Load property from route arguments
  void _loadFromArguments(Map<String, dynamic> args) {
    isLoading.value = true;

    try {
      propertyId.value = args['id'] ?? '';
      isLocked.value = args['isLocked'] ?? true;

      // Check if coming from "Offer from Existing" flow
      isOfferFromExisting.value = args['isOfferFromExisting'] ?? false;
      buyPostId.value = args['buyPostId'] ?? '';
      pageTitle.value = args['pageTitle'] ?? 'Property Details';

      // Map propertyType string to display label
      String propertyTypeLabel = 'Flat';
      final propertyTypeValue = args['propertyType'] ?? '';
      switch (propertyTypeValue) {
        case 'plainLand':
          propertyTypeLabel = 'Plain Land';
          break;
        case 'waterLand':
          propertyTypeLabel = 'Water Land';
          break;
        case 'flat':
          propertyTypeLabel = 'Flat';
          break;
        default:
          propertyTypeLabel = propertyTypeValue;
      }

      // Map postType string to display label
      String postTypeLabel = 'Sell Post';
      final postTypeValue = args['postType'] ?? '';
      switch (postTypeValue) {
        case 'sellPost':
          postTypeLabel = 'Sell Post';
          break;
        case 'buyPost':
          postTypeLabel = 'Buy Post';
          break;
        default:
          postTypeLabel = postTypeValue;
      }

      // Build photos list from imageUrl and propertyPhotos
      List<String> photos = [];
      if (args['propertyPhotos'] != null && args['propertyPhotos'] is List) {
        photos = List<String>.from(args['propertyPhotos']);
      } else if (args['imageUrl'] != null) {
        photos = [args['imageUrl']];
      }

      property.value = PropertyDetails(
        id: args['id'] ?? '',
        postId: args['postId'] ?? '#POST-0000',
        title: args['title'] ?? 'Property',
        price: args['price'] ?? '0',
        propertyType: propertyTypeLabel,
        postType: postTypeLabel,
        isVerified: args['isVerified'] ?? false,
        isLocked: args['isLocked'] ?? true,
        description: args['description'] ?? 'No description available.',
        location: args['location'] ?? 'Location not specified',
        sellableLandAmount: args['sellableLandAmount'] ?? 'N/A',
        plotSize: args['plotSize'] ?? 'N/A',
        distanceFromRoadMin: args['distanceFromRoadMin'] ?? 'N/A',
        distanceFromRoadMax: args['distanceFromRoadMax'] ?? 'N/A',
        landShapeImageUrl: null,
        propertyPhotos: photos,
        postedBy: args['postedBy'] ?? 'Unknown',
        postedByAvatarUrl: args['postedByAvatarUrl']?.toString(),
        postedByVerified: args['postedByVerified'] == true,
        postedTime: args['postedTime'] ?? 'Unknown',
        hasRequestedAppointment: false,
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

  /// Load property details (fallback when no arguments)
  Future<void> loadPropertyDetails() async {
    if (propertyId.value.isEmpty) {
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
        landShapeImageUrl: null,
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
      case 'flat':
      default:
        return 'Flat';
    }
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
    // TODO: Implement actual payment flow
    // For now, simulate unlock by changing the locked state

    if (property.value == null) return;

    // Simply change the locked state - the view will react automatically
    isLocked.value = false;

    // Update the property object as well
    final updatedProperty = PropertyDetails(
      id: property.value!.id,
      postId: property.value!.postId,
      title: property.value!.title,
      price: property.value!.price,
      propertyType: property.value!.propertyType,
      postType: property.value!.postType,
      isVerified: property.value!.isVerified,
      isLocked: false,
      description: property.value!.description,
      location: property.value!.location,
      sellableLandAmount: property.value!.sellableLandAmount,
      plotSize: property.value!.plotSize,
      distanceFromRoadMin: property.value!.distanceFromRoadMin,
      distanceFromRoadMax: property.value!.distanceFromRoadMax,
      landShapeImageUrl: property.value!.landShapeImageUrl,
      propertyPhotos: property.value!.propertyPhotos,
      postedBy: property.value!.postedBy,
      postedByAvatarUrl: property.value!.postedByAvatarUrl,
      postedByVerified: property.value!.postedByVerified,
      postedTime: property.value!.postedTime,
      hasRequestedAppointment: property.value!.hasRequestedAppointment,
    );
    property.value = updatedProperty;
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
        sellPostId: propertyId.value.trim(),
        buyerName: buyerName,
        buyerPhone: normalizedPhone,
        buyerAddress: normalizedAddress,
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
        sellPostId: propertyId.value,
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
