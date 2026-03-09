import 'package:get/get.dart';

import '../../../../core/enums/post_type.dart';
import '../../../../core/services/nested_navigation_service.dart';
import '../../../../core/services/services.dart';
import 'models/my_post.dart';
import 'models/my_post_status.dart';
import 'models/my_sell_posts_api_models.dart';
import 'sell_posts/sell_post_details_controller.dart';
import 'sell_posts/sell_post_details_view.dart';
import 'services/my_sell_posts_service.dart';
import '../properties_controller.dart';
import 'package:landguru/routes/app_routes.dart';
export 'models/my_post.dart';
export 'models/my_post_status.dart';

/// Controller for My Posts section
/// Handles: Sell Posts, Buy Posts, Offered Posts tabs
class MyPostsController extends GetxController {
  static const int _sellPostsLimit = 10;
  static List<MyPost> _cachedSellPosts = <MyPost>[];
  static int _cachedSellPostsTotal = 0;
  static int _cachedSellPostsCurrentPage = 1;
  static bool _cachedSellPostsHasMore = true;
  static int _cachedQuotedBadgeCount = 0;
  static bool _hasCachedSellPosts = false;
  static bool _hasCachedQuotedBadgeCount = false;

  final MySellPostsService _mySellPostsService = Get.find<MySellPostsService>();
  final SellPostDetailsService _sellPostDetailsService =
      Get.find<SellPostDetailsService>();
  final PropertiesController _propertiesController =
      Get.find<PropertiesController>();
  Worker? _globalFilterWorker;

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
  final RxBool isLoadingMoreSellPosts = false.obs;
  final RxBool hasMoreSellPosts = true.obs;

  // Posts data
  final RxList<MyPost> allSellPosts = <MyPost>[].obs;
  final RxList<MyPost> filteredSellPosts = <MyPost>[].obs;
  final RxList<MyPost> allBuyPosts = <MyPost>[].obs;
  final RxList<MyPost> filteredBuyPosts = <MyPost>[].obs;
  final RxList<MyPost> offeredPosts = <MyPost>[].obs;

  // Counts
  final RxInt totalSellPosts = 0.obs;
  final RxInt totalBuyPosts = 0.obs;
  final RxInt buyPostsBadgeCount = 0.obs;
  final RxInt quotedBadgeCount = 0.obs;
  int _sellPostsCurrentPage = 1;

  @override
  void onInit() {
    super.onInit();
    _globalFilterWorker = ever<int>(
      _propertiesController.filterApplyVersion,
      (_) => _applyFilter(),
    );
    loadPosts();
  }

  @override
  void onClose() {
    _globalFilterWorker?.dispose();
    super.onClose();
  }

  /// Change sub-tab (Sell Posts / Buy Posts / Offered Posts)
  void changeSubTab(int index) {
    subTabIndex.value = index;
    currentFilter.value = 'All';

    if (index == 0) {
      if (allSellPosts.isEmpty) {
        _loadSellPosts();
      } else {
        _applyFilter();
      }

      if (!_hasCachedQuotedBadgeCount) {
        _refreshQuotedBadgeCount();
      }
      return;
    }

    _applyFilter();
  }

  /// Change filter
  void changeFilter(String filter) {
    currentFilter.value = filter;
    if (subTabIndex.value == 0) {
      _loadSellPosts();
      return;
    }
    _applyFilter();
  }

  /// Change sort
  void changeSortBy(String sort) {
    sortBy.value = sort;
    _sortPosts();
  }

