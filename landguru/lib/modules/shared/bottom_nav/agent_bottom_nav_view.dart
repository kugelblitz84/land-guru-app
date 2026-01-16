import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agent_bottom_nav_controller.dart';

/// Agent Bottom Navigation shell containing all main tabs
class AgentBottomNavView extends GetView<AgentBottomNavController> {
  const AgentBottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement agent bottom nav UI
    // - IndexedStack or PageView with 4 pages:
    //   - Home (Dashboard)
    //   - My Tasks
    //   - Appointments
    //   - Profile
    // - Bottom Navigation Bar with 4 items
    // - Icons: home, list/tasks, calendar, person
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
