import 'package:get/get.dart';
import '../../../../../core/enums/property_type.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../routes/app_routes.dart';
import 'models/offered_post_models.dart';
import 'offered_post_details_view.dart';

/// Controller for Offered Posts (offers made by user on Wanted/Needs posts)
class OfferedPostsController extends GetxController {
  // Loading state
  final isLoading = false.obs;

  // Filter/Sort options (matches design: All, Buyer Accepted, Pending Buyer Review)
  final filterOptions = ['All', 'Buyer Accepted', 'Pending Buyer Review'];
  final currentFilter = 'All'.obs;

  // Offered posts list
  final offeredPosts = <OfferedPost>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDemoData();
  }

  /// Load demo data
  void _loadDemoData() {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));

    offeredPosts.value = [
      // Buyer Accepted - matches design exactly
      OfferedPost(
        id: '1',
        postId: '#POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyPrice: '40,00,000',
        propertyType: PropertyType.flat,
        propertyImageUrl:
            'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        status: OfferedPostStatus.buyerAccepted,
        timestamp: '2h ago',
        timestampPrefix: 'Offered:',
        description:
            'A stunning newly renovated villa featuring an open-concept '
            "living area, chef's kitchen with top-tier appliances, and a "
            'private backyards oasis...',
        sellableLandAmount: '15 Katha',
        plotSize: '15 Katha',
        distanceFromRoad: '200m-750m',
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        propertyPhotos: [
          'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
          'assets/images/Properties demo/Gazipur Water Zone.jpg',
          'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
        ],
        buyerId: 'buyer_1',
        buyerName: 'Farhan',
        buyerVerified: true,
        originalBuyPostId: 'BUY-2024-001',
        originalBuyPostTitle: 'Looking for Villa in Banani',
        offeredAt: now.subtract(const Duration(hours: 2)),
        canMakeSellPostAt: threeDaysLater,
      ),
      // Pending Buyer Review
      OfferedPost(
        id: '2',
        postId: '#POST-1042',
        propertyTitle: '5 Katha Plot in Purbachal',
        propertyPrice: '2,00,00,000',
        propertyType: PropertyType.flat,
        propertyImageUrl:
            'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        status: OfferedPostStatus.pendingBuyerReview,
        timestamp: '2h ago',
        timestampPrefix: 'Offered:',
        description:
            'Prime location plot in Purbachal with excellent road connectivity. '
            'This plot is ideal for residential construction with all utilities available nearby.',
        sellableLandAmount: '5 Katha',
        plotSize: '5 Katha',
        distanceFromRoad: '0m (Road adjacent)',
        location: 'Sector 15, Purbachal, Dhaka',
        propertyPhotos: [
          'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        ],
        buyerId: 'buyer_2',
        buyerName: 'Fatima Begum',
        buyerVerified: false,
        originalBuyPostId: 'BUY-2024-003',
        originalBuyPostTitle: 'Looking for Land in Purbachal',
        offeredAt: now.subtract(const Duration(hours: 2)),
        canMakeSellPostAt: now.add(const Duration(days: 3)),
      ),
      // Another listing
      OfferedPost(
        id: '3',
        postId: '#POST-1042',
        propertyTitle: 'Gazipur Water Zone',
        propertyPrice: '95,12,000',
        propertyType: PropertyType.flat,
        propertyImageUrl:
            'assets/images/Properties demo/Gazipur Water Zone.jpg',
        status: OfferedPostStatus.pendingBuyerReview,
        timestamp: '2h ago',
        timestampPrefix: 'Offered:',
        description:
            'Beautiful water body land suitable for fishery or eco-tourism development.',
        sellableLandAmount: '10 Katha',
        plotSize: '10 Katha',
        distanceFromRoad: '50m',
        location: 'Gazipur Sadar, Gazipur',
        propertyPhotos: [
          'assets/images/Properties demo/Gazipur Water Zone.jpg',
        ],
        buyerId: 'buyer_3',
        buyerName: 'Kamal Hossain',
        buyerVerified: true,
        originalBuyPostId: 'BUY-2024-005',
        originalBuyPostTitle: 'Need Water Land for Fishery',
        offeredAt: now.subtract(const Duration(hours: 2)),
        canMakeSellPostAt: now.add(const Duration(days: 2)),
      ),
    ];
  }

  /// Get filtered offered posts
  List<OfferedPost> get filteredOfferedPosts {
    List<OfferedPost> filtered;

    switch (currentFilter.value) {
      case 'Buyer Accepted':
        filtered = offeredPosts
            .where(
              (p) =>
                  p.status == OfferedPostStatus.buyerAccepted ||
                  p.status == OfferedPostStatus.completed,
            )
            .toList();
        break;
      case 'Pending Buyer Review':
        filtered = offeredPosts
            .where((p) => p.status == OfferedPostStatus.pendingBuyerReview)
            .toList();
        break;
      default: // All
        filtered = offeredPosts.toList();
    }

    // Sort by newest first
    filtered.sort((a, b) => b.offeredAt.compareTo(a.offeredAt));

    return filtered;
  }

  /// Change filter
  void changeFilter(String filter) {
    currentFilter.value = filter;
  }

  /// Refresh data
  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _loadDemoData();
    isLoading.value = false;
  }

  /// Navigate to offered post details (uses nested navigation to keep bottom nav visible)
  void goToOfferDetails(OfferedPost post) {
    NestedNavigationService.to(
      const OfferedPostDetailsView(),
      arguments: {'offeredPost': post},
    );
  }

  /// Complete the post (for buyer accepted offers)
  void completePost(OfferedPost post) {
    Get.snackbar(
      'Complete Post',
      'Navigating to complete post flow...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to complete post flow
  }

  /// Make this a sell post instead
  void makeSellPost(OfferedPost post) {
    // Navigate to create sell post with pre-filled data
    Get.toNamed(
      AppRoutes.CREATE_SELL_POST_INFO,
      arguments: {'fromOfferedPost': true, 'offeredPost': post},
    );
  }
}
