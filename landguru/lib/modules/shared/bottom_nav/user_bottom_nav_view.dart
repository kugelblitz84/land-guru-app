import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_bottom_nav_controller.dart';

/// User Bottom Navigation shell containing all main tabs
class UserBottomNavView extends GetView<UserBottomNavController> {
  const UserBottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement user bottom nav UI
    // - IndexedStack or PageView with 5 pages:
    //   - Home
    //   - Properties
    //   - Appointments
    //   - My Deals
    //   - Profile
    // - Bottom Navigation Bar with 5 items
    // - Icons: home, grid/properties, calendar, handshake/deals, person
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
