import 'package:get/get.dart';

/// Service for Agent My Tasks screen
/// Handles: New, Active, In Review, Done tabs
class AgentMyTasksController extends GetxService {
  // Tab state
  final RxInt selectedTabIndex = 0.obs; // 0: New, 1: Active, 2: In Review, 3: Done

  // Filter
  final RxString searchQuery = ''.obs;
  final RxString serviceTypeFilter = 'All'.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Lists
  final RxList newTasks = [].obs;
  final RxList activeTasks = [].obs;
  final RxList inReviewTasks = [].obs;
  final RxList doneTasks = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
    loadTasks();
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
    loadTasks();
  }

  /// Update service type filter
  void updateServiceTypeFilter(String type) {
    serviceTypeFilter.value = type;
    loadTasks();
  }

  /// Load tasks based on current tab
  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      // TODO: Load tasks from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to task details
  void goToTaskDetails(String taskId, String status) {
    // TODO: Navigate to task details with appropriate status
  }

  /// Refresh tasks
  Future<void> refresh() async {
    await loadTasks();
  }
}
