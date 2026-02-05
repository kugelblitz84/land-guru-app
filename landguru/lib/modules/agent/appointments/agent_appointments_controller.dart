import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/theme/app_colors.dart';

/// Tab enum for Agent Appointments
enum AgentAppointmentTab { upcoming, past }

/// Status enum for agent appointments
enum AgentAppointmentStatus { visitToday, upcomingVisit, visited }

extension AgentAppointmentStatusExtension on AgentAppointmentStatus {
  String get label {
    switch (this) {
      case AgentAppointmentStatus.visitToday:
        return 'Visit Today';
      case AgentAppointmentStatus.upcomingVisit:
        return 'Upcoming Visit';
      case AgentAppointmentStatus.visited:
        return 'Visited';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AgentAppointmentStatus.visitToday:
        return AppColors.success;
      case AgentAppointmentStatus.upcomingVisit:
        return AppColors.primary;
      case AgentAppointmentStatus.visited:
        return AppColors.grey400;
    }
  }

  Color get textColor => AppColors.white;
}

/// Agent Appointment model
class AgentAppointment {
  final String id;
  final String postId;
  final String propertyTitle;
  final PropertyType propertyType;
  final String location;
  final AgentAppointmentStatus status;
  final DateTime appointmentDate;
  final String serviceType;

  AgentAppointment({
    required this.id,
    required this.postId,
    required this.propertyTitle,
    required this.propertyType,
    required this.location,
    required this.status,
    required this.appointmentDate,
    required this.serviceType,
  });

  /// Get property type label
  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  /// Get property type color
  Color get propertyTypeColor {
    switch (propertyType) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32);
      case PropertyType.waterLand:
        return const Color(0xFF0288D1);
      case PropertyType.flat:
        return AppColors.primary;
    }
  }

  /// Format date as month abbreviation
  String get formattedMonth {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[appointmentDate.month - 1];
  }

  /// Format date as day number
  String get formattedDay => appointmentDate.day.toString();

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }
}

/// Controller for Agent Appointments screen
class AgentAppointmentsController extends GetxController {
  // Tab state
  final Rx<AgentAppointmentTab> selectedTab = AgentAppointmentTab.upcoming.obs;

  // Sort
  final RxString sortBy = 'Date'.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // All appointments
  final RxList<AgentAppointment> allAppointments = <AgentAppointment>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  /// Load mock appointment data
  void _loadMockData() {
    final now = DateTime.now();

    allAppointments.value = [
      // Upcoming appointments
      AgentAppointment(
        id: '1',
        postId: '#SERV892-POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AgentAppointmentStatus.visitToday,
        appointmentDate: now,
        serviceType: 'Ownership History Validation',
      ),
      AgentAppointment(
        id: '2',
        postId: '#SERV892-POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AgentAppointmentStatus.upcomingVisit,
        appointmentDate: now.add(const Duration(days: 1)),
        serviceType: 'Ownership History Validation',
      ),

      // Past appointments
      AgentAppointment(
        id: '3',
        postId: '#SERV892-POST-1042',
        propertyTitle: 'Villa in Kurigram',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AgentAppointmentStatus.visited,
        appointmentDate: now.subtract(const Duration(days: 5)),
        serviceType: 'Ownership History Validation',
      ),
      AgentAppointment(
        id: '4',
        postId: '#SERV892-POST-1042',
        propertyTitle: 'Modern Duplex Villa',
        propertyType: PropertyType.flat,
        location:
            'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
        status: AgentAppointmentStatus.visited,
        appointmentDate: now.subtract(const Duration(days: 10)),
        serviceType: 'Ownership History Validation',
      ),
    ];
  }

  /// Get filtered appointments based on selected tab
  List<AgentAppointment> get filteredAppointments {
    final now = DateTime.now();

    if (selectedTab.value == AgentAppointmentTab.upcoming) {
      return allAppointments
          .where(
            (a) =>
                a.status == AgentAppointmentStatus.visitToday ||
                a.status == AgentAppointmentStatus.upcomingVisit,
          )
          .toList();
    } else {
      return allAppointments
          .where((a) => a.status == AgentAppointmentStatus.visited)
          .toList();
    }
  }

  /// Change tab
  void changeTab(AgentAppointmentTab tab) {
    selectedTab.value = tab;
  }

  /// Refresh data
  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _loadMockData();
    isLoading.value = false;
  }

  /// Navigate to appointment details
  void goToAppointmentDetails(AgentAppointment appointment) {
    Get.snackbar(
      'Appointment Details',
      'Opening ${appointment.propertyTitle}...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to appointment details page
  }
}
