import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Budget range data class
class BudgetRange {
  final int minBudget;
  final int maxBudget;

  const BudgetRange({
    required this.minBudget,
    required this.maxBudget,
  });

  /// Format budget value for display
  static String formatBudget(int value) {
    if (value >= 10000000) {
      final cr = value / 10000000;
      return cr == cr.toInt()
          ? '${cr.toInt()} Cr'
          : '${cr.toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      final lac = value / 100000;
      return lac == lac.toInt()
          ? '${lac.toInt()} Lac'
          : '${lac.toStringAsFixed(1)} Lac';
    } else if (value >= 1000) {
      final k = value / 1000;
      return k == k.toInt() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return '৳$value';
  }

  /// Get label from min and max values
  String get label =>
      '৳ ${formatBudget(minBudget)} - ৳ ${formatBudget(maxBudget)}';

  /// Format number with Indian style commas (e.g., 30,00,000)
  static String formatWithCommas(int value) {
    if (value == 0) return '0';
    String numStr = value.toString();
    String result = '';
    int count = 0;

    // Process from right to left
    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      } else if (count > 3 && (count - 3) % 2 == 0) {
        result = ',$result';
      }
      result = numStr[i] + result;
      count++;
    }
    return result;
  }

  /// Predefined budget values (kept for backwards compatibility)
  static const List<int> budgetValues = [
    0,
    100000, // 1 Lac
    500000, // 5 Lac
    1000000, // 10 Lac
    2500000, // 25 Lac
    5000000, // 50 Lac
    10000000, // 1 Cr
    25000000, // 2.5 Cr
    50000000, // 5 Cr
    100000000, // 10 Cr
    250000000, // 25 Cr
    500000000, // 50 Cr
  ];
}

/// Budget range selector - continuous slider
class BudgetRangeSlider extends StatelessWidget {
  final BudgetRange? selectedRange;
  final ValueChanged<BudgetRange> onChanged;
  final String label;

  // Min and max budget values (0 to 50 Cr)
  static const double minValue = 0;
  static const double maxValue = 500000000; // 50 Cr

  const BudgetRangeSlider({
    super.key,
    required this.selectedRange,
    required this.onChanged,
    this.label = 'Budget Range',
  });

  @override
  Widget build(BuildContext context) {
    // Get current values or defaults
    double startValue = selectedRange?.minBudget.toDouble() ?? minValue;
    double endValue = selectedRange?.maxBudget.toDouble() ?? maxValue;

    // Clamp values to valid range
    startValue = startValue.clamp(minValue, maxValue);
    endValue = endValue.clamp(minValue, maxValue);

    // Ensure start <= end
    if (startValue > endValue) {
      final temp = startValue;
      startValue = endValue;
      endValue = temp;
    }

    final displayLabel = selectedRange != null ? selectedRange!.label : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                ),
              ],
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
                    // Round to nearest 1000 for cleaner budget values
                    final minBudget = (rangeValues.start / 1000).round() * 1000;
                    final maxBudget = (rangeValues.end / 1000).round() * 1000;
                    onChanged(BudgetRange(
                      minBudget: minBudget,
                      maxBudget: maxBudget,
                    ));
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
              SizedBox(height: 16.h),

              // Min/Max value boxes
              Row(
                children: [
                  // Min budget box
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        selectedRange != null
                            ? BudgetRange.formatWithCommas(
                                selectedRange!.minBudget)
                            : '0',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  // Max budget box
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        selectedRange != null
                            ? BudgetRange.formatWithCommas(
                                selectedRange!.maxBudget)
                            : '0',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
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
