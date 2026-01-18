import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'metrics_input_field.dart';

/// Land size range data class (kept for backwards compatibility)
class LandSizeRange {
  final double minValue;
  final double maxValue;
  final String label;

  const LandSizeRange({
    required this.minValue,
    required this.maxValue,
    required this.label,
  });

  /// Get predefined ranges for a given unit (kept for backwards compatibility)
  static List<LandSizeRange> getRangesForUnit(LandUnit unit) {
    switch (unit) {
      case LandUnit.sqft:
        return const [
          LandSizeRange(minValue: 0, maxValue: 500, label: '0-500'),
          LandSizeRange(minValue: 500, maxValue: 1000, label: '500-1K'),
          LandSizeRange(minValue: 1000, maxValue: 2000, label: '1K-2K'),
          LandSizeRange(minValue: 2000, maxValue: 5000, label: '2K-5K'),
          LandSizeRange(minValue: 5000, maxValue: 10000, label: '5K-10K'),
          LandSizeRange(minValue: 10000, maxValue: 50000, label: '10K-50K'),
          LandSizeRange(minValue: 50000, maxValue: 100000, label: '50K+'),
        ];
      case LandUnit.katha:
        return const [
          LandSizeRange(minValue: 0, maxValue: 1, label: '0-1'),
          LandSizeRange(minValue: 1, maxValue: 2, label: '1-2'),
          LandSizeRange(minValue: 2, maxValue: 5, label: '2-5'),
          LandSizeRange(minValue: 5, maxValue: 10, label: '5-10'),
          LandSizeRange(minValue: 10, maxValue: 20, label: '10-20'),
          LandSizeRange(minValue: 20, maxValue: 50, label: '20-50'),
          LandSizeRange(minValue: 50, maxValue: 100, label: '50+'),
        ];
      case LandUnit.decimal:
        return const [
          LandSizeRange(minValue: 0, maxValue: 2, label: '0-2'),
          LandSizeRange(minValue: 2, maxValue: 5, label: '2-5'),
          LandSizeRange(minValue: 5, maxValue: 10, label: '5-10'),
          LandSizeRange(minValue: 10, maxValue: 20, label: '10-20'),
          LandSizeRange(minValue: 20, maxValue: 50, label: '20-50'),
          LandSizeRange(minValue: 50, maxValue: 100, label: '50-100'),
          LandSizeRange(minValue: 100, maxValue: 200, label: '100+'),
        ];
      case LandUnit.acre:
        return const [
          LandSizeRange(minValue: 0, maxValue: 0.5, label: '0-0.5'),
          LandSizeRange(minValue: 0.5, maxValue: 1, label: '0.5-1'),
          LandSizeRange(minValue: 1, maxValue: 2, label: '1-2'),
          LandSizeRange(minValue: 2, maxValue: 5, label: '2-5'),
          LandSizeRange(minValue: 5, maxValue: 10, label: '5-10'),
          LandSizeRange(minValue: 10, maxValue: 20, label: '10-20'),
          LandSizeRange(minValue: 20, maxValue: 50, label: '20+'),
        ];
      case LandUnit.bigha:
        return const [
          LandSizeRange(minValue: 0, maxValue: 1, label: '0-1'),
          LandSizeRange(minValue: 1, maxValue: 2, label: '1-2'),
          LandSizeRange(minValue: 2, maxValue: 5, label: '2-5'),
          LandSizeRange(minValue: 5, maxValue: 10, label: '5-10'),
          LandSizeRange(minValue: 10, maxValue: 20, label: '10-20'),
          LandSizeRange(minValue: 20, maxValue: 50, label: '20-50'),
          LandSizeRange(minValue: 50, maxValue: 100, label: '50+'),
        ];
    }
  }
}

/// Continuous land size slider widget that syncs with text field
class LandSizeRangeSlider extends StatelessWidget {
  final double currentValue;
  final LandUnit currentUnit;
  final ValueChanged<double> onChanged;
  final String? label;

  // Keep these for backwards compatibility but they are not used in new implementation
  final LandSizeRange? selectedRange;

  static const double minValue = 0;
  static const double maxValue = 9999;

  const LandSizeRangeSlider({
    super.key,
    this.currentValue = 0,
    required this.currentUnit,
    required this.onChanged,
    this.label,
    this.selectedRange, // Kept for backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Clamp the value to valid range
    final clampedValue = currentValue.clamp(minValue, maxValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slider
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.grey200,
                  overlayColor: AppColors.primary.withAlpha(30),
                  trackHeight: 4.h,
                  thumbShape: _BorderedThumbShape(
                    enabledThumbRadius: 11.r,
                    borderColor: AppColors.primary,
                    fillColor: AppColors.white,
                    borderWidth: 1.5,
                  ),
                ),
                child: Slider(
                  value: clampedValue,
                  min: minValue,
                  max: maxValue,
                  // No divisions - continuous slider
                  onChanged: (value) {
                    // Round to 3 decimal places for cleaner values
                    final roundedValue = (value * 1000).round() / 1000;
                    onChanged(roundedValue);
                  },
                ),
              ),
              SizedBox(height: 4.h),

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

/// Custom slider thumb shape with border
class _BorderedThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final Color borderColor;
  final Color fillColor;
  final double borderWidth;

  const _BorderedThumbShape({
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
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
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
