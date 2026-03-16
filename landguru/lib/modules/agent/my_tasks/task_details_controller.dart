import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:landguru/core/core.dart';
import '../../../core/enums/land_unit.dart';
import '../../../core/utils/land_unit_converter.dart';
import 'agent_task_actions_service.dart';
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

  final _taskActionsService = Get.find<AgentTaskActionsService>();
  final _uploadService = Get.find<UploadService>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is AgentTask) {
        task.value = Get.arguments as AgentTask;
        taskId.value = task.value!.id;
        loadTaskDetails();
      } else if (Get.arguments is Map) {
        final argumentMap = Map<String, dynamic>.from(Get.arguments as Map);
        final argumentTask = argumentMap['task'];
        if (argumentTask is AgentTask) {
          task.value = argumentTask;
          taskId.value = argumentTask.id;
        }
        taskId.value = (argumentMap['taskId'] ?? taskId.value).toString();
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
    final converted = LandUnitConverter.convert(
      value,
      LandUnit.katha,
      selectedLandUnit.value,
    );

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
    if (taskId.value.trim().isEmpty) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await ApiErrorHandler.call<AgentTask>(
        () => _taskActionsService.fetchTaskDetails(assignmentId: taskId.value),
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      task.value = result.data;
      await _refreshWorkLogOnly();
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
    if (task.value == null) return;

    isAccepting.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _taskActionsService.acceptTask(assignmentId: task.value!.id),
      );

      if (!result.isSuccess) {
        return;
      }

      await _refreshTaskAndWorkLog();

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
    if (task.value == null) return false;

    isSettingAppointment.value = true;
    try {
      final currentTask = task.value!;
      final date = selectedAppointmentDate.value!;
      final time = selectedAppointmentTime.value!;

      final dateText =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final timeText =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      final result = await ApiErrorHandler.call(() async {
        if (currentTask.appointment == null) {
          await _taskActionsService.createAppointment(
            assignmentId: currentTask.id,
            date: dateText,
            time: timeText,
            location: currentTask.location,
          );
          return;
        }

        final reason = appointmentTitleController.text.trim().isEmpty
            ? 'Rescheduled by agent'
            : appointmentTitleController.text.trim();

        await _taskActionsService.rescheduleAppointment(
          assignmentId: currentTask.id,
          newDate: dateText,
          newTime: timeText,
          reason: reason,
        );
      });

      if (!result.isSuccess) {
        return false;
      }

      await _refreshTaskAndWorkLog();

      resetAppointmentForm();
      return true;
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
    if (task.value == null) return;

    isPostingRemark.value = true;
    try {
      final remarkText = remarkController.text.trim();
      final fileUrls = <String>[];
      if (attachment?.url != null && attachment!.url!.trim().isNotEmpty) {
        fileUrls.add(attachment.url!.trim());
      }

      final result = await ApiErrorHandler.call(
        () => _taskActionsService.addWorkLog(
          assignmentId: task.value!.id,
          remark: remarkText.isEmpty ? null : remarkText,
          fileUrls: fileUrls,
        ),
      );

      if (!result.isSuccess) {
        return;
      }

      await _refreshWorkLogOnly();

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
    if (task.value == null) return;

    isPostingRemark.value = true;
    try {
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (pickResult == null || pickResult.files.isEmpty) {
        return;
      }

      final pickedFile = pickResult.files.single;
      final path = pickedFile.path;
      if (path == null || path.trim().isEmpty) {
        return;
      }

      final uploadedUrl = await ApiErrorHandler.call<String>(
        () => _uploadService.uploadFile(
          payload: UploadFilePayload(
            file: File(path),
            contentType: _guessContentType(path),
            type: 'DEED',
          ),
        ),
      );

      if (!uploadedUrl.isSuccess || uploadedUrl.data == null) {
        return;
      }

      final newDoc = TaskDocument(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: pickedFile.name,
        size: _formatFileSize(pickedFile.size),
        url: uploadedUrl.data,
        uploadedAt: DateTime.now(),
      );

      await postRemark(attachment: newDoc);
    } finally {
      isPostingRemark.value = false;
    }
  }

  /// Submit for review (for Active tasks)
  Future<bool> submitForReview() async {
    if (task.value == null) return false;

    isSubmitting.value = true;
    try {
      final result = await ApiErrorHandler.call(
        () => _taskActionsService.submitReview(
          assignmentId: task.value!.id,
          comment: remarkController.text.trim(),
        ),
      );

      if (!result.isSuccess) {
        return false;
      }

      await _refreshTaskAndWorkLog();

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

  Future<void> _refreshTaskAndWorkLog() async {
    if (task.value == null) return;

    final detailsResult = await ApiErrorHandler.call<AgentTask>(
      () => _taskActionsService.fetchTaskDetails(assignmentId: task.value!.id),
      showError: false,
    );

    if (detailsResult.isSuccess && detailsResult.data != null) {
      task.value = detailsResult.data;
    }

    await _refreshWorkLogOnly();
  }

  Future<void> _refreshWorkLogOnly() async {
    if (task.value == null) return;

    final workLogResult = await ApiErrorHandler.call<List<WorkLogEntry>>(
      () => _taskActionsService.fetchWorkLog(assignmentId: task.value!.id),
      showError: false,
    );

    if (!workLogResult.isSuccess || workLogResult.data == null) {
      return;
    }

    task.value = task.value!.copyWith(workLog: workLogResult.data!);
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int index = 0;
    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }
    final fixed = size >= 10
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(1);
    return '$fixed ${units[index]}';
  }

  @override
  void onClose() {
    remarkController.dispose();
    appointmentTitleController.dispose();
    super.onClose();
  }
}
