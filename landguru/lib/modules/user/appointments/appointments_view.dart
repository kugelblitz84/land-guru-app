import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'appointments_controller.dart';

/// User Appointments screen with tabs
class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement appointments UI
    // - Tab bar: Upcoming, Past, My Requests
    // - Appointment list cards
    // - Each card shows: Property image, title, date/time, status
    // - Actions: View Details, Cancel, Reschedule
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
