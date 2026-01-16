import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agent_dashboard_controller.dart';

/// Agent Dashboard/Home screen
class AgentDashboardView extends GetView<AgentDashboardController> {
  const AgentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement agent dashboard UI
    // - Header with agent name, avatar, notification icon
    // - Assigned location card
    // - Stats row: New Requests, Active Jobs, Done (this month)
    // - "Requires Scheduling" section with horizontal scroll cards
    // - "Today's Schedule" section with timeline view
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
