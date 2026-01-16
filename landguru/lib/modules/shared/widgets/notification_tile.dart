import 'package:flutter/material.dart';

/// Reusable notification tile widget
class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color? iconBackgroundColor;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.icon,
    this.iconBackgroundColor,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement notification tile UI
    // - Icon with colored background
    // - Title (bold if unread)
    // - Description
    // - Time ago
    // - Unread indicator dot
    return const Placeholder();
  }
}
