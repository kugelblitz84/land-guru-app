import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import 'widgets/distance_range_selector.dart';
import 'widgets/properties_filter_sheet.dart';

/// Property type enum
enum PropertyType { plainLand, waterLand, flat }

/// Post type enum
enum PostType { sellPost, buyPost }

/// Offer status enum for land wanted posts
enum OfferStatus {
  none,
  pendingBuyerReview, // Waiting for buyer to accept/reject
  buyerAcceptedPendingAdmin, // Buyer accepted, waiting for admin review
  buyerAcceptedAppointment, // Buyer accepted, admin approved, appointment scheduled
  rejected,
}

/// Model for property listing
class PropertyListing {
  final String id;
  final String postId; // e.g., "#POST-1042"
  final String title;
  final String location;
  final String price;
  final PropertyType propertyType;
  final PostType postType;
  final bool isVerified;
  final bool isLocked;
  final String? imageUrl;

  // Additional details for property details page
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? postedBy;
  final String? postedTime;
  final List<String>? propertyPhotos;

  PropertyListing({
    required this.id,
    this.postId = '',
    required this.title,
    required this.location,
    required this.price,
    required this.propertyType,
    required this.postType,
    this.isVerified = false,
    this.isLocked = true,
    this.imageUrl,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.postedBy,
    this.postedTime,
    this.propertyPhotos,
  });

  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  String get postTypeLabel {
    switch (postType) {
      case PostType.sellPost:
        return 'Sell Post';
      case PostType.buyPost:
        return 'Buy Post';
    }
  }

  Color get propertyTypeColor {
    switch (propertyType) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32); // Green
      case PropertyType.waterLand:
        return const Color(0xFF0288D1); // Blue
      case PropertyType.flat:
        return const Color(0xFF3B6CF5); // Primary blue
    }
  }

  /// Convert to Map for passing as route arguments
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'location': location,
      'price': price,
      'propertyType': propertyType.name,
      'postType': postType.name,
      'isVerified': isVerified,
      'isLocked': isLocked,
      'imageUrl': imageUrl,
      'description': description,
      'sellableLandAmount': sellableLandAmount,
      'plotSize': plotSize,
      'distanceFromRoad': distanceFromRoad,
      'postedBy': postedBy,
      'postedTime': postedTime,
      'propertyPhotos': propertyPhotos,
    };
  }
}

/// Model for land wanted/needs post
class LandWantedPost {
  final String id;
  final String postId; // e.g., "#BUY-1042"
  final String title;
  final String postedBy;
  final String postedTime;
  final String preferredLocation;
  final String propertyType;
  final String requiredLandSize;
  final String requiredPlotSize;
  final String distanceFromRoad;
  final String budgetRange;
  final OfferStatus offerStatus;
  final bool hasOffered;

  LandWantedPost({
    required this.id,
    required this.postId,
    required this.title,
    required this.postedBy,
    required this.postedTime,
    required this.preferredLocation,
    required this.propertyType,
    required this.requiredLandSize,
    required this.requiredPlotSize,
    required this.distanceFromRoad,
    required this.budgetRange,
    this.offerStatus = OfferStatus.none,
    this.hasOffered = false,
  });

  /// Primary status badge label
  String get offerStatusLabel {
    switch (offerStatus) {
      case OfferStatus.none:
        return '';
      case OfferStatus.pendingBuyerReview:
        return 'Pending Buyer Review';
      case OfferStatus.buyerAcceptedPendingAdmin:
        return 'Buyer accepted your offer';
      case OfferStatus.buyerAcceptedAppointment:
        return 'Buyer accepted your offer';
      case OfferStatus.rejected:
        return 'Offer Rejected';
    }
  }

  /// Primary status badge color
  Color get offerStatusColor {
    switch (offerStatus) {
      case OfferStatus.none:
        return const Color(0xFF9E9E9E);
      case OfferStatus.pendingBuyerReview:
        return const Color(0xFF9E9E9E);
      case OfferStatus.buyerAcceptedPendingAdmin:
        return const Color(0xFF4CAF50);
      case OfferStatus.buyerAcceptedAppointment:
        return const Color(0xFF4CAF50);
      case OfferStatus.rejected:
        return const Color(0xFFF44336);
    }
  }

