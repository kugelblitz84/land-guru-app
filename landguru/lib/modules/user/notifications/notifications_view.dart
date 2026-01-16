import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notifications_controller.dart';

/// User Notifications screen
class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement notifications UI
    // - AppBar with title and mark all as read action
    // - Notification list (empty state if no notifications)
    // - Each notification item with icon, title, message, time
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
