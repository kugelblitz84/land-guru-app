import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/nested_navigation_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/models/property_listing.dart';
import 'wanted_and_needs/models/offer_status.dart';
import 'wanted_and_needs/models/land_wanted_post.dart';
import 'widgets/distance_range_selector.dart';
import 'widgets/properties_filter_sheet.dart';
import 'for_sale/property_details/property_details_controller.dart';
import 'for_sale/property_details/property_details_view.dart';
import 'package:landguru/core/services/services.dart';

// Re-export for backward compatibility
export '../../../core/enums/property_type.dart';
export '../../../core/enums/post_type.dart';
export '../../../core/models/property_listing.dart';
export 'wanted_and_needs/models/offer_status.dart';
export 'wanted_and_needs/models/land_wanted_post.dart';

/// Controller for the Properties listing screen
/// Handles: For Sale, Land Wanted/Needs, My Posts tabs
class PropertiesController extends GetxController {
  final SellPostListingService _sellPostListingService =
      Get.find<SellPostListingService>();
  final BuyPostListingService _buyPostListingService =
      Get.find<BuyPostListingService>();
  final SellPostDetailsService _sellPostDetailsService =
      Get.find<SellPostDetailsService>();
  static const int _forSalePageLimit = 10;
  static const int _wantedPageLimit = 20;
  static List<PropertyListing> _cachedForSalePosts = <PropertyListing>[];
  static int _cachedForSaleCurrentPage = 1;
  static int _cachedForSaleApiTotal = 0;
  static bool _cachedHasMoreForSale = true;
  static bool _hasCachedForSaleData = false;
  static List<LandWantedPost> _cachedAllWantedPosts = <LandWantedPost>[];
  static List<LandWantedPost> _cachedOfferedByYouPosts = <LandWantedPost>[];
  static int _cachedOfferedByYouCount = 0;
  static int _cachedTotalWantedPosts = 0;
  static int _cachedWantedCurrentPage = 1;
  static int _cachedWantedApiTotal = 0;
  static bool _cachedHasMoreWanted = true;
  static bool _hasCachedWantedData = false;
  static const PriceFilterRange _defaultPriceFilterRange = PriceFilterRange(
    minPrice: 5000000,
    maxPrice: 80000000,
  );
  static const LandSizeFilterRange _defaultLandSizeFilterRange =
      LandSizeFilterRange(minKatha: 7, maxKatha: 20);
  static const DistanceRange _defaultDistanceRange = DistanceRange(
    label: '200m-750m',
    minMeters: 200,
    maxMeters: 750,
  );
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
  final RxBool isLoadingMoreForSale = false.obs;
  final RxBool hasMoreForSale = true.obs;
  final RxBool isLoadingMoreWanted = false.obs;
  final RxBool hasMoreWanted = true.obs;

  // Lists
  final RxList<PropertyListing> propertiesForSale = <PropertyListing>[].obs;
  final List<PropertyListing> _allForSalePosts = <PropertyListing>[];
  int _forSaleCurrentPage = 1;
  int _forSaleApiTotal = 0;
  int _wantedCurrentPage = 1;
  int _wantedApiTotal = 0;
  bool _isForSaleFilterApplied = false;
  final RxList<PropertyListing> propertiesWanted = <PropertyListing>[].obs;
  final RxList<PropertyListing> myPosts = <PropertyListing>[].obs;

