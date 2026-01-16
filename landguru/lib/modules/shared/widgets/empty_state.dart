import 'package:flutter/material.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement empty state UI
    // - Centered content
    // - Icon or illustration
    // - Title text
    // - Subtitle text
    // - Optional action button
    return const Placeholder();
  }
}
