import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'task_details_controller.dart';

/// Agent Task Details screen
/// Adapts UI based on task status (New, Active, In Review, Done)
class AgentTaskDetailsView extends GetView<AgentTaskDetailsController> {
  const AgentTaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement task details UI
    // - AppBar with "Task Details" title
    // - Service info card: type, ID, status badge, deadline
    // - Assigned Service Fee
    // - Task Status stepper (Accepted, Processing, In Review)
    // - Appointment section (optional, with Set Date & Time)
    // - Property & Client Info section
    // - Property Photos section
    // - Raw Documents (From Client) section
    // - Work Log section (for Active tasks)
    // - Actions based on status:
    //   - New: Accept Task button
    //   - Active: Post Update, Attach, Submit for Review buttons
    //   - In Review: Read-only view
    //   - Done: Read-only view
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
