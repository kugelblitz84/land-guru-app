import 'package:flutter/material.dart';

/// Property type enum - used across the app for categorizing properties
enum PropertyType {
  plainLand,
  waterLand,
  flat;

  String get label {
    switch (this) {
      case PropertyType.plainLand:
        return 'Plain Land';
      case PropertyType.waterLand:
        return 'Water Land';
      case PropertyType.flat:
        return 'Flat';
    }
  }

  Color get color {
    switch (this) {
      case PropertyType.plainLand:
        return const Color(0xFF2E7D32); // Green
      case PropertyType.waterLand:
        return const Color(0xFF0288D1); // Blue
      case PropertyType.flat:
        return const Color(0xFF3B6CF5); // Primary blue
    }
  }
}
