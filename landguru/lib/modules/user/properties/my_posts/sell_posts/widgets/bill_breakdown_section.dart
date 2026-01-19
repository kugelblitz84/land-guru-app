import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/sell_post_models.dart';

/// Bill Breakdown Section for Quoted status
class BillBreakdownSection extends StatelessWidget {
  final BillBreakdown billBreakdown;
  final VoidCallback onRequote;
  final VoidCallback onPayAndActivate;

  const BillBreakdownSection({
    super.key,
    required this.billBreakdown,
    required this.onRequote,
    required this.onPayAndActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Bill Breakdown',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.grey200),
          SizedBox(height: 12.h),

          // Service Fees Label
          Text(
            'Service Fees',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 12.h),

          // Mandatory Service Fees
          _buildServiceFeeSection(
            'Mandatory Service Fees',
            billBreakdown.mandatoryServices,
            billBreakdown.mandatoryTotal,
          ),

          SizedBox(height: 16.h),

          // Optional Service Fees
          _buildServiceFeeSection(
            'Optional Service Fees',
            billBreakdown.optionalServices,
            billBreakdown.optionalTotal,
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.grey200),
          SizedBox(height: 12.h),

          // Total Payable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              Text(
                '৳ ${billBreakdown.totalPayable.toInt()}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.grey200),
          SizedBox(height: 12.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRequote,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey900,
                    side: BorderSide(color: AppColors.grey300, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Requote',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPayAndActivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Pay & Activate Post',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeeSection(
    String title,
    List<ServiceFeeItem> services,
    double total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            Text(
              '৳ ${total.toInt()}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...services.map(
          (service) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    service.name,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Requote Summary Card (Quoted status footer)
class RequoteSummaryCard extends StatelessWidget {
  final BillBreakdown billBreakdown;

  const RequoteSummaryCard({super.key, required this.billBreakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_buildInfoRow('Your Last Requote Amount', '৳ ${(billBreakdown.lastRequoteAmount ?? 0).toInt()}', AppColors.primary),
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Your Last Requote Amount',
            '৳ ${(billBreakdown.lastRequoteAmount ?? 0).toInt()}',
            AppColors.primary,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Mandatory Service Fees',
            '৳ ${(billBreakdown.mandatoryServiceFees ?? 0).toInt()}',
            AppColors.black,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Optional Service Fees',
            '৳ ${(billBreakdown.optionalServiceFees ?? 0).toInt()}',
            AppColors.black,
          ),
          SizedBox(height: 8.h),
          Text(
            'Quotation Revised: ${billBreakdown.quotationRevisions} times',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.grey600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: color,
            //decoration: TextDecoration.underline,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
