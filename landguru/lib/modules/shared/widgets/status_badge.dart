import 'package:flutter/material.dart';

/// Reusable status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const StatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  /// Factory for common status badges
  factory StatusBadge.verified() => const StatusBadge(
        text: 'Verified',
        backgroundColor: Color(0xFF4CAF50),
        textColor: Colors.white,
      );

  factory StatusBadge.pending() => const StatusBadge(
        text: 'Pending',
        backgroundColor: Color(0xFFFF9800),
        textColor: Colors.white,
      );

  factory StatusBadge.active() => const StatusBadge(
        text: 'Active',
        backgroundColor: Color(0xFF2196F3),
        textColor: Colors.white,
      );

  factory StatusBadge.draft() => const StatusBadge(
        text: 'Draft',
        backgroundColor: Color(0xFF9E9E9E),
        textColor: Colors.white,
      );

  factory StatusBadge.quoted() => const StatusBadge(
        text: 'Quoted',
        backgroundColor: Color(0xFF9C27B0),
        textColor: Colors.white,
      );

  factory StatusBadge.newRequest() => const StatusBadge(
        text: 'NEW REQUEST',
        backgroundColor: Color(0xFFFF6B35),
        textColor: Colors.white,
      );

  factory StatusBadge.inReview() => const StatusBadge(
        text: 'IN REVIEW',
        backgroundColor: Color(0xFF3B6CF5),
        textColor: Colors.white,
      );

  factory StatusBadge.completed() => const StatusBadge(
        text: 'COMPLETED',
        backgroundColor: Color(0xFF4CAF50),
        textColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    // TODO: Implement status badge UI
    // - Container with rounded corners
    // - Background color
    // - Text with appropriate styling
    return const Placeholder();
  }
}