  /// Whether to show "View Appointment" button
  bool get showViewAppointment =>
      offerStatus == OfferStatus.buyerAcceptedAppointment;

  /// Whether to show "Pending Admin Review" button
  bool get showPendingAdminReview =>
      offerStatus == OfferStatus.buyerAcceptedPendingAdmin;
}

/// Controller for the Properties listing screen
/// Handles: For Sale, Land Wanted/Needs, My Posts tabs
class PropertiesController extends GetxController {
  // Tab state
  final RxInt selectedTabIndex = 0.obs;

  // Search
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Display state
  final RxString selectedLocation =
      'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.'
          .obs;
  final RxString sortBy = 'High to Low'.obs;
  final RxInt totalProperties = 120.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Lists
  final RxList<PropertyListing> propertiesForSale = <PropertyListing>[].obs;
  final RxList<PropertyListing> propertiesWanted = <PropertyListing>[].obs;
  final RxList<PropertyListing> myPosts = <PropertyListing>[].obs;

  // Wanted/Needs tab state
  final RxInt wantedSubTabIndex = 0.obs; // 0 = All, 1 = Offered by you
  final RxList<LandWantedPost> allWantedPosts = <LandWantedPost>[].obs;
  final RxList<LandWantedPost> offeredByYouPosts = <LandWantedPost>[].obs;
  final RxList<LandWantedPost> filteredOfferedPosts = <LandWantedPost>[].obs;
  final RxInt totalWantedPosts = 40.obs;
  final RxInt offeredByYouCount = 1.obs;

  // Offered by you filter options
  final RxString offeredFilterBy = 'All'.obs;
  final List<String> offeredFilterOptions = [
    'All',
    'Buyer Accepted',
    'Pending Buyer Review',
  ];

  // ==================== Filter State ====================
  final RxString filterPropertyType = 'plainLand'.obs;
  final Rxn<PriceFilterRange> filterPriceRange = Rxn<PriceFilterRange>(
    const PriceFilterRange(minPrice: 5000000, maxPrice: 80000000),
  );
  final Rxn<LandSizeFilterRange> filterSellableLandAmount =
      Rxn<LandSizeFilterRange>(
        const LandSizeFilterRange(minKatha: 7, maxKatha: 20),
      );
  final Rxn<LandSizeFilterRange> filterPlotSize = Rxn<LandSizeFilterRange>(
    const LandSizeFilterRange(minKatha: 7, maxKatha: 20),
  );
  final Rxn<DistanceRange> filterDistanceRange = Rxn<DistanceRange>(
    const DistanceRange(label: '200m-750m', minMeters: 200, maxMeters: 750),
  );

  // Location filter dropdowns
  final RxString filterDivision = ''.obs;
  final RxString filterDistrict = ''.obs;
  final RxString filterUpazilla = ''.obs;
  final RxString filterPouroshova = ''.obs;
  final RxString filterWardNo = ''.obs;

  // Dropdown options (mock data - replace with API data)
  final List<String> divisionOptions = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  final List<String> districtOptions = [
    'Dhaka',
    'Gazipur',
    'Narayanganj',
    'Tangail',
    'Manikganj',
  ];

  final List<String> upazillaOptions = [
    'Dhanmondi',
    'Gulshan',
    'Uttara',
    'Mirpur',
    'Mohammadpur',
  ];

  final List<String> pouroshovaOptions = [
    'Dhaka South City Corporation',
    'Dhaka North City Corporation',
    'Gazipur City Corporation',
  ];

  final List<String> wardOptions = [
    'Ward 1',
    'Ward 2',
    'Ward 3',
    'Ward 4',
    'Ward 5',
    'Ward 10',
    'Ward 15',
    'Ward 20',
    'Ward 25',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (index == 1) {
      loadWantedPosts();
    } else {
      loadProperties();
    }
  }

