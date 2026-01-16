import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_tasks_controller.dart';

/// Agent My Tasks screen with tabs: New, Active, In Review, Done
class AgentMyTasksView extends GetView<AgentMyTasksController> {
  const AgentMyTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement my tasks UI
    // - Header with agent name and notification icon
    // - Search bar
    // - Tab bar: New, Active, In Review, Done
    // - Assigned location info
    // - Service type filter
    // - Task list with cards showing:
    //   - Service type badge (NEW REQUEST, ACTIVE, etc.)
    //   - Service name
    //   - Client name
    //   - Location
    //   - Accept before deadline
    //   - View Details button
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
