import 'package:flutter/material.dart';

/// Reusable appointment card widget
class AppointmentCard extends StatelessWidget {
  final DateTime date;
  final String title;
  final String? serviceId;
  final String? propertyType;
  final String location;
  final String? serviceType;
  final String status; // Visit Today, Upcoming Visit, Past
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.date,
    required this.title,
    this.serviceId,
    this.propertyType,
    required this.location,
    this.serviceType,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement appointment card UI
    // - Date badge (Jan 25)
    // - Title
    // - Service ID
    // - Property type badge
    // - Status badge (Visit Today, Upcoming)
    // - Location with icon
    // - Service type
    // - Arrow icon for navigation
    return const Placeholder();
  }
}
