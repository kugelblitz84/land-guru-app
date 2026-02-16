import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/services/services.dart';
import '../../../../../routes/app_routes.dart';
import '../../properties_controller.dart';

/// Controller for Offer from Existing Property
/// Allows selecting from user's active listings to offer
class OfferFromExistingController extends GetxController {
  final BuyPostOfferService _offerService = Get.find<BuyPostOfferService>();

  static List<PropertyListing> _cachedActiveProperties = <PropertyListing>[];
  static String _cachedSortBy = 'High to Low';
  static int _cachedTotalProperties = 120;
  static bool _hasCachedData = false;

  // State
  final RxBool isLoading = false.obs;
  final RxString buyPostId = ''.obs;
  final RxString buyPostTitle = ''.obs;
  final RxList<PropertyListing> activeProperties = <PropertyListing>[].obs;
  final RxSet<String> selectedPropertyIds = <String>{}.obs;

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxString selectedLocation =
      'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.'
          .obs;
  final RxString sortBy = 'High to Low'.obs;
  final RxInt totalProperties = 120.obs;

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
      activeProperties.assignAll(result.data!);
      totalProperties.value = activeProperties.length;
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
    activeProperties.assignAll(_cachedActiveProperties);
  }

  void _syncCache() {
    _cachedActiveProperties = List<PropertyListing>.from(activeProperties);
    _cachedSortBy = sortBy.value;
    _cachedTotalProperties = totalProperties.value;
    _hasCachedData = true;
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
    Get.toNamed(
      AppRoutes.PROPERTY_DETAILS_UNLOCKED,
      arguments: {
        ...property.toMap(),
        'pageTitle': 'Your Property Details',
        'isOfferFromExisting': true,
        'buyPostId': buyPostId.value,
      },
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
    // TODO: Implement filter sheet
    Get.snackbar(
      'Filter',
      'Filter options coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Change sort order
  void changeSortBy(String? value) {
    if (value != null) {
      sortBy.value = value;
      _sortProperties();
    }
  }

  void _sortProperties() {
    switch (sortBy.value) {
      case 'High to Low':
        activeProperties.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        break;
      case 'Low to High':
        activeProperties.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        break;
      // Add more sorting options as needed
    }
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
            sellPostId: sellPostId,
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
