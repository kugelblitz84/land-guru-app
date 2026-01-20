import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/land_unit.dart';
import '../../../../core/utils/land_unit_converter.dart';

export '../../../../core/enums/land_unit.dart';
export '../../../../core/utils/land_unit_converter.dart';

/// Helper class for parsing and formatting land measurement values
class LandValueHelper {
  /// Parse numeric value from a string (removes unit labels like Katha, Decimal, etc.)
  static double parseNumericValue(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[Mm]in\s*'), '')
        .replaceAll(RegExp(r'[Mm]ax\s*'), '')
        .replaceAll(RegExp(r'[Kk]atha'), '')
        .replaceAll(RegExp(r'[Dd]ecimal'), '')
        .replaceAll(RegExp(r'[Aa]cre'), '')
        .replaceAll(RegExp(r'[Bb]igha'), '')
        .replaceAll(RegExp(r'[Ss]qft'), '')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  /// Format a value with unit conversion
  /// [value] - the numeric value in original unit (default: Katha)
  /// [unit] - the target unit to display
  /// [fromUnit] - the source unit (default: Katha)
  /// [prefix] - optional prefix like "Min" or "Max"
  /// [notSpecifiedText] - text to show when value is 0
  static String formatValue(
    double value,
    LandUnit unit, {
    LandUnit fromUnit = LandUnit.katha,
    String? prefix,
    String notSpecifiedText = 'Not specified',
  }) {
    if (value == 0) return notSpecifiedText;
    final converted = LandUnitConverter.fromSqft(
      LandUnitConverter.toSqft(value, fromUnit),
      unit,
    );
    String formattedNumber;
    if (converted >= 1) {
      formattedNumber = converted.toStringAsFixed(
        converted.truncateToDouble() == converted ? 0 : 2,
      );
    } else {
      formattedNumber = converted.toStringAsFixed(4);
    }
    if (prefix != null && prefix.isNotEmpty) {
      return '$prefix $formattedNumber ${unit.label}';
    }
    return '$formattedNumber ${unit.label}';
  }
}

/// PopupMenuButton widget for changing measurement unit
class ChangeMetricsPopup extends StatelessWidget {
  final LandUnit selectedUnit;
  final ValueChanged<LandUnit> onUnitChanged;
  final String? label;

  const ChangeMetricsPopup({
    super.key,
    required this.selectedUnit,
    required this.onUnitChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LandUnit>(
      onSelected: onUnitChanged,
      offset: Offset(0, 30.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      itemBuilder: (context) {
        return LandUnit.values.map((unit) {
          final isSelected = unit == selectedUnit;
          return PopupMenuItem<LandUnit>(
            value: unit,
            child: Text(
              unit.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.grey700,
              ),
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label ?? 'Change Metrics',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.arrow_drop_down, size: 16.sp, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// Displays conversion values for other metrics
class MetricsConversionRow extends StatelessWidget {
  final double value;
  final LandUnit currentUnit;
  final String? label;
  final VoidCallback? onTap;

  const MetricsConversionRow({
    super.key,
    required this.value,
    required this.currentUnit,
    this.label,
    this.onTap,
  });

  String _formatValue(double val) {
    if (val >= 1000) {
      return val.toStringAsFixed(0);
    } else if (val >= 1) {
      return val.toStringAsFixed(2);
    } else {
      return val.toStringAsFixed(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversions = LandUnitConverter.getAllConversions(value, currentUnit);

    // Filter out current unit and build display list
    final displayUnits = LandUnit.values
        .where((u) => u != currentUnit)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
        ],
        GestureDetector(
          onTap: onTap,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: displayUnits.map((unit) {
                final convertedValue = conversions[unit] ?? 0;
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Text(
                    '${_formatValue(convertedValue)} ${unit.label}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