  /// Load all posts
  Future<void> loadPosts({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      if (!forceRefresh && _hasCachedSellPosts) {
        _restoreSellPostsCache();
      } else {
        await _loadSellPosts(showError: true);
        await _refreshQuotedBadgeCount();
      }
      buyPostsBadgeCount.value = 0;
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
    final criteria = _propertiesController.currentFilterCriteria;

    if (subTabIndex.value == 0) {
      final filtered = allSellPosts.where((post) {
        return criteria.matches(
          propertyType: post.propertyType,
          price: post.price,
        );
      }).toList();

      filteredSellPosts.assignAll(filtered);
      _sortPosts();
    } else if (subTabIndex.value == 1) {
      List<MyPost> statusFiltered;
      if (currentFilter.value == 'All') {
        statusFiltered = allBuyPosts.toList();
      } else {
        final status = _getStatusFromFilter(currentFilter.value);
        statusFiltered = allBuyPosts.where((p) => p.status == status).toList();
      }

      final globallyFiltered = statusFiltered.where((post) {
        return criteria.matches(
          propertyType: post.propertyType,
          price: post.price,
        );
      }).toList();

      filteredBuyPosts.assignAll(globallyFiltered);
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
        comparator = (a, b) => 0;
        break;
      case 'Oldest First':
        comparator = (a, b) => 0;
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
        return totalSellPosts.value;
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
    if (subTabIndex.value == 0) {
      await _loadSellPosts(showError: false, forceRefresh: true);
      await _refreshQuotedBadgeCount(forceRefresh: true);
      return;
    }
    await loadPosts(forceRefresh: true);
  }

  Future<void> _loadSellPosts({
    bool showError = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _hasCachedSellPosts && currentFilter.value == 'All') {
      _restoreSellPostsCache();
      return;
    }

    final tab = MySellPostTabValues.fromFilter(currentFilter.value);
    _sellPostsCurrentPage = 1;
    hasMoreSellPosts.value = true;
    final result = await ApiErrorHandler.call(
      () => _mySellPostsService.getMySellPosts(
        page: _sellPostsCurrentPage,
        limit: _sellPostsLimit,
        tab: tab,
      ),
      showError: showError,
    );

    if (!result.isSuccess || result.data == null) {
      return;
    }

    allSellPosts.assignAll(result.data!.posts);
    filteredSellPosts.assignAll(result.data!.posts);
    totalSellPosts.value = result.data!.total;
    hasMoreSellPosts.value = allSellPosts.length < totalSellPosts.value;
    if (currentFilter.value == 'All') {
      _syncSellPostsCache();
    }
    _sortPosts();
  }

  Future<void> loadMoreSellPostsIfNeeded() async {
    if (subTabIndex.value != 0 ||
        isLoading.value ||
        isLoadingMoreSellPosts.value ||
        !hasMoreSellPosts.value) {
      return;
    }

    final tab = MySellPostTabValues.fromFilter(currentFilter.value);
    isLoadingMoreSellPosts.value = true;
    try {
      final nextPage = _sellPostsCurrentPage + 1;
      final result = await ApiErrorHandler.call(
        () => _mySellPostsService.getMySellPosts(
          page: nextPage,
          limit: _sellPostsLimit,
          tab: tab,
        ),
        showError: false,
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final existingIds = allSellPosts.map((post) => post.id).toSet();
      final newPosts = result.data!.posts
          .where((post) => !existingIds.contains(post.id))
          .toList();
      allSellPosts.addAll(newPosts);
      filteredSellPosts.assignAll(allSellPosts);
      totalSellPosts.value = result.data!.total;
      _sellPostsCurrentPage = nextPage;
      hasMoreSellPosts.value = allSellPosts.length < totalSellPosts.value;

      if (currentFilter.value == 'All') {
        _syncSellPostsCache();
      }
      _sortPosts();
    } finally {
      isLoadingMoreSellPosts.value = false;
    }
  }

  Future<void> _refreshQuotedBadgeCount({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedQuotedBadgeCount) {
      quotedBadgeCount.value = _cachedQuotedBadgeCount;
      return;
    }

    final result = await ApiErrorHandler.call(
      () => _mySellPostsService.getMySellPosts(
        page: 1,
        limit: 1,
        tab: MySellPostTabValues.quoted,
      ),
      showError: false,
    );

    if (!result.isSuccess || result.data == null) {
      return;
    }

    quotedBadgeCount.value = result.data!.total;
    _cachedQuotedBadgeCount = result.data!.total;
    _hasCachedQuotedBadgeCount = true;
  }

  void _restoreSellPostsCache() {
    allSellPosts.assignAll(_cachedSellPosts);
    filteredSellPosts.assignAll(_cachedSellPosts);
    totalSellPosts.value = _cachedSellPostsTotal;
    _sellPostsCurrentPage = _cachedSellPostsCurrentPage;
    hasMoreSellPosts.value = _cachedSellPostsHasMore;
    quotedBadgeCount.value = _cachedQuotedBadgeCount;
    _sortPosts();
  }

  void _syncSellPostsCache() {
    _cachedSellPosts = List<MyPost>.from(allSellPosts);
    _cachedSellPostsTotal = totalSellPosts.value;
    _cachedSellPostsCurrentPage = _sellPostsCurrentPage;
    _cachedSellPostsHasMore = hasMoreSellPosts.value;
    _hasCachedSellPosts = true;
  }

  /// Navigate to post details (uses nested navigation to keep bottom nav visible)
  Future<void> goToPostDetails(MyPost post) async {
    if (post.postType == PostType.sellPost) {
      final detailsResult = await ApiErrorHandler.call(
        () => _sellPostDetailsService.getSellPostById(post.id),
        showError: true,
      );

      if (!detailsResult.isSuccess || detailsResult.data == null) {
        return;
      }

      NestedNavigationService.to(
        const SellPostDetailsView(),
        arguments: {'postId': post.id, 'status': post.status.name},
        binding: BindingsBuilder(() {
          Get.lazyPut<SellPostDetailsController>(
            () => SellPostDetailsController(),
          );
        }),
      );
    } else {
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
      Get.toNamed(AppRoutes.CREATE_SELL_POST_INFO);
      // Get.snackbar(
      //   'Create',
      //   'Navigate to create sell post',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } else if (subTabIndex.value == 1) {
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
