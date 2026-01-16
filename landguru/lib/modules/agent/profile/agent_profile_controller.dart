import 'package:get/get.dart';

/// Service for Agent Profile screen
class AgentProfileController extends GetxService {
  // State
  final RxBool isLoading = false.obs;

  // Agent data
  final RxString agentName = ''.obs;
  final RxString agentId = ''.obs;
  final RxString agentType = ''.obs; // Lawyer, Surveyor, etc.
  final RxBool isVerified = false.obs;
  final RxString profileImage = ''.obs;

  // Stats
  final RxInt totalTasksCompleted = 0.obs;
  final RxDouble totalEarned = 0.0.obs;

  // Assigned location
  final RxString assignedLocation = ''.obs;

  // Services provided
  final RxList servicesProvided = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Load agent profile
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // TODO: Load profile from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to view full profile
  void goToProfileDetails() {
    // TODO: Navigate to detailed profile view
  }

  /// Logout
  Future<void> logout() async {
    // TODO: Implement logout
    // - Clear local storage
    // - Navigate to agent login
  }
}
