import 'package:get/get.dart';

/// Service for Agent Task Details screen
/// Handles different task states: New, Active, In Review, Done
class AgentTaskDetailsController extends GetxService {
  // State
  final RxBool isLoading = false.obs;
  final RxString taskId = ''.obs;
  final RxString taskStatus = ''.obs; // new, active, in_review, done

  // Task data
  final RxString serviceName = ''.obs;
  final RxDouble serviceFee = 0.0.obs;

  // Work log
  final RxList workLog = [].obs;

  // Appointment
  final RxBool hasAppointment = false.obs;
  final Rxn<DateTime> appointmentDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      taskId.value = Get.arguments['taskId'] ?? '';
      taskStatus.value = Get.arguments['status'] ?? 'new';
    }
    loadTaskDetails();
  }

  /// Load task details
  Future<void> loadTaskDetails() async {
    isLoading.value = true;
    try {
      // TODO: Load task details from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept task (for New tasks)
  Future<void> acceptTask() async {
    isLoading.value = true;
    try {
      // TODO: Implement accept task API call
      await Future.delayed(const Duration(seconds: 1));

      // Update status to active
      taskStatus.value = 'active';
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Set appointment date/time
  Future<void> setAppointment(DateTime dateTime) async {
    isLoading.value = true;
    try {
      // TODO: Implement set appointment API call
      await Future.delayed(const Duration(seconds: 1));

      appointmentDate.value = dateTime;
      hasAppointment.value = true;
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }

  /// Add work log entry
  Future<void> addWorkLogEntry(String text, {String? attachment}) async {
    // TODO: Implement add work log
  }

  /// Upload verified document
  Future<void> uploadDocument() async {
    // TODO: Implement document upload
  }

  /// Submit for review (for Active tasks)
  Future<void> submitForReview() async {
    isLoading.value = true;
    try {
      // TODO: Implement submit for review API call
      await Future.delayed(const Duration(seconds: 1));

      // Update status
      taskStatus.value = 'in_review';
    } catch (e) {
      // TODO: Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
