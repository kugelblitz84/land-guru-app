import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/land_unit.dart';
import '../../../core/utils/land_unit_converter.dart';
import 'models/task_models.dart';

/// Controller for Agent Task Details screen
/// Handles different task states: New, Active, In Review, Done
class AgentTaskDetailsController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxBool isAccepting = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isSettingAppointment = false.obs;
  final RxString taskId = ''.obs;

  // Task data
  final Rxn<AgentTask> task = Rxn<AgentTask>();

  // Land unit conversion - uses same unit for both sellable land and plot size
  final Rx<LandUnit> selectedLandUnit = LandUnit.katha.obs;

  // Remark input
  final remarkController = TextEditingController();
  final RxBool isPostingRemark = false.obs;

  // Appointment form controllers
  final appointmentTitleController = TextEditingController(text: 'Site Visit');
  final Rxn<DateTime> selectedAppointmentDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedAppointmentTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is AgentTask) {
        task.value = Get.arguments as AgentTask;
        taskId.value = task.value!.id;
      } else if (Get.arguments is Map) {
        taskId.value = Get.arguments['taskId'] ?? '';
        loadTaskDetails();
      }
    }
  }

  /// Get current task status
  TaskStatus get taskStatus => task.value?.status ?? TaskStatus.newRequest;

  /// Get current processing status
  TaskProcessingStatus get processingStatus =>
      task.value?.processingStatus ?? TaskProcessingStatus.accepted;

  /// Check if task is new
  bool get isNewTask => taskStatus == TaskStatus.newRequest;

  /// Check if task is active
  bool get isActiveTask => taskStatus == TaskStatus.active;

  /// Check if task is in review
  bool get isInReviewTask => taskStatus == TaskStatus.inReview;

  /// Check if task is done
  bool get isDoneTask => taskStatus == TaskStatus.done;

  /// Check if appointment is scheduled
  bool get hasAppointment => task.value?.appointment != null;

  /// Check if should show bottom button
  bool get shouldShowBottomButton => isNewTask || isActiveTask;

  /// Get appointment status
  AppointmentStatus get appointmentStatus =>
      task.value?.appointment?.status ?? AppointmentStatus.notScheduled;

  /// Get time ago string for assigned time
  String get assignedTimeAgo {
    if (task.value == null) return '';
    final now = DateTime.now();
    final difference = now.difference(task.value!.assignedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get all unit conversions for a given land amount value (in original unit, default Katha)
  Map<LandUnit, double> getAllConversions(double value) {
    // Assuming the original value is in Katha
    return LandUnitConverter.getAllConversions(value, LandUnit.katha);
  }

  /// Get converted land amount with unit label
  String getConvertedLandAmount(double value) {
    if (value == 0) return 'Not specified';

    // Convert from Katha (assumed source unit) to selected unit
    final sqft = LandUnitConverter.toSqft(value, LandUnit.katha);
    final converted = LandUnitConverter.fromSqft(sqft, selectedLandUnit.value);

    String formattedNumber;
    if (converted >= 1) {
      formattedNumber = converted.toStringAsFixed(
        converted.truncateToDouble() == converted ? 0 : 2,
      );
    } else {
      formattedNumber = converted.toStringAsFixed(4);
    }

    return '$formattedNumber ${selectedLandUnit.value.label}';
  }

  /// Load task details from API
  Future<void> loadTaskDetails() async {
    isLoading.value = true;
    try {
      // TODO: Load task details from API using taskId
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept task (for New tasks)
  Future<void> acceptTask() async {
    isAccepting.value = true;
    try {
      // TODO: Implement accept task API call
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      Get.snackbar(
        'Task Accepted',
        'You have accepted this task successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back to task list
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept task',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAccepting.value = false;
    }
  }

  /// Reset appointment form
  void resetAppointmentForm() {
    appointmentTitleController.text = 'Site Visit';
    selectedAppointmentDate.value = null;
    selectedAppointmentTime.value = null;
  }

  /// Pick appointment date
  Future<void> pickAppointmentDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          selectedAppointmentDate.value ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3366FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedAppointmentDate.value = pickedDate;
    }
  }

  /// Pick appointment time
  Future<void> pickAppointmentTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          selectedAppointmentTime.value ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3366FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      selectedAppointmentTime.value = pickedTime;
    }
  }

  /// Get formatted appointment date
  String get formattedAppointmentDate {
    if (selectedAppointmentDate.value == null) return '';
    final date = selectedAppointmentDate.value!;
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;
    return '$day $month $year';
  }

  /// Get formatted appointment time
  String get formattedAppointmentTime {
    if (selectedAppointmentTime.value == null) return '';
    final time = selectedAppointmentTime.value!;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Check if appointment form is valid
  bool get isAppointmentFormValid =>
      appointmentTitleController.text.isNotEmpty &&
      selectedAppointmentDate.value != null &&
      selectedAppointmentTime.value != null;

  /// Set appointment date/time
  Future<bool> setAppointment() async {
    if (!isAppointmentFormValid) return false;

    isSettingAppointment.value = true;
    try {
      final date = selectedAppointmentDate.value!;
      final time = selectedAppointmentTime.value!;
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // TODO: Implement set appointment API call
      await Future.delayed(const Duration(seconds: 1));

      // Update local task with new appointment
      if (task.value != null) {
        final newAppointment = TaskAppointment(
          id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
          type: appointmentTitleController.text,
          dateTime: dateTime,
          status: AppointmentStatus.upcoming,
        );

        // Add work log entry for scheduling appointment
        final newWorkLog = [
          WorkLogEntry(
            id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
            description:
                'Site Visit Scheduled for ${_formatDateTimeFull(dateTime)}',
            timestamp: DateTime.now(),
            type: WorkLogEntryType.appointmentScheduled,
          ),
          ...task.value!.workLog,
        ];

        task.value = task.value!.copyWith(
          appointment: newAppointment,
          workLog: newWorkLog,
        );
      }

      resetAppointmentForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set appointment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSettingAppointment.value = false;
    }
  }

  /// Reschedule appointment
  void rescheduleAppointment() {
    if (task.value?.appointment != null) {
      final apt = task.value!.appointment!;
      appointmentTitleController.text = apt.type;
      selectedAppointmentDate.value = apt.dateTime;
      selectedAppointmentTime.value = TimeOfDay.fromDateTime(apt.dateTime);
    }
  }

  String _formatDateTimeFull(DateTime dateTime) {
    final day = dateTime.day;
    final month = _getMonthName(dateTime.month);
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hour:$minute$period';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Add work log entry / post remark
  Future<void> postRemark({TaskDocument? attachment}) async {
    if (remarkController.text.trim().isEmpty && attachment == null) return;

    isPostingRemark.value = true;
    try {
      // TODO: Implement add work log API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Add to local work log
      if (task.value != null) {
        final newEntry = WorkLogEntry(
          id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
          description: attachment != null
              ? 'Uploaded new verified document'
              : remarkController.text.trim(),
          timestamp: DateTime.now(),
          attachment: attachment,
          type: attachment != null
              ? WorkLogEntryType.documentUpload
              : WorkLogEntryType.remark,
        );

        task.value = task.value!.copyWith(
          workLog: [newEntry, ...task.value!.workLog],
        );
      }

      remarkController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to post update',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPostingRemark.value = false;
    }
  }

  /// Upload verified document
  Future<void> uploadDocument() async {
    // TODO: Implement document picker and upload
    // For now, simulate document upload
    isPostingRemark.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newDoc = TaskDocument(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name:
            'Verified document ${task.value?.workLog.where((e) => e.type == WorkLogEntryType.documentUpload).length ?? 0 + 1}.pdf',
        size: '1.5MB',
        uploadedAt: DateTime.now(),
      );

      await postRemark(attachment: newDoc);
    } finally {
      isPostingRemark.value = false;
    }
  }

  /// Submit for review (for Active tasks)
  Future<bool> submitForReview() async {
    isSubmitting.value = true;
    try {
      // TODO: Implement submit for review API call
      await Future.delayed(const Duration(seconds: 1));

      // Update local task status
      if (task.value != null) {
        final submitEntry = WorkLogEntry(
          id: 'wl_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Submitted for review',
          timestamp: DateTime.now(),
          type: WorkLogEntryType.submitted,
        );

        task.value = task.value!.copyWith(
          status: TaskStatus.inReview,
          processingStatus: TaskProcessingStatus.inReview,
          workLog: [submitEntry, ...task.value!.workLog],
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit for review',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Go back
  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    remarkController.dispose();
    appointmentTitleController.dispose();
    super.onClose();
  }
}
