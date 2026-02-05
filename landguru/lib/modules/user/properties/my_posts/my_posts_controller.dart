import 'package:get/get.dart';
import '../../../../core/enums/property_type.dart';
import '../../../../core/enums/post_type.dart';
import '../../../../core/services/nested_navigation_service.dart';
import 'models/my_post.dart';
import 'models/my_post_status.dart';
import 'sell_posts/sell_post_details_controller.dart';
import 'sell_posts/sell_post_details_view.dart';

export 'models/my_post.dart';
export 'models/my_post_status.dart';

/// Controller for My Posts section
/// Handles: Sell Posts, Buy Posts, Offered Posts tabs
class MyPostsController extends GetxController {
  // Sub-tab state: 0 = Sell Posts, 1 = Buy Posts, 2 = Offered Posts
  final RxInt subTabIndex = 0.obs;

  // Filter state for posts
  final RxString currentFilter = 'All'.obs;
  final List<String> filterOptions = [
    'All',
    'Pending',
    'Quoted',
    'Active',
    'Draft',
  ];

  // Sort state
  final RxString sortBy = 'Low to High'.obs;
  final List<String> sortOptions = [
    'Low to High',
    'High to Low',
    'Newest First',
    'Oldest First',
  ];

  // Loading state
  final RxBool isLoading = false.obs;

  // Posts data
  final RxList<MyPost> allSellPosts = <MyPost>[].obs;
  final RxList<MyPost> filteredSellPosts = <MyPost>[].obs;
  final RxList<MyPost> allBuyPosts = <MyPost>[].obs;
  final RxList<MyPost> filteredBuyPosts = <MyPost>[].obs;
  final RxList<MyPost> offeredPosts = <MyPost>[].obs;

