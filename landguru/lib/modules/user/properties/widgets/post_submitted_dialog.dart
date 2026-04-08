import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'property_type_selector.dart';

/// Sell post summary data
class SellPostSummary {
  final String title;
  final String askingPrice;
  final PropertyType? propertyType;
  final String? imagePath;

  const SellPostSummary({
    required this.title,
    required this.askingPrice,
    this.propertyType,
    this.imagePath,
  });
}

/// Buy post summary data
class BuyPostSummary {
  final String title;
  final String location;
  final PropertyType? propertyType;
  final String landSize;
  final String? plotSize;
  final String? distanceFromRoad;
  final String budgetRange;
  final String? description;

  const BuyPostSummary({
    required this.title,
    required this.location,
    this.propertyType,
    required this.landSize,
    this.plotSize,
    this.distanceFromRoad,
    required this.budgetRange,
    this.description,
  });
}

/// Legacy PostSummary for backward compatibility
class PostSummary {
  final String title;
  final String? price;
  final PropertyType? propertyType;
  final String? location;
  final String? landSize;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? budgetRange;
  final String? description;

  const PostSummary({
    required this.title,
    this.price,
    this.propertyType,
    this.location,
    this.landSize,
    this.plotSize,
    this.distanceFromRoad,
    this.budgetRange,
    this.description,
  });
}

/// Post submitted success dialog helper class
class PostSubmittedDialog {
  PostSubmittedDialog._(); // Private constructor to prevent instantiation

  /// Show sell post submitted dialog
  static Future<void> showSellPost(
    BuildContext context, {
    required SellPostSummary summary,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SellPostSubmittedDialog(summary: summary, onClose: onClose),
    );
  }

  /// Show buy post submitted dialog
  static Future<void> showBuyPost(
    BuildContext context, {
    required BuyPostSummary summary,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          BuyPostSubmittedDialog(summary: summary, onClose: onClose),
    );
  }

  /// Legacy show method for backward compatibility
  static Future<void> show(
    BuildContext context, {
    required PostSummary summary,
    bool isBuyPost = false,
    required VoidCallback onClose,
  }) {
    if (isBuyPost) {
      return showBuyPost(
        context,
        summary: BuyPostSummary(
          title: summary.title,
          location: summary.location ?? '',
          propertyType: summary.propertyType,
          landSize: summary.landSize ?? '',
          plotSize: summary.plotSize,
          distanceFromRoad: summary.distanceFromRoad,
          budgetRange: summary.budgetRange ?? '',
          description: summary.description,
        ),
        onClose: onClose,
      );
    } else {
      return showSellPost(
        context,
        summary: SellPostSummary(
          title: summary.title,
          askingPrice: summary.price ?? '৳ 0',
          propertyType: summary.propertyType,
        ),
        onClose: onClose,
      );
    }
  }
}

/// Sell post submitted dialog - compact card with image, title, price, type, status
class SellPostSubmittedDialog extends StatelessWidget {
  final SellPostSummary summary;
  final VoidCallback onClose;

  const SellPostSubmittedDialog({
    super.key,
    required this.summary,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: AppColors.grey500, size: 24.sp),
              ),
            ),

            // Success icon
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.white, size: 40.sp),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Post Submitted',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'You will be prompted with quotation soon.\nIt may take up to 1-3 business days for reviewing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),

            // Property card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  _buildPropertyPreview(),
                  SizedBox(width: 12.w),

                  // Property info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Asking Price: ${summary.askingPrice}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            summary.propertyType?.label ?? 'Not specified',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Status section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Pending Admin Review',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPreview() {
    final imagePath = summary.imagePath?.trim();
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          imagePath,
          width: 64.w,
          height: 64.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPropertyPlaceholder(),
        ),
      );
    }

    return _buildPropertyPlaceholder();
  }

  Widget _buildPropertyPlaceholder() {
    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(80),
            AppColors.primaryDark.withAlpha(120),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.home,
          color: AppColors.white.withAlpha(200),
          size: 32.sp,
        ),
      ),
    );
  }
}

/// Buy post submitted dialog - detailed property requirements
class BuyPostSubmittedDialog extends StatelessWidget {
  final BuyPostSummary summary;
  final VoidCallback onClose;

  const BuyPostSubmittedDialog({
    super.key,
    required this.summary,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    color: AppColors.grey500,
                    size: 24.sp,
                  ),
                ),
              ),

              // Success icon
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: AppColors.white, size: 40.sp),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'Post Submitted',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Your post will be visible in the listing soon.\nIt may take up to 1-3 business days for reviewing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),

              // Details card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey200.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      summary.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Preferred Location
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Preferred Location',
                      summary.location,
                    ),

                    // Property Type
                    _buildDetailRow(
                      Icons.home_outlined,
                      'Property Type',
                      summary.propertyType?.label ?? 'Not specified',
                    ),

                    // Required Land Size
                    _buildDetailRow(
                      Icons.straighten,
                      'Required Land Size',
                      summary.landSize,
                    ),

                    // Minimum Plot Size
                    if (summary.plotSize != null &&
                        summary.plotSize!.isNotEmpty)
                      _buildDetailRow(
                        Icons.crop_square,
                        'Minimum Plot Size',
                        summary.plotSize!,
                      ),

                    // Distance from Road
                    if (summary.distanceFromRoad != null &&
                        summary.distanceFromRoad!.isNotEmpty)
                      _buildDetailRow(
                        Icons.directions,
                        'Distance from Road',
                        summary.distanceFromRoad!,
                      ),

                    // Budget Range
                    _buildDetailRow(
                      Icons.payments_outlined,
                      'Budget Range',
                      summary.budgetRange,
                    ),

                    // Description
                    if (summary.description != null &&
                        summary.description!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        summary.description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Status section
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Pending Admin Review',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
