import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/services.dart';
import '../../for_sale/property_details/property_details_controller.dart';
import '../../for_sale/property_details/property_details_view.dart';
import '../models/models.dart';
import '../../property_filter_criteria.dart';
import '../../properties_controller.dart';
import '../../widgets/distance_range_selector.dart';
import '../../widgets/properties_filter_sheet.dart';
import 'package:landguru/core/services/nested_navigation_service.dart';

/// Controller for Offer from Existing Property
/// Allows selecting from user's active listings to offer
class OfferFromExistingController extends GetxController {
  OfferFromExistingController(this._offerService);

  final BuyPostOfferService _offerService;

  static List<PropertyListing> _cachedAllActiveProperties = <PropertyListing>[];
  static String _cachedSortBy = 'High to Low';
  static int _cachedTotalProperties = 120;
  static bool _hasCachedData = false;

  // State
  final RxBool isLoading = false.obs;
  final RxString buyPostId = ''.obs;
  final RxString buyPostTitle = ''.obs;
  final RxList<PropertyListing> activeProperties = <PropertyListing>[].obs;
  final List<PropertyListing> _allActiveProperties = <PropertyListing>[];
  final RxSet<String> selectedPropertyIds = <String>{}.obs;

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedLocation =
      'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.'
          .obs;
  final RxString sortBy = 'High to Low'.obs;
  final RxInt totalProperties = 120.obs;

  // Shared filter state with Properties page
  final RxBool isFilterApplied = false.obs;
  final RxInt filterApplyVersion = 0.obs;
  final RxString filterPropertyType = 'all'.obs;
  final Rxn<PriceFilterRange> filterPriceRange = Rxn<PriceFilterRange>();
  final Rxn<LandSizeFilterRange> filterSellableLandAmount =
      Rxn<LandSizeFilterRange>();
  final Rxn<LandSizeFilterRange> filterPlotSize = Rxn<LandSizeFilterRange>();
  final Rxn<DistanceRange> filterDistanceRange = Rxn<DistanceRange>();

  final RxString filterDivision = ''.obs;
  final RxString filterDistrict = ''.obs;
  final RxString filterUpazilla = ''.obs;
  final RxString filterPouroshova = ''.obs;
  final RxString filterWardNo = ''.obs;

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

