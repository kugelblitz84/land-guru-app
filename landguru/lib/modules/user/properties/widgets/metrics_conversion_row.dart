import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'metrics_input_field.dart';

/// Utility class for land unit conversions
class LandUnitConverter {
  // Base unit is Sqft
  static const double sqftPerKatha = 720.0;
  static const double sqftPerDecimal = 435.6;
  static const double sqftPerAcre = 43560.0;
  static const double sqftPerBigha = 14400.0;

  /// Convert a value from one unit to sqft
  static double toSqft(double value, LandUnit unit) {
    switch (unit) {
      case LandUnit.sqft:
        return value;
      case LandUnit.katha:
        return value * sqftPerKatha;
      case LandUnit.decimal:
        return value * sqftPerDecimal;
      case LandUnit.acre:
        return value * sqftPerAcre;
      case LandUnit.bigha:
        return value * sqftPerBigha;
    }
  }

  /// Convert sqft to a specific unit
  static double fromSqft(double sqft, LandUnit unit) {
    switch (unit) {
      case LandUnit.sqft:
        return sqft;
      case LandUnit.katha:
        return sqft / sqftPerKatha;
      case LandUnit.decimal:
        return sqft / sqftPerDecimal;
      case LandUnit.acre:
        return sqft / sqftPerAcre;
      case LandUnit.bigha:
        return sqft / sqftPerBigha;
    }
  }

  /// Get all conversions for a given value and unit
  static Map<LandUnit, double> getAllConversions(
    double value,
    LandUnit fromUnit,
  ) {
    final sqft = toSqft(value, fromUnit);
    return {for (final unit in LandUnit.values) unit: fromSqft(sqft, unit)};
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
