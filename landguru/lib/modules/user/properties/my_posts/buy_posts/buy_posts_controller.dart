import 'package:get/get.dart';

import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../routes/app_routes.dart';
import 'buy_post_offer_details_view.dart';
import 'models/buy_post_models.dart';
import 'services/my_buy_posts_service.dart';

class BuyPostsController extends GetxController {
  static const int _pageLimit = 10;
  static List<BuyPost> _cachedAllBuyPosts = <BuyPost>[];
  static int _cachedCurrentPage = 1;
  static int _cachedTotal = 0;
  static bool _cachedHasMore = true;
  static String _cachedCurrentFilter = 'All';
  static String _cachedSortBy = 'Newest First';
  static int _cachedOffersCount = 0;
  static bool _hasCachedData = false;

  final MyBuyPostsService _service = Get.find<MyBuyPostsService>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxString currentFilter = 'All'.obs;
  final List<String> filterOptions = ['All', 'Offers', 'Active', 'In Review'];

  final RxString sortBy = 'Newest First'.obs;
  final List<String> sortOptions = [
    'Newest First',
    'Oldest First',
    'Most Offers',
    'Least Offers',
  ];

  final RxList<BuyPost> allBuyPosts = <BuyPost>[].obs;
  final RxList<BuyPost> filteredBuyPosts = <BuyPost>[].obs;

  final RxInt offersCount = 0.obs;
  int _currentPage = 1;
  int _apiTotal = 0;

  @override
  void onInit() {
    super.onInit();
    loadBuyPosts();
  }

  Future<void> loadBuyPosts({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    _currentPage = 1;
    hasMore.value = true;
    try {
      final response = await _service.getMyBuyPosts(
        page: _currentPage,
        limit: _pageLimit,
      );
      allBuyPosts.assignAll(response.posts);
      _apiTotal = response.total;
      hasMore.value = allBuyPosts.length < _apiTotal;
      offersCount.value = allBuyPosts.fold(
        0,
        (sum, post) => sum + post.offersCount,
      );
      _applyFilter();
      _syncCache();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load buy posts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreIfNeeded() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final nextPage = _currentPage + 1;
      final response = await _service.getMyBuyPosts(
        page: nextPage,
        limit: _pageLimit,
      );

      final existingIds = allBuyPosts.map((post) => post.id).toSet();
      final newPosts = response.posts
          .where((post) => !existingIds.contains(post.id))
          .toList();

      allBuyPosts.addAll(newPosts);
      _currentPage = nextPage;
      _apiTotal = response.total;
      hasMore.value = allBuyPosts.length < _apiTotal;

      offersCount.value = allBuyPosts.fold(
        0,
        (sum, post) => sum + post.offersCount,
      );
      _applyFilter();
      _syncCache();
    } catch (_) {
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void changeFilter(String filter) {
    currentFilter.value = filter;
    _applyFilter();
  }

  void changeSortBy(String sort) {
    sortBy.value = sort;
    _sortPosts();
  }

  void _applyFilter() {
    switch (currentFilter.value) {
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
      case 'All':
      default:
        filteredBuyPosts.assignAll(allBuyPosts);
        break;
    }
    _sortPosts();
  }

  void _sortPosts() {
    switch (sortBy.value) {
      case 'Most Offers':
        filteredBuyPosts.sort((a, b) => b.offersCount.compareTo(a.offersCount));
        break;
      case 'Least Offers':
        filteredBuyPosts.sort((a, b) => a.offersCount.compareTo(b.offersCount));
        break;
      case 'Oldest First':
      case 'Newest First':
      default:
        break;
    }
  }

  int getBadgeCount(String filter) {
    if (filter == 'Offers') {
      return allBuyPosts.where((p) => p.hasOffers).length;
    }
    return 0;
  }

  Future<void> refresh() async {
    await loadBuyPosts(forceRefresh: true);
  }

  void _restoreFromCache() {
    currentFilter.value = _cachedCurrentFilter;
    sortBy.value = _cachedSortBy;
    offersCount.value = _cachedOffersCount;
    allBuyPosts.assignAll(_cachedAllBuyPosts);
    _currentPage = _cachedCurrentPage;
    _apiTotal = _cachedTotal;
    hasMore.value = _cachedHasMore;
    _applyFilter();
  }

  void _syncCache() {
    _cachedAllBuyPosts = List<BuyPost>.from(allBuyPosts);
    _cachedCurrentPage = _currentPage;
    _cachedTotal = _apiTotal;
    _cachedHasMore = hasMore.value;
    _cachedCurrentFilter = currentFilter.value;
    _cachedSortBy = sortBy.value;
    _cachedOffersCount = offersCount.value;
    _hasCachedData = true;
  }

  void showOffersPopup(BuyPost post) {}

  void goToOfferDetails(BuyPost buyPost, OfferReceived offer) {
    NestedNavigationService.to(
      const BuyPostOfferDetailsView(),
      arguments: {'buyPost': buyPost, 'offer': offer},
    );
  }

  void onPostTap(BuyPost post) {
    if (post.status == BuyPostStatus.draft) {
      final lastCompletedStep = post.lastCompletedStep ?? 1;
      final resumeStep = (lastCompletedStep + 1).clamp(1, 2);

      Get.toNamed(
        AppRoutes.CREATE_BUY_POST_INFO,
        arguments: {
          'draftPostId': post.id,
          'lastCompletedStep': lastCompletedStep,
          'resumeStep': resumeStep,
        },
      );
    }
  }

  Future<bool> acceptOffer(BuyPost buyPost, OfferReceived offer) async {
    final offerId = offer.id.trim();
    if (offerId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid offer ID',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      await _service.acceptOffer(offerId: offerId);
      await loadBuyPosts(forceRefresh: true);
      return true;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to accept offer. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void viewAppointment(BuyPost post) {
    Get.snackbar(
      'Appointment',
      'View appointment for ${post.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
