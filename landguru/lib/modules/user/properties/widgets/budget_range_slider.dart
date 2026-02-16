import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Budget range data class
class BudgetRange {
  final int minBudget;
  final int maxBudget;

  const BudgetRange({required this.minBudget, required this.maxBudget});

  /// Format budget value for display (with comma separators)
  static String formatBudget(int value) {
    return CurrencyFormatter.format(value);
  }

  /// Get label from min and max values
  String get label =>
      '৳ ${formatBudget(minBudget)} - ৳ ${formatBudget(maxBudget)}';

  /// Format number with Indian style commas (e.g., 30,00,000)
  static String formatWithCommas(int value) {
    return CurrencyFormatter.format(value);
  }

  /// Predefined budget values
  static const List<int> budgetValues = [
    0,

    // 0 – 1 lakh (10k steps)
    10000,
    20000,
    30000,
    40000,
    50000,
    60000,
    70000,
    80000,
    90000,
    100000,

    // 1 – 5 lakh (50k steps)
    150000,
    200000,
    250000,
    300000,
    350000,
    400000,
    450000,
    500000,

    // 5 – 10 lakh (1 lakh steps)
    600000,
    700000,
    800000,
    900000,
    1000000,

    // 10 – 25 lakh (2.5 lakh steps)
    1250000,
    1500000,
    1750000,
    2000000,
    2250000,
    2500000,

    // 25 – 50 lakh (5 lakh steps)
    3000000,
    3500000,
    4000000,
    4500000,
    5000000,

    // 50 lakh – 1 crore (10 lakh steps)
    6000000,
    7000000,
    8000000,
    9000000,
    10000000,
  ];
}

/// Budget range selector - continuous slider
class BudgetRangeSlider extends StatelessWidget {
  final BudgetRange? selectedRange;
  final TextEditingController minBudgetController;
  final TextEditingController maxBudgetController;
  final ValueChanged<BudgetRange> onChanged;
  final String label;

  // Min and max budget values (0 to 99,99,999)
  static const double minValue = 0;
  static const double maxValue = 9999999;

  const BudgetRangeSlider({
    super.key,
    required this.selectedRange,
    required this.minBudgetController,
    required this.maxBudgetController,
    required this.onChanged,
    this.label = 'Budget Range',
  });

  int _parseControllerValue(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text.replaceAll(',', '').trim()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    // Get current values or defaults
    final minFromController = _parseControllerValue(
      minBudgetController,
      minValue.toInt(),
    );
    final maxFromController = _parseControllerValue(
      maxBudgetController,
      maxValue.toInt(),
    );

    double startValue =
        selectedRange?.minBudget.toDouble() ?? minFromController.toDouble();
    double endValue =
        selectedRange?.maxBudget.toDouble() ?? maxFromController.toDouble();

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
                    onChanged(
                      BudgetRange(minBudget: minBudget, maxBudget: maxBudget),
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
              SizedBox(height: 16.h),

              // Min/Max value boxes
              Row(
                children: [
                  // Min budget box
                  Expanded(
                    child: Semantics(
                      label: 'Minimum budget input',
                      textField: true,
                      child: TextFormField(
                        controller: minBudgetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey900,
                        ),
                        decoration: InputDecoration(
                          prefixText: '৳ ',
                          hintText: minValue.toInt().toString(),
                          filled: true,
                          fillColor: AppColors.grey100,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
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
                    child: Semantics(
                      label: 'Maximum budget input',
                      textField: true,
                      child: TextFormField(
                        controller: maxBudgetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey900,
                        ),
                        decoration: InputDecoration(
                          prefixText: '৳ ',
                          hintText: maxValue.toInt().toString(),
                          filled: true,
                          fillColor: AppColors.grey100,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
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
