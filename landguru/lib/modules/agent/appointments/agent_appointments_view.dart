import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agent_appointments_controller.dart';

/// Agent Appointments screen with tabs: Upcoming, Past
class AgentAppointmentsView extends GetView<AgentAppointmentsController> {
  const AgentAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement appointments UI
    // - Header with agent name and notification icon
    // - Tab bar: Upcoming, Past
    // - Sort dropdown (Date)
    // - Appointment list cards showing:
    //   - Date badge (Jan 25)
    //   - Property title
    //   - Service ID
    //   - Property type badge (Flat, etc.)
    //   - Visit status (Visit Today, Upcoming Visit)
    //   - Location
    //   - Service type
    //   - Arrow to view details
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
