import 'package:get/get.dart';
import '../../../../../core/enums/property_type.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../routes/app_routes.dart';
import 'models/buy_post_models.dart';
import 'buy_post_offer_details_view.dart';

/// Controller for Buy Posts section
class BuyPostsController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // Filter state
  final RxString currentFilter = 'All'.obs;
  final List<String> filterOptions = ['All', 'Offers', 'Active', 'In Review'];

  // Sort state
  final RxString sortBy = 'Newest First'.obs;
  final List<String> sortOptions = [
    'Newest First',
    'Oldest First',
    'Most Offers',
    'Least Offers',
  ];

  // Posts data
  final RxList<BuyPost> allBuyPosts = <BuyPost>[].obs;
  final RxList<BuyPost> filteredBuyPosts = <BuyPost>[].obs;

  // Counts
  final RxInt offersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBuyPosts();
  }

  /// Load all buy posts
  Future<void> loadBuyPosts() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data for Buy Posts with detailed offers
      allBuyPosts.value = [
        BuyPost(
          id: '1',
          postId: '#BUY-1042',
          title: 'Villa in Banasree',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: PropertyType.flat,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          description:
              'Client is looking for a ready flat in Dhanmondi area. Must have parking and be above 2nd floor.',
          status: BuyPostStatus.active,
          timestamp: '2h ago',
          timestampPrefix: 'Posted:',
          offersReceived: [
            OfferReceived(
              id: 'o1',
              propertyTitle: 'Modern Duplex Villa',
              propertyPrice: '40,00,000',
              propertyType: PropertyType.flat,
              propertyImageUrl:
                  'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
              offeredTime: '2h ago',
              status: OfferReceivedStatus.pending,
              sellerId: 's1',
              sellerName: 'Khaled',
              sellerVerified: true,
              postId: '#POST-1042',
              description:
                  'A stunning newly renovated villa featuring an open-concept living area, chef\'s kitchen with top-tier appliances, and a private backyards oasis...',
              sellableLandAmount: '15 Katha',
              plotSize: '15 Katha',
              distanceFromRoad: '200m-750m',
              location:
                  'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
              propertyPhotos: [
                'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
                'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
                'assets/images/Properties Listing - For Sale Images/gazipur water zone.jpg',
              ],
            ),
            OfferReceived(
              id: 'o2',
              propertyTitle: '5 Katha Plot in Purbachal',
              propertyPrice: '40,00,000',
              propertyType: PropertyType.flat,
              propertyImageUrl:
                  'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
              offeredTime: '2h ago',
              status: OfferReceivedStatus.pending,
              sellerId: 's2',
              sellerName: 'Rafiq',
              sellerVerified: true,
              postId: '#POST-1043',
              description:
                  'Prime plot in Purbachal with excellent road access and all utilities available.',
              sellableLandAmount: '5 Katha',
              plotSize: '5 Katha',
              distanceFromRoad: '50m-100m',
              location: 'Purbachal, Dhaka, Bangladesh.',
              propertyPhotos: [
                'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
              ],
            ),
            OfferReceived(
              id: 'o3',
              propertyTitle: 'Gazipur Water Zone',
              propertyPrice: '40,00,000',
              propertyType: PropertyType.flat,
              propertyImageUrl:
                  'assets/images/Properties Listing - For Sale Images/gazipur water zone.jpg',
              offeredTime: '2h ago',
              status: OfferReceivedStatus.pending,
              sellerId: 's3',
              sellerName: 'Ahmed',
              sellerVerified: false,
              postId: '#POST-1044',
              description: 'Beautiful water zone property in Gazipur.',
              sellableLandAmount: '10 Katha',
              plotSize: '10 Katha',
              distanceFromRoad: '100m-200m',
              location: 'Gazipur, Dhaka Division, Bangladesh.',
              propertyPhotos: [
                'assets/images/Properties Listing - For Sale Images/gazipur water zone.jpg',
              ],
            ),
          ],
        ),
        BuyPost(
          id: '2',
          postId: '#BUY-1043',
          title: 'Want a Plain Land near Banasree Block C',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: PropertyType.plainLand,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          status: BuyPostStatus.active,
          timestamp: '2h ago',
          timestampPrefix: 'Posted:',
          offersReceived: [],
        ),
        BuyPost(
          id: '3',
          postId: '#BUY-1044',
          title: 'Want a Plain Land near Banasree Block C',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: PropertyType.plainLand,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          status: BuyPostStatus.pending,
          timestamp: '2h ago',
          timestampPrefix: 'Submitted:',
          offersReceived: [],
        ),
        BuyPost(
          id: '4',
          postId: '#BUY-1045',
          title: '3 Bed Ready Flat Needed',
          preferredLocation:
              'Banasree, Ward No. 25, Dhaka South City Corporation, Khilgaon Thana, Dhaka - 1219, Dhaka Division.',
          propertyType: PropertyType.flat,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          status: BuyPostStatus.active,
          timestamp: '3h ago',
          timestampPrefix: 'Posted:',
          offersReceived: [],
          acceptedOffer: OfferReceived(
            id: 'o4',
            propertyTitle: 'Modern Duplex Villa',
            propertyPrice: '40,00,000',
            propertyType: PropertyType.flat,
            propertyImageUrl:
                'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
            offeredTime: '2h ago',
            status: OfferReceivedStatus.pendingAdminReview,
            sellerId: 's4',
            sellerName: 'Farhan',
            sellerVerified: true,
            postId: '#POST-1045',
            description:
                'A stunning newly renovated villa featuring an open-concept living area.',
            sellableLandAmount: '15 Katha',
            plotSize: '15 Katha',
            distanceFromRoad: '200m-750m',
            location: 'Block-C, Banani, Dhaka, Bangladesh.',
            propertyPhotos: [
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
            ],
          ),
        ),
        BuyPost(
          id: '5',
          postId: '#BUY-1046',
          title: 'Looking for Agro Land',
          preferredLocation: 'Gazipur, Dhaka Division.',
          propertyType: PropertyType.plainLand,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '200m-750m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          status: BuyPostStatus.pending,
          timestamp: '5h ago',
          timestampPrefix: 'Submitted:',
          offersReceived: [],
        ),
        BuyPost(
          id: '6',
          postId: '#BUY-1047',
          title: 'Resort in Gulshan',
          preferredLocation: 'Gulshan, Dhaka Division.',
          propertyType: PropertyType.flat,
          requiredLandSize: 'Min 5 Katha',
          requiredPlotSize: 'Min 5 Katha',
          distanceFromRoad: '50m',
          budgetRange: '৳ 30,00,000 - ৳ 40,00,000',
          status: BuyPostStatus.draft,
          timestamp: '1d ago',
          timestampPrefix: 'Edited:',
          offersReceived: [],
        ),
      ];

      // Calculate offers count
      offersCount.value = allBuyPosts.fold(
        0,
        (sum, post) => sum + post.offersCount,
      );

      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load buy posts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Change filter
  void changeFilter(String filter) {
    currentFilter.value = filter;
    _applyFilter();
  }

  /// Change sort
  void changeSortBy(String sort) {
    sortBy.value = sort;
    _sortPosts();
  }

  /// Apply current filter
  void _applyFilter() {
    switch (currentFilter.value) {
      case 'All':
        filteredBuyPosts.assignAll(allBuyPosts);
        break;
      case 'Offers':
        filteredBuyPosts.assignAll(
          allBuyPosts.where((p) => p.hasOffers).toList(),
        );
        break;
      case 'Active':
        filteredBuyPosts.assignAll(
          allBuyPosts.where((p) => p.status == BuyPostStatus.active).toList(),
        );
        break;
      case 'In Review':
        filteredBuyPosts.assignAll(
          allBuyPosts
              .where(
                (p) =>
                    p.status == BuyPostStatus.pending ||
                    p.showPendingAdminReview,
              )
              .toList(),
        );
        break;
      default:
        filteredBuyPosts.assignAll(allBuyPosts);
    }
    _sortPosts();
  }

  /// Sort posts
  void _sortPosts() {
    switch (sortBy.value) {
      case 'Most Offers':
        filteredBuyPosts.sort((a, b) => b.offersCount.compareTo(a.offersCount));
        break;
      case 'Least Offers':
        filteredBuyPosts.sort((a, b) => a.offersCount.compareTo(b.offersCount));
        break;
      case 'Newest First':
        // TODO: Sort by actual date
        break;
      case 'Oldest First':
        // TODO: Sort by actual date
        break;
    }
  }

  /// Get badge count for a filter
  int getBadgeCount(String filter) {
    switch (filter) {
      case 'Offers':
        return allBuyPosts.where((p) => p.hasOffers).length;
      default:
        return 0;
    }
  }

  /// Refresh posts
  Future<void> refresh() async {
    await loadBuyPosts();
  }

  /// Navigate to buy post offers popup
  void showOffersPopup(BuyPost post) {
    // This will be handled by the view using the popup widget
  }

  /// Navigate to offer details (uses nested navigation to keep bottom nav visible)
  void goToOfferDetails(BuyPost buyPost, OfferReceived offer) {
    NestedNavigationService.to(
      const BuyPostOfferDetailsView(),
      arguments: {'buyPost': buyPost, 'offer': offer},
    );
  }

  /// Accept an offer
  Future<void> acceptOffer(BuyPost buyPost, OfferReceived offer) async {
    // TODO: Implement offer acceptance logic
    Get.snackbar(
      'Offer Accepted',
      'You have accepted the offer for ${offer.propertyTitle}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// View appointment
  void viewAppointment(BuyPost post) {
    // TODO: Navigate to appointments page
    Get.snackbar(
      'Appointment',
      'View appointment for ${post.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
