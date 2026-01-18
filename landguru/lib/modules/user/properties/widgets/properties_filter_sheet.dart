import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../properties_controller.dart';
import 'distance_range_selector.dart';

/// Filter property type enum for the filter sheet
enum FilterPropertyType {
  plainLand('Plain Land'),
  flat('Flat'),
  commercial('Commercial'),
  waterLand('Water Land'),
  agroLand('Agro Land'),
  blankRoof('Blank Roof');

  final String label;
  const FilterPropertyType(this.label);
}

/// Land size range for filter sliders
class LandSizeFilterRange {
  final double minKatha;
  final double maxKatha;

  const LandSizeFilterRange({required this.minKatha, required this.maxKatha});

  String get label {
    final minStr = minKatha == minKatha.toInt()
        ? '${minKatha.toInt()} Katha'
        : '${minKatha.toStringAsFixed(1)} Katha';
    final maxStr = maxKatha == maxKatha.toInt()
        ? '${maxKatha.toInt()} Katha'
        : '${maxKatha.toStringAsFixed(1)} Katha';
    return '$minStr - $maxStr';
  }
}

/// Price range for filter
class PriceFilterRange {
  final int minPrice;
  final int maxPrice;

  const PriceFilterRange({required this.minPrice, required this.maxPrice});

  /// Format price with Indian style commas
  static String formatPrice(int value) {
    if (value == 0) return '0';
    String numStr = value.toString();
    String result = '';
    int count = 0;

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

  String get label => '৳ ${formatPrice(minPrice)} - ৳ ${formatPrice(maxPrice)}';
}

/// Properties filter bottom sheet
class PropertiesFilterSheet extends StatelessWidget {
  final PropertiesController controller;

  const PropertiesFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          _buildHeader(),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Property Type
                  _buildPropertyTypeSection(),

                  SizedBox(height: 24.h),

                  // Price Range
                  _buildPriceRangeSection(),

                  SizedBox(height: 24.h),

                  // Sellable Land Amount
                  _buildSellableLandSection(),

                  SizedBox(height: 24.h),

                  // Plot Size
                  _buildPlotSizeSection(),

                  SizedBox(height: 24.h),

                  // Distance From Road
                  _buildDistanceSection(),

                  SizedBox(height: 24.h),

                  // Division
                  _buildDropdownField(
                    label: 'Division',
                    hint: 'Select your division',
                    value: controller.filterDivision,
                    items: controller.divisionOptions,
                    onChanged: (value) =>
                        controller.filterDivision.value = value ?? '',
                  ),

                  SizedBox(height: 16.h),

                  // District
                  _buildDropdownField(
                    label: 'District',
                    hint: 'Select your division',
                    value: controller.filterDistrict,
                    items: controller.districtOptions,
                    onChanged: (value) =>
                        controller.filterDistrict.value = value ?? '',
                  ),

                  SizedBox(height: 16.h),

                  // Upazilla
                  _buildDropdownField(
                    label: 'Upazilla',
                    hint: 'Select your upazilla',
                    value: controller.filterUpazilla,
                    items: controller.upazillaOptions,
                    onChanged: (value) =>
                        controller.filterUpazilla.value = value ?? '',
                  ),

                  SizedBox(height: 16.h),

                  // Pouroshova/City Corp/Union
                  _buildDropdownField(
                    label: 'Pouroshova/City Corp/Union',
                    hint: 'Select your Pouroshova/City Corp *',
                    value: controller.filterPouroshova,
                    items: controller.pouroshovaOptions,
                    onChanged: (value) =>
                        controller.filterPouroshova.value = value ?? '',
                  ),

                  SizedBox(height: 16.h),

                  // Ward No
                  _buildDropdownField(
                    label: 'Ward No',
                    hint: 'Select Ward No',
                    value: controller.filterWardNo,
                    items: controller.wardOptions,
                    onChanged: (value) =>
                        controller.filterWardNo.value = value ?? '',
                  ),

                  SizedBox(height: 24.h),

                  // Show Results Button
                  _buildShowResultsButton(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.resetFilters,
            child: Text(
              'Reset',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            'Filter Search',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.close, size: 24.sp, color: AppColors.grey700),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: FilterPropertyType.values.map((type) {
              final isSelected =
                  controller.filterPropertyType.value == type.name;
              return GestureDetector(
                onTap: () => controller.filterPropertyType.value = type.name,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.grey200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Obx(() {
      final range = controller.filterPriceRange.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              if (range != null)
                Text(
                  range.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildRangeSlider(
            startValue: range?.minPrice.toDouble() ?? 0,
            endValue: range?.maxPrice.toDouble() ?? 100000000,
            minValue: 0,
            maxValue: 100000000,
            onChanged: (start, end) {
              controller.filterPriceRange.value = PriceFilterRange(
                minPrice: (start / 100000).round() * 100000,
                maxPrice: (end / 100000).round() * 100000,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildSellableLandSection() {
    return Obx(() {
      final range = controller.filterSellableLandAmount.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sellable Land Amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              if (range != null)
                Text(
                  range.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildRangeSlider(
            startValue: range?.minKatha ?? 0,
            endValue: range?.maxKatha ?? 100,
            minValue: 0,
            maxValue: 100,
            onChanged: (start, end) {
              controller.filterSellableLandAmount.value = LandSizeFilterRange(
                minKatha: (start * 10).round() / 10,
                maxKatha: (end * 10).round() / 10,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildPlotSizeSection() {
    return Obx(() {
      final range = controller.filterPlotSize.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plot Size',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              if (range != null)
                Text(
                  range.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildRangeSlider(
            startValue: range?.minKatha ?? 0,
            endValue: range?.maxKatha ?? 100,
            minValue: 0,
            maxValue: 100,
            onChanged: (start, end) {
              controller.filterPlotSize.value = LandSizeFilterRange(
                minKatha: (start * 10).round() / 10,
                maxKatha: (end * 10).round() / 10,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildDistanceSection() {
    return Obx(() {
      return DistanceRangeSelector(
        label: 'Distance From Road',
        selectedRange: controller.filterDistanceRange.value,
        onChanged: (range) {
          controller.filterDistanceRange.value = range;
        },
      );
    });
  }

  Widget _buildRangeSlider({
    required double startValue,
    required double endValue,
    required double minValue,
    required double maxValue,
    required void Function(double start, double end) onChanged,
  }) {
    // Clamp values to valid range
    double clampedStart = startValue.clamp(minValue, maxValue);
    double clampedEnd = endValue.clamp(minValue, maxValue);

    // Ensure start <= end
    if (clampedStart > clampedEnd) {
      final temp = clampedStart;
      clampedStart = clampedEnd;
      clampedEnd = temp;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
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
              values: RangeValues(clampedStart, clampedEnd),
              min: minValue,
              max: maxValue,
              onChanged: (values) {
                onChanged(values.start, values.end);
              },
            ),
          ),
          SizedBox(height: 8.h),
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required RxString value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value.isEmpty ? null : value.value,
                hint: Text(
                  hint,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey400),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.grey600,
                  size: 24.sp,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey900,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowResultsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.applyFilters();
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Show Results',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, size: 20.sp),
          ],
        ),
      ),
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
