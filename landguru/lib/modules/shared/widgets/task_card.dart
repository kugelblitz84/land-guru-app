import 'package:flutter/material.dart';

/// Reusable task card widget for agent tasks listing
class TaskCard extends StatelessWidget {
  final String serviceType;
  final String serviceName;
  final String serviceId;
  final String clientName;
  final String location;
  final String status;
  final DateTime? deadline;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const TaskCard({
    super.key,
    required this.serviceType,
    required this.serviceName,
    required this.serviceId,
    required this.clientName,
    required this.location,
    required this.status,
    this.deadline,
    this.onTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement task card UI
    // - Status badge (NEW REQUEST, ACTIVE, IN REVIEW, etc.)
    // - Service name
    // - Service ID
    // - Client name with icon
    // - Location with icon
    // - Deadline (Accept Before)
    // - View Details button
    return const Placeholder();
  }
}
