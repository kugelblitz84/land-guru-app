import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/metrics_input_field.dart';
import '../widgets/metrics_conversion_row.dart';
import '../widgets/change_metrics_sheet.dart';
import 'models/property_details_models.dart';

/// Controller for Property Details screen (Locked and Unlocked views)
class PropertyDetailsController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxBool isLocked = true.obs;
  final RxBool hasRequestedAppointment = false.obs;
  final RxBool isDescriptionExpanded = false.obs;

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

  // User data for appointment form (mock - would come from user account)
  final RxString userName = 'Farhan'.obs;
  final RxString userPhone = '+8801700000000'.obs;
  final RxString userAddress =
      'Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.'
          .obs;

  @override
  void onInit() {
    super.onInit();

    // Get property data from arguments
    if (Get.arguments != null) {
      _loadFromArguments(Get.arguments);
    } else {
      loadPropertyDetails();
    }
  }

  /// Load property from route arguments
  void _loadFromArguments(Map<String, dynamic> args) {
    isLoading.value = true;

    try {
      propertyId.value = args['id'] ?? '';
      isLocked.value = args['isLocked'] ?? true;

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
        distanceFromRoad: args['distanceFromRoad'] ?? 'N/A',
        landShapeImageUrl: null,
        propertyPhotos: photos,
        postedBy: args['postedBy'] ?? 'Unknown',
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
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Fallback mock property data
      property.value = PropertyDetails(
        id: propertyId.value.isEmpty ? '1' : propertyId.value,
        postId: '#POST-1042',
        title: 'Modern Duplex Villa',
        price: '40,00,000',
        propertyType: 'Flat',
        postType: 'Sell Post',
        isVerified: true,
        isLocked: isLocked.value,
        description:
            'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        sellableLandAmount: '15 Katha',
        plotSize: '15 Katha',
        distanceFromRoad: '200m-750m',
        landShapeImageUrl: null,
        propertyPhotos: [
          'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        ],
        postedBy: 'Farhan',
        postedTime: '2h ago',
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
    // For now, simulate unlock by navigating to unlocked view

    if (property.value == null) return;

    // Navigate to unlocked view with same property data but isLocked = false
    Get.offNamed(
      AppRoutes.PROPERTY_DETAILS_UNLOCKED,
      arguments: property.value!.toMap(overrideLocked: false),
    );
  }

  /// Submit appointment request
  Future<bool> submitAppointmentRequest({
    required String phone,
    required String address,
  }) async {
    try {
      // TODO: Call API to submit appointment request
      await Future.delayed(const Duration(seconds: 1));

      // Update state
      hasRequestedAppointment.value = true;
      userPhone.value = phone;
      userAddress.value = address;

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit appointment request',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }

  /// Change metrics (for land size display)
  Future<void> changeMetrics() async {
    final context = Get.context;
    if (context == null) return;

    final result = await ChangeMetricsSheet.show(
      context,
      currentUnit: selectedLandUnit.value,
    );

    if (result != null) {
      selectedLandUnit.value = result;
    }
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
    final sqft = LandUnitConverter.toSqft(value, originalUnit);
    final convertedValue = LandUnitConverter.fromSqft(
      sqft,
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
