import 'package:get/get.dart';

/// Service for the Agent Dashboard/Home screen
class AgentDashboardController extends GetxService {
  // State
  final RxBool isLoading = false.obs;
  final RxString agentName = ''.obs;
  final RxString assignedLocation = ''.obs;

  // Stats
  final RxInt newRequestsCount = 0.obs;
  final RxInt activeJobsCount = 0.obs;
  final RxInt doneThisMonthCount = 0.obs;

  // Requires scheduling list
  final RxList requiresScheduling = [].obs;

  // Today's schedule
  final RxList todaySchedule = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // TODO: Load agent dashboard data from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to notifications
  void goToNotifications() {
    // TODO: Navigate to notifications
  }

  /// View task details from requires scheduling
  void goToTaskDetails(String taskId) {
    // TODO: Navigate to task details
  }

  /// View all requires scheduling
  void viewAllRequiresScheduling() {
    // TODO: Navigate to my tasks with filter
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
