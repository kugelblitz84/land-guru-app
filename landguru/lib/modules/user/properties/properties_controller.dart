import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/nested_navigation_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/enums/post_type.dart';
import '../../../core/models/property_listing.dart';
import 'wanted_and_needs/models/offer_status.dart';
import 'wanted_and_needs/models/land_wanted_post.dart';
import 'widgets/distance_range_selector.dart';
import 'widgets/properties_filter_sheet.dart';
import 'property_details/property_details_controller.dart';
import 'property_details/property_details_view.dart';

// Re-export for backward compatibility
export '../../../core/enums/property_type.dart';
export '../../../core/enums/post_type.dart';
export '../../../core/models/property_listing.dart';
export 'wanted_and_needs/models/offer_status.dart';
export 'wanted_and_needs/models/land_wanted_post.dart';

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

  /// Navigate to property details (uses nested navigation to keep bottom nav visible)
  void goToPropertyDetails(PropertyListing property) {
    // The unified PropertyDetailsView handles both locked and unlocked states
    NestedNavigationService.to(
      const PropertyDetailsView(),
      arguments: property.toMap(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PropertyDetailsController>(
          () => PropertyDetailsController(),
        );
      }),
    );
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
          description:
              'Client is looking for a ready flat in Dhanmondi area. Must have parking and be above 2nd floor.',
          hasOffered: true,
          offerStatus: OfferStatus.buyerAcceptedAppointment,
          offeredPropertyTitle: 'Modern Duplex Villa',
          offeredPropertyPrice: '40,00,000',
          offeredPropertyType: PropertyType.flat,
          offeredPropertyImageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
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
          description:
              'Looking for agricultural land suitable for farming. Must have water access and good soil quality.',
          hasOffered: true,
          offerStatus: OfferStatus.buyerAcceptedPendingAdmin,
          offeredPropertyTitle: '5 Katha Plot in Purbachal',
          offeredPropertyPrice: '2,00,00,000',
          offeredPropertyType: PropertyType.plainLand,
          offeredPropertyImageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
        ),
        LandWantedPost(
          id: '3',
          postId: '#BUY-1044',
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
          description:
              'Need a luxury flat with modern amenities, preferably in a gated community with 24/7 security.',
          hasOffered: true,
          offerStatus: OfferStatus.pendingBuyerReview,
          offeredPropertyTitle: 'Gazipur Water Zone',
          offeredPropertyPrice: '95,12,000',
          offeredPropertyType: PropertyType.waterLand,
          offeredPropertyImageUrl:
              'assets/images/Properties Listing - For Sale Images/Gazipur Water Zone.jpg',
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
    Get.toNamed(
      AppRoutes.CREATE_OFFER_INFO,
      arguments: {'postId': post.id, 'postTitle': post.title},
    );
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
