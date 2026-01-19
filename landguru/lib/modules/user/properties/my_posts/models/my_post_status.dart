import 'package:flutter/material.dart';

/// Post status enum for My Posts section
enum MyPostStatus {
  pending, // Pending Admin Review
  quoted, // Has received quotes/offers
  active, // Published and live
  draft; // Saved as draft

  String get label {
    switch (this) {
      case MyPostStatus.pending:
        return 'Pending Admin Review';
      case MyPostStatus.quoted:
        return 'Quoted';
      case MyPostStatus.active:
        return 'Active';
      case MyPostStatus.draft:
        return 'Draft';
    }
  }

  Color get color {
    switch (this) {
      case MyPostStatus.pending:
        return const Color(0xFF9E9E9E);
      case MyPostStatus.quoted:
        return const Color(0xFFE53935);
      case MyPostStatus.active:
        return const Color(0xFF4CAF50);
      case MyPostStatus.draft:
        return const Color(0xFF9E9E9E);
    }
  }

  Color get textColor {
    switch (this) {
      case MyPostStatus.pending:
        return const Color(0xFF616161);
      case MyPostStatus.quoted:
        return const Color(0xFFFFFFFF);
      case MyPostStatus.active:
        return const Color(0xFFFFFFFF);
      case MyPostStatus.draft:
        return const Color(0xFF616161);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case MyPostStatus.pending:
        return const Color(0xFFE0E0E0);
      case MyPostStatus.quoted:
        return const Color(0xFFE53935);
      case MyPostStatus.active:
        return const Color(0xFF4CAF50);
      case MyPostStatus.draft:
        return const Color(0xFFE0E0E0);
    }
  }
}
