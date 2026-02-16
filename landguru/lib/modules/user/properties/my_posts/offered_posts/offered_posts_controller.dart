import 'package:get/get.dart';

import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../routes/app_routes.dart';
import 'models/offered_post_models.dart';
import 'offered_post_details_view.dart';
import 'services/my_offered_posts_service.dart';

class OfferedPostsController extends GetxController {
  static const int _pageLimit = 10;
  static List<OfferedPost> _cachedOfferedPosts = <OfferedPost>[];
  static int _cachedCurrentPage = 1;
  static int _cachedTotal = 0;
  static bool _cachedHasMore = true;
  static String _cachedCurrentFilter = 'All';
  static bool _hasCachedData = false;

  final MyOfferedPostsService _service = Get.find<MyOfferedPostsService>();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final filterOptions = ['All', 'Buyer Accepted', 'Pending Buyer Review'];
  final currentFilter = 'All'.obs;

  final offeredPosts = <OfferedPost>[].obs;
  int _currentPage = 1;
  int _apiTotal = 0;

  @override
  void onInit() {
    super.onInit();
    loadOfferedPosts();
  }

  Future<void> loadOfferedPosts({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasCachedData) {
      _restoreFromCache();
      return;
    }

    isLoading.value = true;
    _currentPage = 1;
    hasMore.value = true;
    try {
      final response = await _service.getMyOfferedPosts(
        page: _currentPage,
        limit: _pageLimit,
      );
      offeredPosts.assignAll(response.posts);
      _apiTotal = response.total;
      hasMore.value = offeredPosts.length < _apiTotal;
      _syncCache();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load offered posts',
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
      final response = await _service.getMyOfferedPosts(
        page: nextPage,
        limit: _pageLimit,
      );

      final existingIds = offeredPosts.map((post) => post.id).toSet();
      final newItems = response.posts
          .where((item) => !existingIds.contains(item.id))
          .toList();
      offeredPosts.addAll(newItems);

      _currentPage = nextPage;
      _apiTotal = response.total;
      hasMore.value = offeredPosts.length < _apiTotal;
      _syncCache();
    } catch (_) {
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

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
      case 'All':
      default:
        filtered = offeredPosts.toList();
    }

    filtered.sort((a, b) => b.offeredAt.compareTo(a.offeredAt));
    return filtered;
  }

  void changeFilter(String filter) {
    currentFilter.value = filter;
  }

  Future<void> refresh() async {
    await loadOfferedPosts(forceRefresh: true);
  }

  void _restoreFromCache() {
    currentFilter.value = _cachedCurrentFilter;
    offeredPosts.assignAll(_cachedOfferedPosts);
    _currentPage = _cachedCurrentPage;
    _apiTotal = _cachedTotal;
    hasMore.value = _cachedHasMore;
  }

  void _syncCache() {
    _cachedOfferedPosts = List<OfferedPost>.from(offeredPosts);
    _cachedCurrentPage = _currentPage;
    _cachedTotal = _apiTotal;
    _cachedHasMore = hasMore.value;
    _cachedCurrentFilter = currentFilter.value;
    _hasCachedData = true;
  }

  void goToOfferDetails(OfferedPost post) {
    NestedNavigationService.to(
      const OfferedPostDetailsView(),
      arguments: {'offeredPost': post},
    );
  }

  void completePost(OfferedPost post) {
    Get.snackbar(
      'Complete Post',
      'Navigating to complete post flow...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void makeSellPost(OfferedPost post) {
    Get.toNamed(
      AppRoutes.CREATE_SELL_POST_INFO,
      arguments: {'fromOfferedPost': true, 'offeredPost': post},
    );
  }
}