  // Counts
  final RxInt totalSellPosts = 0.obs;
  final RxInt totalBuyPosts = 0.obs;
  final RxInt buyPostsBadgeCount = 0.obs; // Badge count for Buy Posts tab
  final RxInt quotedBadgeCount = 0.obs; // Badge count for Quoted filter

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  /// Change sub-tab (Sell Posts / Buy Posts / Offered Posts)
  void changeSubTab(int index) {
    subTabIndex.value = index;
    currentFilter.value = 'All';
    _applyFilter();
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

  /// Load all posts
  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock data for Sell Posts
      allSellPosts.value = [
        MyPost(
          id: '1',
          postId: '#POST-1042',
          title: '5 Katha Plot in Purbachal',
          price: '2,00,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          status: MyPostStatus.pending,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          timestamp: '2h ago',
          timestampPrefix: 'Submitted:',
        ),
        MyPost(
          id: '2',
          postId: '#POST-1042',
          title: 'Villa in Kurigram',
          price: '4,00,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          status: MyPostStatus.quoted,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/5 katha plot in purbachal.jpg',
          timestamp: '2h ago',
          timestampPrefix: 'Submitted:',
          quotesCount: 3,
        ),
        MyPost(
          id: '3',
          postId: '#POST-1042',
          title: 'Modern Duplex Villa',
          price: '40,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          status: MyPostStatus.active,
          isVerified: true,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          timestamp: '2h ago',
          timestampPrefix: 'Posted:',
        ),
        MyPost(
          id: '4',
          postId: '#POST-1043',
          title: 'Gazipur Water Zone',
          price: '95,12,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          status: MyPostStatus.draft,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/Gazipur Water Zone.jpg',
          timestamp: '2h ago',
          timestampPrefix: 'Edited:',
        ),
        MyPost(
          id: '5',
          postId: '#POST-1044',
          title: 'Luxury Apartment in Gulshan',
          price: '1,50,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.sellPost,
          status: MyPostStatus.pending,
          imageUrl:
              'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
          timestamp: '1d ago',
          timestampPrefix: 'Submitted:',
        ),
      ];

      // Mock data for Buy Posts
      allBuyPosts.value = [
        MyPost(
          id: '1',
          postId: '#BUY-1042',
          title: '3 Bed Ready Flat Needed',
          price: '30,00,000 - 40,00,000',
          propertyType: PropertyType.flat,
          postType: PostType.buyPost,
          status: MyPostStatus.active,
          timestamp: '2h ago',
          timestampPrefix: 'Posted:',
        ),
        MyPost(
          id: '2',
          postId: '#BUY-1043',
          title: 'Looking for Agro Land',
          price: '50,00,000 - 1,00,00,000',
          propertyType: PropertyType.plainLand,
          postType: PostType.buyPost,
          status: MyPostStatus.pending,
          timestamp: '1d ago',
          timestampPrefix: 'Submitted:',
        ),
      ];

      // Calculate counts
      totalSellPosts.value = allSellPosts.length;
      totalBuyPosts.value = allBuyPosts.length;
      buyPostsBadgeCount.value = allBuyPosts
          .where((p) => p.status == MyPostStatus.quoted)
          .length;
      quotedBadgeCount.value = allSellPosts
          .where((p) => p.status == MyPostStatus.quoted)
          .length;

      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load posts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply current filter
  void _applyFilter() {
    if (subTabIndex.value == 0) {
      // Sell Posts
      if (currentFilter.value == 'All') {
        filteredSellPosts.assignAll(allSellPosts);
      } else {
        final status = _getStatusFromFilter(currentFilter.value);
        filteredSellPosts.assignAll(
          allSellPosts.where((p) => p.status == status).toList(),
        );
      }
      _sortPosts();
    } else if (subTabIndex.value == 1) {
      // Buy Posts
      if (currentFilter.value == 'All') {
        filteredBuyPosts.assignAll(allBuyPosts);
      } else {
        final status = _getStatusFromFilter(currentFilter.value);
        filteredBuyPosts.assignAll(
          allBuyPosts.where((p) => p.status == status).toList(),
        );
      }
      _sortPosts();
    }
  }

  /// Get MyPostStatus from filter string
  MyPostStatus? _getStatusFromFilter(String filter) {
    switch (filter) {
      case 'Pending':
        return MyPostStatus.pending;
      case 'Quoted':
        return MyPostStatus.quoted;
      case 'Active':
        return MyPostStatus.active;
      case 'Draft':
        return MyPostStatus.draft;
      default:
        return null;
    }
  }

  /// Sort posts
  void _sortPosts() {
    int Function(MyPost, MyPost) comparator;

    switch (sortBy.value) {
      case 'Low to High':
        comparator = (a, b) =>
            _parsePrice(a.price).compareTo(_parsePrice(b.price));
        break;
      case 'High to Low':
        comparator = (a, b) =>
            _parsePrice(b.price).compareTo(_parsePrice(a.price));
        break;
      case 'Newest First':
        comparator = (a, b) => 0; // TODO: Sort by actual date
        break;
      case 'Oldest First':
        comparator = (a, b) => 0; // TODO: Sort by actual date
        break;
      default:
        comparator = (a, b) => 0;
    }

    if (subTabIndex.value == 0) {
      filteredSellPosts.sort(comparator);
    } else if (subTabIndex.value == 1) {
      filteredBuyPosts.sort(comparator);
    }
  }

  double _parsePrice(String price) {
    // Handle price range (for buy posts)
    final parts = price.split('-');
    final firstPart = parts.first.trim();
    return double.tryParse(
          firstPart.replaceAll(',', '').replaceAll('৳', '').trim(),
        ) ??
        0;
  }

  /// Get current posts list
  List<MyPost> get currentPosts {
    switch (subTabIndex.value) {
      case 0:
        return filteredSellPosts;
      case 1:
        return filteredBuyPosts;
      case 2:
        return offeredPosts;
      default:
        return filteredSellPosts;
    }
  }

  /// Get current total count
  int get currentTotalCount {
    switch (subTabIndex.value) {
      case 0:
        return filteredSellPosts.length;
      case 1:
        return filteredBuyPosts.length;
      case 2:
        return offeredPosts.length;
      default:
        return 0;
    }
  }

  /// Get badge count for a filter
  int getBadgeCount(String filter) {
    if (filter == 'Quoted') {
      return quotedBadgeCount.value;
    }
    return 0;
  }

  /// Refresh posts
  Future<void> refresh() async {
    await loadPosts();
  }

  /// Navigate to post details (uses nested navigation to keep bottom nav visible)
  void goToPostDetails(MyPost post) {
    if (post.postType == PostType.sellPost) {
      // Navigate to Sell Post Details with status
      NestedNavigationService.to(
        const SellPostDetailsView(),
        arguments: {
          'postId': post.id,
          'status': post.status.name, // pending, quoted, active, draft
        },
        binding: BindingsBuilder(() {
          Get.lazyPut<SellPostDetailsController>(
            () => SellPostDetailsController(),
          );
        }),
      );
    } else {
      // TODO: Navigate to Buy Post Details
      Get.snackbar(
        'Post Details',
        'Opening ${post.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to create new post
  void goToCreatePost() {
    if (subTabIndex.value == 0) {
      // Create Sell Post
      Get.snackbar(
        'Create',
        'Navigate to create sell post',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (subTabIndex.value == 1) {
      // Create Buy Post
      Get.snackbar(
        'Create',
        'Navigate to create buy post',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }
}
