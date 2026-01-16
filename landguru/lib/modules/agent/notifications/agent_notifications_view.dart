import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agent_notifications_controller.dart';

/// Agent Notifications screen with filter chips
class AgentNotificationsView extends GetView<AgentNotificationsController> {
  const AgentNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement notifications UI
    // - AppBar with title and "Mark all as read" action
    // - Filter chips: All, Action Required, Appointments
    // - Notification list with:
    //   - Icon based on type (warning, info, calendar)
    //   - Title (New Service Request Assigned, etc.)
    //   - Description
    //   - Time ago
    //   - Unread indicator dot
    // - Empty state when no notifications
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
