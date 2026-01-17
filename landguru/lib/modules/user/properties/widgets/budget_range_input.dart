import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Budget range input with min-max fields
class BudgetRangeInput extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final String label;
  final String? Function(String?)? minValidator;
  final String? Function(String?)? maxValidator;

  const BudgetRangeInput({
    super.key,
    required this.minController,
    required this.maxController,
    this.label = 'Budget Range',
    this.minValidator,
    this.maxValidator,
  });

  String _formatBudgetDisplay(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null) return value;

    if (number >= 10000000) {
      return '৳ ${(number / 10000000).toStringAsFixed(2)} Cr';
    } else if (number >= 100000) {
      return '৳ ${(number / 100000).toStringAsFixed(2)} Lac';
    }
    return '৳ $value';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with range display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: minController,
              builder: (context, minValue, _) {
                return ValueListenableBuilder(
                  valueListenable: maxController,
                  builder: (context, maxValue, _) {
                    final minDisplay = _formatBudgetDisplay(minController.text);
                    final maxDisplay = _formatBudgetDisplay(maxController.text);
                    if (minDisplay.isNotEmpty && maxDisplay.isNotEmpty) {
                      return Text(
                        '$minDisplay - $maxDisplay',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Min - Max input row
        Row(
          children: [
            // Min input
            Expanded(
              child: _buildBudgetField(
                controller: minController,
                hint: 'Min',
                validator: minValidator,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                '-',
                style: TextStyle(fontSize: 20.sp, color: AppColors.grey400),
              ),
            ),
            // Max input
            Expanded(
              child: _buildBudgetField(
                controller: maxController,
                hint: 'Max',
                validator: maxValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      style: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
      decoration: InputDecoration(
        prefixText: '৳ ',
        prefixStyle: TextStyle(fontSize: 16.sp, color: AppColors.grey900),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.grey400),
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

/// Widget to display the calculated asking price
class AskingPriceDisplay extends StatelessWidget {
  final double askingPrice;
  final String label;

  const AskingPriceDisplay({
    super.key,
    required this.askingPrice,
    this.label = 'Asking Price',
  });

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '৳ ${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '৳ ${(price / 100000).toStringAsFixed(2)} Lac';
    } else if (price >= 1000) {
      return '৳ ${price.toStringAsFixed(0)}';
    }
    return '৳ ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatPrice(askingPrice),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
