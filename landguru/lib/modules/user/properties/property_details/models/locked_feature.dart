import 'package:flutter/material.dart';

/// Model for locked feature item
class LockedFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const LockedFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

/// Model for unlocked feature with expandable content
class UnlockedFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? expandedContent;
  final bool isExpanded;

  const UnlockedFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.expandedContent,
    this.isExpanded = false,
  });

  UnlockedFeature copyWith({bool? isExpanded}) {
    return UnlockedFeature(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      expandedContent: expandedContent,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