  // Sort options
  final List<String> sortOptions = [
    'High to Low',
    'Low to High',
    'Newest First',
    'Oldest First',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      buyPostId.value = Get.arguments['postId'] ?? '';
      buyPostTitle.value = Get.arguments['postTitle'] ?? '';
    }
    loadActiveProperties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load user's active properties
  Future<void> loadActiveProperties({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    final result = await ApiErrorHandler.call(
      () => _offerService.getMyActiveSellPosts(),
    );
    if (result.isSuccess && result.data != null) {
      _allActiveProperties
        ..clear()
        ..addAll(result.data!);
      _applySearchAndFilters();
      _syncCache();
    }
    isLoading.value = false;
  }

  /// Refresh properties list
  Future<void> refresh() async {
    await loadActiveProperties(forceRefresh: true);
  }

  void _restoreFromCache() {
    sortBy.value = _cachedSortBy;
    totalProperties.value = _cachedTotalProperties;
    _allActiveProperties
      ..clear()
      ..addAll(_cachedAllActiveProperties);
    _applySearchAndFilters();
  }

  void _syncCache() {
    _cachedAllActiveProperties = List<PropertyListing>.from(
      _allActiveProperties,
    );
    _cachedSortBy = sortBy.value;
    _cachedTotalProperties = totalProperties.value;
    _hasCachedData = true;
  }

  PropertyFilterCriteria get currentFilterCriteria {
    final selectedPriceRange = filterPriceRange.value;
    final selectedSellableRange = filterSellableLandAmount.value;
    final selectedPlotRange = filterPlotSize.value;
    final selectedDistanceRange = filterDistanceRange.value;

    return PropertyFilterCriteria(
      isApplied: isFilterApplied.value,
      propertyTypeKey: filterPropertyType.value,
      minPrice: selectedPriceRange?.minPrice.toDouble(),
      maxPrice: selectedPriceRange?.maxPrice.toDouble(),
      minSellableKatha: selectedSellableRange?.minKatha,
      maxSellableKatha: selectedSellableRange?.maxKatha,
      minPlotKatha: selectedPlotRange?.minKatha,
      maxPlotKatha: selectedPlotRange?.maxKatha,
      minDistanceMeters: selectedDistanceRange?.minMeters.toDouble(),
      maxDistanceMeters: selectedDistanceRange?.maxMeters.toDouble(),
      division: filterDivision.value.trim().toLowerCase(),
      district: filterDistrict.value.trim().toLowerCase(),
      upazilla: filterUpazilla.value.trim().toLowerCase(),
      pouroshova: filterPouroshova.value.trim().toLowerCase(),
      wardNo: filterWardNo.value.trim().toLowerCase(),
    );
  }

  void search() {
    searchQuery.value = searchController.text;
    _applySearchAndFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applySearchAndFilters();
  }

  void applyFilters() {
    isFilterApplied.value = true;
    filterApplyVersion.value++;
    _applySearchAndFilters();
  }

  void resetFilters() {
    filterPropertyType.value = 'all';
    filterPriceRange.value = null;
    filterSellableLandAmount.value = null;
    filterPlotSize.value = null;
    filterDistanceRange.value = null;
    filterDivision.value = '';
    filterDistrict.value = '';
    filterUpazilla.value = '';
    filterPouroshova.value = '';
    filterWardNo.value = '';

    isFilterApplied.value = false;
    filterApplyVersion.value++;
    _applySearchAndFilters();
  }

  /// Toggle property selection
  void togglePropertySelection(String propertyId) {
    if (selectedPropertyIds.contains(propertyId)) {
      selectedPropertyIds.remove(propertyId);
    } else {
      selectedPropertyIds.add(propertyId);
    }
  }

  /// Check if property is selected
  bool isPropertySelected(String propertyId) {
    return selectedPropertyIds.contains(propertyId);
  }

  /// View property details
  /// Navigates to property details with offer flow flags
  void viewPropertyDetails(PropertyListing property) {
    final args = <String, dynamic>{
      'id': property.id,
      'postId': property.postId,
      'isLocked': false,
      'pageTitle': 'Your Property Details',
      'isOfferFromExisting': true,
      'buyPostId': buyPostId.value,
    };

    NestedNavigationService.to(
      const PropertyDetailsView(),
      id: 1,
      arguments: args,
      binding: BindingsBuilder(() {
        if (Get.isRegistered<PropertyDetailsController>()) {
          Get.delete<PropertyDetailsController>(force: true);
        }
        Get.put<PropertyDetailsController>(
          PropertyDetailsController(initialArguments: args),
        );
      }),
    );
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

  /// Open filter sheet
  void openFilterSheet() {
    Get.bottomSheet(
      PropertiesFilterSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Change sort order
  void changeSortBy(String? value) {
    if (value != null) {
      sortBy.value = value;
      _applySearchAndFilters();
      _syncCache();
    }
  }

  void _sortProperties(List<PropertyListing> list) {
    switch (sortBy.value) {
      case 'High to Low':
        list.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        break;
      case 'Low to High':
        list.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        break;
      // Add more sorting options as needed
    }
  }

  void _applySearchAndFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final criteria = currentFilterCriteria;

    final filtered = _allActiveProperties.where((property) {
      final matchesSearch =
          query.isEmpty ||
          property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query);

      if (!matchesSearch) {
        return false;
      }

      return criteria.matches(
        propertyType: property.propertyType,
        price: property.price,
        sellableLandAmount: property.sellableLandAmount,
        plotSize: property.plotSize,
        distanceFromRoad: property.distanceFromRoad,
        location: property.location,
      );
    }).toList();

    _sortProperties(filtered);
    activeProperties.assignAll(filtered);

    if (searchQuery.value.trim().isNotEmpty || isFilterApplied.value) {
      totalProperties.value = filtered.length;
      return;
    }

    totalProperties.value = _allActiveProperties.length;
  }

  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(',', '')) ?? 0;
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }

  /// Submit offer with selected properties
  Future<void> submitOffer() async {
    if (selectedPropertyIds.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select at least one property to offer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final selectedIds = selectedPropertyIds.toList(growable: false);
    final result = await ApiErrorHandler.call(
      () => Future.wait(
        selectedIds.map(
          (sellPostId) => _offerService.makeOfferFromExisting(
            buyPostId: buyPostId.value,
            payload: MakeOfferFromExistingPayload(sellPostId: sellPostId),
          ),
        ),
      ),
    );

    if (result.isSuccess) {
      Get.back();
      Get.snackbar(
        'Offer Submitted',
        selectedIds.length == 1
            ? 'Your offer has been sent to the buyer for review'
            : '${selectedIds.length} offers have been sent to the buyer for review',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }
}