  // Wanted/Needs tab state
  final RxInt wantedSubTabIndex = 0.obs; // 0 = All, 1 = Offered by you
  final RxList<LandWantedPost> allWantedPosts = <LandWantedPost>[].obs;
  final RxList<LandWantedPost> offeredByYouPosts = <LandWantedPost>[].obs;
  final RxList<LandWantedPost> filteredOfferedPosts = <LandWantedPost>[].obs;
  final RxInt totalWantedPosts = 0.obs;
  final RxInt offeredByYouCount = 0.obs;

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
    _defaultPriceFilterRange,
  );
  final Rxn<LandSizeFilterRange> filterSellableLandAmount =
      Rxn<LandSizeFilterRange>(_defaultLandSizeFilterRange);
  final Rxn<LandSizeFilterRange> filterPlotSize = Rxn<LandSizeFilterRange>(
    _defaultLandSizeFilterRange,
  );
  final Rxn<DistanceRange> filterDistanceRange = Rxn<DistanceRange>(
    _defaultDistanceRange,
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
  Future<void> loadProperties({bool forceRefresh = false}) async {
    if (selectedTabIndex.value != 0) return;
    if (isLoading.value) return;

    if (!forceRefresh && _hasCachedForSaleData) {
      _restoreForSaleFromCache();
      return;
    }

    isLoading.value = true;
    _forSaleCurrentPage = 1;
    hasMoreForSale.value = true;

    await _fetchForSalePage(page: _forSaleCurrentPage, reset: true);

    _syncForSaleCache();

    isLoading.value = false;
  }

  Future<void> loadMoreForSaleIfNeeded() async {
    if (selectedTabIndex.value != 0 ||
        isLoading.value ||
        isLoadingMoreForSale.value ||
        !hasMoreForSale.value) {
      return;
    }

    isLoadingMoreForSale.value = true;
    final nextPage = _forSaleCurrentPage + 1;
    final success = await _fetchForSalePage(page: nextPage);
    if (success) {
      _forSaleCurrentPage = nextPage;
      _syncForSaleCache();
    }
    isLoadingMoreForSale.value = false;
  }

  void _restoreForSaleFromCache() {
    _allForSalePosts
      ..clear()
      ..addAll(_cachedForSalePosts);
    _forSaleCurrentPage = _cachedForSaleCurrentPage;
    _forSaleApiTotal = _cachedForSaleApiTotal;
    hasMoreForSale.value = _cachedHasMoreForSale;
    _applyForSaleFiltersAndSort();
  }

  void _syncForSaleCache() {
    _cachedForSalePosts = List<PropertyListing>.from(_allForSalePosts);
    _cachedForSaleCurrentPage = _forSaleCurrentPage;
    _cachedForSaleApiTotal = _forSaleApiTotal;
    _cachedHasMoreForSale = hasMoreForSale.value;
    _hasCachedForSaleData = true;
  }

  Future<bool> _fetchForSalePage({
    required int page,
    bool reset = false,
  }) async {
    final result = await ApiErrorHandler.call(
      () => _sellPostListingService.getSellPosts(
        page: page,
        limit: _forSalePageLimit,
      ),
    );

    if (!result.isSuccess || result.data == null) {
      return false;
    }

    final posts = result.data!.posts;

    if (reset) {
      _allForSalePosts.clear();
    }

    final existingIds = _allForSalePosts.map((post) => post.id).toSet();
    final newPosts = posts
        .where((post) => !existingIds.contains(post.id))
        .toList();

    _allForSalePosts.addAll(newPosts);
    _applyForSaleFiltersAndSort();

    if (result.data!.total > 0) {
      _forSaleApiTotal = result.data!.total;
      totalProperties.value = result.data!.total;
      hasMoreForSale.value = _allForSalePosts.length < result.data!.total;
    } else {
      _forSaleApiTotal = _allForSalePosts.length;
      hasMoreForSale.value = posts.length >= _forSalePageLimit;
    }

    if (posts.isEmpty || newPosts.isEmpty) {
      hasMoreForSale.value = false;
    }

    return true;
  }

  /// Perform search
  void search() {
    searchQuery.value = searchController.text;
    _applyForSaleFiltersAndSort();
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
    _applyForSaleFiltersAndSort();
  }

  /// Update sort
  void updateSort(String sort) {
    sortBy.value = sort;
    _applyForSaleFiltersAndSort();
  }

  /// Toggle sort order
  void toggleSort() {
    if (sortBy.value == 'High to Low') {
      sortBy.value = 'Low to High';
    } else {
      sortBy.value = 'High to Low';
    }
    _applyForSaleFiltersAndSort();
  }

  void _applyForSaleFiltersAndSort() {
    final query = searchQuery.value.trim().toLowerCase();
    final selectedPriceRange = filterPriceRange.value;
    final selectedSellableRange = filterSellableLandAmount.value;
    final selectedPlotRange = filterPlotSize.value;
    final selectedDistanceRange = filterDistanceRange.value;

    final selectedDivision = filterDivision.value.trim().toLowerCase();
    final selectedDistrict = filterDistrict.value.trim().toLowerCase();
    final selectedUpazilla = filterUpazilla.value.trim().toLowerCase();
    final selectedPouroshova = filterPouroshova.value.trim().toLowerCase();
    final selectedWard = filterWardNo.value.trim().toLowerCase();

    final filtered = _allForSalePosts.where((property) {
      final matchesSearch =
          query.isEmpty ||
          property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query);

      if (!matchesSearch) {
        return false;
      }

      if (_isForSaleFilterApplied) {
        final matchesPropertyType = _matchesPropertyTypeFilter(property);
        if (!matchesPropertyType) {
          return false;
        }

        if (selectedPriceRange != null) {
          final price = _parsePriceForSort(property.price);
          if (price < selectedPriceRange.minPrice ||
              price > selectedPriceRange.maxPrice) {
            return false;
          }
        }

        if (selectedSellableRange != null) {
          final sellableValue = _extractLeadingNumber(
            property.sellableLandAmount,
          );
          if (sellableValue != null &&
              (sellableValue < selectedSellableRange.minKatha ||
                  sellableValue > selectedSellableRange.maxKatha)) {
            return false;
          }
        }

        if (selectedPlotRange != null) {
          final plotValue = _extractLeadingNumber(property.plotSize);
          if (plotValue != null &&
              (plotValue < selectedPlotRange.minKatha ||
                  plotValue > selectedPlotRange.maxKatha)) {
            return false;
          }
        }

        if (selectedDistanceRange != null) {
          final parsedDistance = _parseDistanceRange(property.distanceFromRoad);
          if (parsedDistance != null) {
            final minDistance = parsedDistance[0];
            final maxDistance = parsedDistance[1];

            final isOverlappingRange =
                maxDistance >= selectedDistanceRange.minMeters &&
                minDistance <= selectedDistanceRange.maxMeters;
            if (!isOverlappingRange) {
              return false;
            }
          }
        }

        final location = property.location.toLowerCase();
        if (selectedDivision.isNotEmpty &&
            !location.contains(selectedDivision)) {
          return false;
        }
        if (selectedDistrict.isNotEmpty &&
            !location.contains(selectedDistrict)) {
          return false;
        }
        if (selectedUpazilla.isNotEmpty &&
            !location.contains(selectedUpazilla)) {
          return false;
        }
        if (selectedPouroshova.isNotEmpty &&
            !location.contains(selectedPouroshova)) {
          return false;
        }
        if (selectedWard.isNotEmpty && !location.contains(selectedWard)) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final priceA = _parsePriceForSort(a.price);
      final priceB = _parsePriceForSort(b.price);
      if (sortBy.value == 'Low to High') {
        return priceA.compareTo(priceB);
      }
      return priceB.compareTo(priceA);
    });

    propertiesForSale.assignAll(filtered);

    if (searchQuery.value.trim().isNotEmpty || _isForSaleFilterApplied) {
      totalProperties.value = filtered.length;
      return;
    }

    totalProperties.value = _forSaleApiTotal > 0
        ? _forSaleApiTotal
        : _allForSalePosts.length;
  }

  double _parsePriceForSort(String priceText) {
    final normalized = priceText.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  bool _matchesPropertyTypeFilter(PropertyListing property) {
    switch (filterPropertyType.value) {
      case 'plainLand':
        return property.propertyType == PropertyType.plainLand;
      case 'waterLand':
        return property.propertyType == PropertyType.waterLand;
      case 'flat':
        return property.propertyType == PropertyType.flat;
      case 'commercial':
      case 'agroLand':
      case 'blankRoof':
      default:
        return false;
    }
  }

  double? _extractLeadingNumber(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawValue);
    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  List<double>? _parseDistanceRange(String? rawDistance) {
    if (rawDistance == null || rawDistance.trim().isEmpty) {
      return null;
    }

    final matches = RegExp(r'(\d+(?:\.\d+)?)')
        .allMatches(rawDistance)
        .map((match) => double.tryParse(match.group(1)!))
        .whereType<double>()
        .toList();

    if (matches.isEmpty) {
      return null;
    }

    if (matches.length == 1) {
      return [matches.first, matches.first];
    }

    return [matches.first, matches.last];
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
    filterPriceRange.value = _defaultPriceFilterRange;
    filterSellableLandAmount.value = _defaultLandSizeFilterRange;
    filterPlotSize.value = _defaultLandSizeFilterRange;
    filterDistanceRange.value = _defaultDistanceRange;
    filterDivision.value = '';
    filterDistrict.value = '';
    filterUpazilla.value = '';
    filterPouroshova.value = '';
    filterWardNo.value = '';

    _isForSaleFilterApplied = false;
    _applyForSaleFiltersAndSort();
  }

  /// Apply filters and reload properties
  void applyFilters() {
    _isForSaleFilterApplied = true;
    _applyForSaleFiltersAndSort();
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
  Future<void> goToPropertyDetails(PropertyListing property) async {
    final detailsResult = await ApiErrorHandler.call(
      () => _sellPostDetailsService.getSellPostById(property.id),
    );

    if (!detailsResult.isSuccess || detailsResult.data == null) {
      return;
    }

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
    await loadProperties(forceRefresh: true);
  }

  // ==================== Wanted/Needs Tab Methods ====================

  /// Change wanted sub-tab (All / Offered by you)
  void changeWantedSubTab(int index) {
    wantedSubTabIndex.value = index;
    loadWantedPosts(forceRefresh: false);
  }

  /// Load wanted posts based on sub-tab
  Future<void> loadWantedPosts({bool forceRefresh = false}) async {
    if (wantedSubTabIndex.value == 1 && !forceRefresh) {
      _applyOfferedFilter();
      return;
    }

    if (!forceRefresh && _hasCachedWantedData) {
      _restoreWantedFromCache();
      return;
    }

    isLoading.value = true;
    _wantedCurrentPage = 1;
    hasMoreWanted.value = true;
    try {
      final success = await _fetchWantedPage(
        page: _wantedCurrentPage,
        reset: true,
      );
      if (!success) {
        allWantedPosts.clear();
        offeredByYouPosts.clear();
        filteredOfferedPosts.clear();
        offeredByYouCount.value = 0;
        totalWantedPosts.value = 0;
        hasMoreWanted.value = false;
        return;
      }

      offeredByYouPosts.clear();
      filteredOfferedPosts.clear();
      offeredByYouCount.value = 0;

      _applyOfferedFilter();
      _syncWantedCache();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreWantedIfNeeded() async {
    if (selectedTabIndex.value != 1 ||
        wantedSubTabIndex.value != 0 ||
        isLoading.value ||
        isLoadingMoreWanted.value ||
        !hasMoreWanted.value) {
      return;
    }

    isLoadingMoreWanted.value = true;
    final nextPage = _wantedCurrentPage + 1;
    final success = await _fetchWantedPage(page: nextPage);
    if (success) {
      _wantedCurrentPage = nextPage;
      _syncWantedCache();
    }
    isLoadingMoreWanted.value = false;
  }

  Future<bool> _fetchWantedPage({required int page, bool reset = false}) async {
    final result = await ApiErrorHandler.call(
      () => _buyPostListingService.getAllBuyPosts(
        page: page,
        limit: _wantedPageLimit,
      ),
    );

    if (!result.isSuccess || result.data == null) {
      return false;
    }

    final payload = result.data!;
    if (reset) {
      allWantedPosts.clear();
    }

    final existingIds = allWantedPosts.map((post) => post.id).toSet();
    final newPosts = payload.posts
        .where((post) => !existingIds.contains(post.id))
        .toList();

    allWantedPosts.addAll(newPosts);

    if (payload.total > 0) {
      _wantedApiTotal = payload.total;
      totalWantedPosts.value = payload.total;
      hasMoreWanted.value = allWantedPosts.length < payload.total;
    } else {
      _wantedApiTotal = allWantedPosts.length;
      totalWantedPosts.value = allWantedPosts.length;
      hasMoreWanted.value = payload.posts.length >= _wantedPageLimit;
    }

    if (payload.posts.isEmpty || newPosts.isEmpty) {
      hasMoreWanted.value = false;
    }

    return true;
  }

  void _restoreWantedFromCache() {
    allWantedPosts.assignAll(_cachedAllWantedPosts);
    offeredByYouPosts.assignAll(_cachedOfferedByYouPosts);
    offeredByYouCount.value = _cachedOfferedByYouCount;
    totalWantedPosts.value = _cachedTotalWantedPosts;
    _wantedCurrentPage = _cachedWantedCurrentPage;
    _wantedApiTotal = _cachedWantedApiTotal;
    hasMoreWanted.value = _cachedHasMoreWanted;
    _applyOfferedFilter();
  }

  void _syncWantedCache() {
    _cachedAllWantedPosts = List<LandWantedPost>.from(allWantedPosts);
    _cachedOfferedByYouPosts = List<LandWantedPost>.from(offeredByYouPosts);
    _cachedOfferedByYouCount = offeredByYouCount.value;
    _cachedTotalWantedPosts = totalWantedPosts.value;
    _cachedWantedCurrentPage = _wantedCurrentPage;
    _cachedWantedApiTotal = _wantedApiTotal;
    _cachedHasMoreWanted = hasMoreWanted.value;
    _hasCachedWantedData = true;
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