  /// Load properties based on current tab
  Future<void> loadProperties() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for For Sale tab
      final List<PropertyListing> mockProperties = [
        PropertyListing(
          id: '1',
          postId: '#POST-1040',
          title: '5 Katha Plot in Purbachal',
          location:
              'Sector 4, Purbachal New Town, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          price: '2,00,00,000',
          propertyType: PropertyType.plainLand,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: true,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          description:
              'Prime residential plot in the rapidly developing Purbachal New Town. Ideal location with excellent connectivity and future growth potential.',
          sellableLandAmount: '5 Katha',
          plotSize: '5 Katha',
          distanceFromRoad: '50m-100m',
          postedBy: 'Mr. Rahman',
          postedTime: '1d ago',
          propertyPhotos: [
            'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          ],
        ),
        PropertyListing(
          id: '2',
          postId: '#POST-1041',
          title: 'Gazipur Water Zone',
          location:
              'Gazipur Sadar, Gazipur City Corporation, Dhaka Division, Bangladesh.',
          price: '95,12,000',
          propertyType: PropertyType.waterLand,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: true,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/gazipur water zone.jpg',
          description:
              'Beautiful water-adjacent land perfect for agricultural or aquaculture projects. Natural water source with excellent drainage system.',
          sellableLandAmount: '10 Katha',
          plotSize: '12 Katha',
          distanceFromRoad: '200m-500m',
          postedBy: 'Mr. Karim',
          postedTime: '3d ago',
          propertyPhotos: [
            'assets/images/Properties Listing - For Sale Images/gazipur water zone.jpg',
          ],
        ),
        PropertyListing(
          id: '3',
          postId: '#POST-1042',
          title: 'Modern Duplex Villa',
          location:
              'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
          price: '40,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: true,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          description:
              'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
          sellableLandAmount: '15 Katha',
          plotSize: '15 Katha',
          distanceFromRoad: '200m-750m',
          postedBy: 'Farhan',
          postedTime: '2h ago',
          propertyPhotos: [
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          ],
        ),
      ];

      propertiesForSale.assignAll(mockProperties);
      totalProperties.value = propertiesForSale.length;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load properties',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Perform search
  void search() {
    searchQuery.value = searchController.text;
    loadProperties();
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
    loadProperties();
  }

  /// Update sort
  void updateSort(String sort) {
    sortBy.value = sort;
    loadProperties();
  }

  /// Toggle sort order
  void toggleSort() {
    if (sortBy.value == 'High to Low') {
      sortBy.value = 'Low to High';
    } else {
      sortBy.value = 'High to Low';
    }
    loadProperties();
  }

  /// Open filter sheet
  void openFilter() {
    Get.bottomSheet(
      PropertiesFilterSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Reset all filters to default values
  void resetFilters() {
    filterPropertyType.value = 'plainLand';
    filterPriceRange.value = const PriceFilterRange(
      minPrice: 5000000,
      maxPrice: 80000000,
    );
    filterSellableLandAmount.value = const LandSizeFilterRange(
      minKatha: 7,
      maxKatha: 20,
    );
    filterPlotSize.value = const LandSizeFilterRange(minKatha: 7, maxKatha: 20);
    filterDistanceRange.value = const DistanceRange(
      label: '200m-750m',
      minMeters: 200,
      maxMeters: 750,
    );
    filterDivision.value = '';
    filterDistrict.value = '';
    filterUpazilla.value = '';
    filterPouroshova.value = '';
    filterWardNo.value = '';
  }

  /// Apply filters and reload properties
  void applyFilters() {
    // TODO: Apply filters to API call
    loadProperties();
  }

  /// Open location picker
  void openLocationPicker() {
    // TODO: Implement location picker
    Get.snackbar(
      'Location',
      'Location picker coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to property details
  void goToPropertyDetails(PropertyListing property) {
    final route = property.isLocked
        ? AppRoutes.PROPERTY_DETAILS_LOCKED
        : AppRoutes.PROPERTY_DETAILS_UNLOCKED;

    Get.toNamed(route, arguments: property.toMap());
  }

  /// Navigate to land wanted details
  void goToLandWantedDetails(String postId) {
    Get.toNamed(AppRoutes.BUY_POST_DETAILS, arguments: {'postId': postId});
  }

  /// Refresh properties
  Future<void> refresh() async {
    await loadProperties();
  }

  // ==================== Wanted/Needs Tab Methods ====================

  /// Change wanted sub-tab (All / Offered by you)
  void changeWantedSubTab(int index) {
    wantedSubTabIndex.value = index;
    loadWantedPosts();
  }

  /// Load wanted posts based on sub-tab
  Future<void> loadWantedPosts() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data for All wanted posts
      final List<LandWantedPost> mockAllPosts = [
        LandWantedPost(
          id: '1',
          postId: '#BUY-1042',
          title: '3 Bed Ready Flat Needed',
          postedBy: 'Farhan',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Flat',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
        ),
        LandWantedPost(
          id: '2',
          postId: '#BUY-1043',
          title: 'Looking for Agro Land',
          postedBy: 'Mr. Karim',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Plain Land',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
        ),
        LandWantedPost(
          id: '3',
          postId: '#BUY-1042',
          title: 'Luxury Flat',
          postedBy: 'Mr. Karim',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Flat',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
        ),
      ];

      // Mock data for Offered by you posts
      final List<LandWantedPost> mockOfferedPosts = [
        LandWantedPost(
          id: '1',
          postId: '#BUY-1042',
          title: '3 Bed Ready Flat Needed',
          postedBy: 'Farhan',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Flat',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          hasOffered: true,
          offerStatus: OfferStatus.buyerAcceptedAppointment,
        ),
        LandWantedPost(
          id: '2',
          postId: '#BUY-1043',
          title: 'Looking for Agro Land',
          postedBy: 'Mr. Karim',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Plain Land',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          hasOffered: true,
          offerStatus: OfferStatus.buyerAcceptedPendingAdmin,
        ),
        LandWantedPost(
          id: '3',
          postId: '#BUY-1042',
          title: 'Luxury Flat',
          postedBy: 'Mr. Karim',
          postedTime: '2h ago',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: 'Flat',
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          hasOffered: true,
          offerStatus: OfferStatus.pendingBuyerReview,
        ),
      ];

      allWantedPosts.assignAll(mockAllPosts);
      offeredByYouPosts.assignAll(mockOfferedPosts);
      offeredByYouCount.value = mockOfferedPosts.length;
      totalWantedPosts.value = mockAllPosts.length;
      _applyOfferedFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load wanted posts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle "I have this property" button
  void onIHaveThisProperty(LandWantedPost post) {
    // Navigate to create offer or show popup
    Get.snackbar(
      'Make Offer',
      'Offer feature for "${post.title}"',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to offer creation flow
    // Get.toNamed(AppRoutes.CREATE_OFFER, arguments: {'postId': post.id});
  }

  /// Handle "View Appointment" button
  void onViewAppointment(LandWantedPost post) {
    Get.snackbar(
      'Appointment',
      'View appointment for "${post.title}"',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to appointment details
  }

  /// Change offered by you filter
  void changeOfferedFilter(String filter) {
    offeredFilterBy.value = filter;
    _applyOfferedFilter();
  }

  /// Apply filter to offered posts
  void _applyOfferedFilter() {
    if (offeredFilterBy.value == 'All') {
      filteredOfferedPosts.assignAll(offeredByYouPosts);
    } else if (offeredFilterBy.value == 'Buyer Accepted') {
      final List<LandWantedPost> filtered = offeredByYouPosts
          .where(
            (post) =>
                post.offerStatus == OfferStatus.buyerAcceptedAppointment ||
                post.offerStatus == OfferStatus.buyerAcceptedPendingAdmin,
          )
          .toList();
      filteredOfferedPosts.assignAll(filtered);
    } else if (offeredFilterBy.value == 'Pending Buyer Review') {
      final List<LandWantedPost> filtered = offeredByYouPosts
          .where((post) => post.offerStatus == OfferStatus.pendingBuyerReview)
          .toList();
      filteredOfferedPosts.assignAll(filtered);
    }
  }
}
