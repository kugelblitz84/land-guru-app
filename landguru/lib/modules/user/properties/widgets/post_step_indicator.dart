import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Step progress indicator for multi-step post creation flows
class PostStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onSaveAsDraft;

  const PostStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onSaveAsDraft,
  });

  int get percentage => ((currentStep / totalSteps) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step count and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Progress bars
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep - 1;
            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 8.w : 0,
                ),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }),
        ),

        // Save as Draft link
        if (onSaveAsDraft != null) ...[
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onSaveAsDraft,
              child: Text(
                'Save as Draft',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
