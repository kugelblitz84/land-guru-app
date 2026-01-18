import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Distance from road range options
class DistanceRange {
  final String label;
  final int minMeters;
  final int maxMeters;

  const DistanceRange({
    required this.label,
    required this.minMeters,
    required this.maxMeters,
  });

  /// Format meters to display string
  static String formatDistance(int meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return km == km.toInt()
          ? '${km.toInt()}km'
          : '${km.toStringAsFixed(1)}km';
    }
    return '${meters}m';
  }

  /// Get label from min and max values
  static String getLabel(int minMeters, int maxMeters) {
    return '${formatDistance(minMeters)}-${formatDistance(maxMeters)}';
  }

  /// Predefined distance values for the slider (kept for backwards compatibility)
  static const List<int> distanceValues = [
    0,
    50,
    100,
    200,
    500,
    750,
    1000,
    2000,
  ];
}

/// Distance from road range selector - continuous slider
class DistanceRangeSelector extends StatelessWidget {
  final DistanceRange? selectedRange;
  final ValueChanged<DistanceRange> onChanged;
  final String label;

  static const double minValue = 0;
  static const double maxValue = 9999;

  const DistanceRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onChanged,
    this.label = 'Distance From Road',
  });

  @override
  Widget build(BuildContext context) {
    // Get current values or defaults
    double startValue = selectedRange?.minMeters.toDouble() ?? minValue;
    double endValue = selectedRange?.maxMeters.toDouble() ?? maxValue;

    // Clamp values to valid range
    startValue = startValue.clamp(minValue, maxValue);
    endValue = endValue.clamp(minValue, maxValue);

    // Ensure start <= end
    if (startValue > endValue) {
      final temp = startValue;
      startValue = endValue;
      endValue = temp;
    }

    final displayLabel = selectedRange != null
        ? DistanceRange.getLabel(
            selectedRange!.minMeters,
            selectedRange!.maxMeters,
          )
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (selectedRange != null)
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),

        // Range slider visualization
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              // Range Slider - continuous (no divisions)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.grey200,
                  overlayColor: AppColors.primary.withAlpha(30),
                  trackHeight: 4.h,
                  rangeThumbShape: _BorderedRangeThumbShape(
                    enabledThumbRadius: 11.r,
                    borderColor: AppColors.primary,
                    fillColor: AppColors.white,
                    borderWidth: 1.5,
                  ),
                ),
                child: RangeSlider(
                  values: RangeValues(startValue, endValue),
                  min: minValue,
                  max: maxValue,
                  // No divisions - continuous slider
                  onChanged: (rangeValues) {
                    final minMeters = rangeValues.start.round();
                    final maxMeters = rangeValues.end.round();
                    onChanged(
                      DistanceRange(
                        label: DistanceRange.getLabel(minMeters, maxMeters),
                        minMeters: minMeters,
                        maxMeters: maxMeters,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),

              // Min/Max labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                  Text(
                    'Max',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom range slider thumb shape with border
class _BorderedRangeThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final Color borderColor;
  final Color fillColor;
  final double borderWidth;

  const _BorderedRangeThumbShape({
    required this.enabledThumbRadius,
    required this.borderColor,
    required this.fillColor,
    this.borderWidth = 2.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;

    // Draw white fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(
      center,
      enabledThumbRadius - borderWidth / 2,
      borderPaint,
    );
  }
}
