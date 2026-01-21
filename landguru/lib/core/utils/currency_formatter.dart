import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Currency formatting utilities
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a number with comma separators (Indian/Bangladeshi style)
  /// e.g., 10000000 -> "1,00,00,000"
  static String format(dynamic value) {
    if (value == null) return '0';

    double number;
    if (value is String) {
      // Remove existing formatting
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      number = double.tryParse(cleaned) ?? 0;
    } else if (value is int) {
      number = value.toDouble();
    } else if (value is double) {
      number = value;
    } else {
      return '0';
    }

    if (number == 0) return '0';

    // Format with Indian/Bangladeshi comma style
    return _formatIndianStyle(number);
  }

  /// Format with currency symbol
  static String formatWithSymbol(dynamic value, {String symbol = '৳'}) {
    return '$symbol ${format(value)}';
  }

  /// Indian/Bangladeshi number formatting (xx,xx,xxx)
  static String _formatIndianStyle(double number) {
    final isNegative = number < 0;
    number = number.abs();

    // Handle decimals
    final parts = number.toStringAsFixed(0).split('.');
    String integerPart = parts[0];

    if (integerPart.length <= 3) {
      return isNegative ? '-$integerPart' : integerPart;
    }

    // Format: last 3 digits, then groups of 2
    final lastThree = integerPart.substring(integerPart.length - 3);
    final remaining = integerPart.substring(0, integerPart.length - 3);

    // Add commas every 2 digits for the remaining part
    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }

    final result = '${buffer.toString()},$lastThree';
    return isNegative ? '-$result' : result;
  }

  /// Parse a formatted string back to double
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

/// A responsive text widget for displaying currency amounts
/// Automatically adjusts font size to fit within constraints
class ResponsiveCurrencyText extends StatelessWidget {
  final String amount;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final Color? color;
  final int maxLines;
  final TextAlign textAlign;
  final String? prefix;

  const ResponsiveCurrencyText({
    super.key,
    required this.amount,
    this.maxFontSize = 18,
    this.minFontSize = 10,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = prefix != null ? '$prefix $amount' : amount;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.end
          ? Alignment.centerRight
          : textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: maxFontSize.sp,
          fontWeight: fontWeight,
          color: color,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }
}
