import 'package:get/get.dart';

/// Service for Agent Appointments screen
/// Handles: Upcoming, Past tabs
class AgentAppointmentsController extends GetxService {
  // Tab state
  final RxInt selectedTabIndex = 0.obs; // 0: Upcoming, 1: Past

  // Sort
  final RxString sortBy = 'Date'.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Lists
  final RxList upcomingAppointments = [].obs;
  final RxList pastAppointments = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  /// Change tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
    loadAppointments();
  }

  /// Update sort
  void updateSort(String sort) {
    sortBy.value = sort;
    loadAppointments();
  }

  /// Load appointments based on current tab
  Future<void> loadAppointments() async {
    isLoading.value = true;
    try {
      // TODO: Load appointments from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// View appointment/task details
  void goToAppointmentDetails(String appointmentId) {
    // TODO: Navigate to task details
  }

  /// Refresh appointments
  Future<void> refresh() async {
    await loadAppointments();
  }
}
