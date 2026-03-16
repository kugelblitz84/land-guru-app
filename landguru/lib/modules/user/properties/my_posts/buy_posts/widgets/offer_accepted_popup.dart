import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/buy_post_models.dart';

/// Popup dialog shown when user accepts an offer
class OfferAcceptedPopup extends StatelessWidget {
  final OfferReceived offer;
  final VoidCallback onClose;

  const OfferAcceptedPopup({
    super.key,
    required this.offer,
    required this.onClose,
  });

  /// Show the popup as a dialog
  static Future<void> show(
    BuildContext context, {
    required OfferReceived offer,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfferAcceptedPopup(offer: offer, onClose: onClose),
    );
  }

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
              'Offer Accepted',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'We will review your request and schedule appointment\nsoon. It may take up to 1-3 business days for reviewing',
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
                  // Property image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: _buildOfferImage(),
                  ),
                  SizedBox(width: 12.w),

                  // Property info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.propertyTitle,
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
                          'Asking Price: ৳ ${offer.propertyPrice}',
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
                            color: offer.propertyTypeColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            offer.propertyTypeLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Offered: ${offer.offeredTime}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.grey500,
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

  Widget _buildImagePlaceholder() {
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

  Widget _buildOfferImage() {
    final image = offer.propertyImageUrl?.trim();
    if (image == null || image.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      image,
      width: 64.w,
      height: 64.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }
}
