import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../properties_controller.dart';

/// Controller for Offer from Existing Property
/// Allows selecting from user's active listings to offer
class OfferFromExistingController extends GetxController {
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
  Future<void> loadActiveProperties() async {
    isLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data - active sell posts from the user
      activeProperties.value = [
        PropertyListing(
          id: '1',
          postId: '#POST-1042',
          title: 'Modern Duplex Villa',
          location: 'Bashundhara R/A, Block C',
          price: '40,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: false,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          description: 'A stunning modern duplex villa with premium amenities.',
          sellableLandAmount: '5 Katha',
          plotSize: '5 Katha',
          distanceFromRoad: '200m-750m',
          postedBy: 'You',
          postedTime: '2h ago',
        ),
        PropertyListing(
          id: '2',
          postId: '#POST-1043',
          title: '5 Katha Plot in Purbachal',
          location: 'Sector 4, Dhaka',
          price: '2,00,00,000',
          propertyType: PropertyType.plainLand,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: false,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          description: 'Prime plot in Purbachal New Town.',
          sellableLandAmount: '5 Katha',
          plotSize: '5 Katha',
          distanceFromRoad: '0m-200m',
          postedBy: 'You',
          postedTime: '1d ago',
        ),
        PropertyListing(
          id: '3',
          postId: '#POST-1044',
          title: 'Gazipur Water Zone',
          location: 'Gazipur, Dhaka',
          price: '95,12,000',
          propertyType: PropertyType.waterLand,
          postType: PostType.sellPost,
          isVerified: true,
          isLocked: false,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/Gazipur Water Zone.jpg',
          description: 'Beautiful water land in Gazipur.',
          sellableLandAmount: '10 Katha',
          plotSize: '10 Katha',
          distanceFromRoad: '750m-2km',
          postedBy: 'You',
          postedTime: '3d ago',
        ),
      ];

      totalProperties.value = activeProperties.length;
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

  /// Refresh properties list
  Future<void> refresh() async {
    await loadActiveProperties();
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
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Show success and navigate back
      Get.back();
      Get.snackbar(
        'Offer Submitted',
        'Your offer has been sent to the buyer for review',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit offer. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
