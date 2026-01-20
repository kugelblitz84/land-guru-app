import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../widgets/metrics_conversion_row.dart';
import '../buy_posts_controller.dart';
import '../models/buy_post_models.dart';

/// Popup dialog shown when user taps on a buy post with offers
/// Shows detailed view of the buy post and list of offers received
class BuyPostOffersPopup extends StatefulWidget {
  final BuyPostsController controller;
  final BuyPost post;

  const BuyPostOffersPopup({
    super.key,
    required this.controller,
    required this.post,
  });

  /// Show the popup as a dialog
  static Future<void> show(
    BuildContext context,
    BuyPostsController controller,
    BuyPost post,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: BuyPostOffersPopup(controller: controller, post: post),
      ),
    );
  }

  @override
  State<BuyPostOffersPopup> createState() => _BuyPostOffersPopupState();
}

class _BuyPostOffersPopupState extends State<BuyPostOffersPopup> {
  bool _isDescriptionExpanded = false;

  // Units for land size and plot size
  LandUnit _landSizeUnit = LandUnit.katha;
  LandUnit _plotSizeUnit = LandUnit.katha;

  // Parsed values (in the original unit - Katha)
  double _landSizeValue = 0;
  double _plotSizeValue = 0;

  BuyPost get post => widget.post;

  @override
  void initState() {
    super.initState();
    _parseValues();
  }

  /// Parse the numeric values from the post strings
  void _parseValues() {
    _landSizeValue = LandValueHelper.parseNumericValue(post.requiredLandSize);
    _plotSizeValue = LandValueHelper.parseNumericValue(post.requiredPlotSize);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and close button
                  _buildHeader(),

                  SizedBox(height: 16.h),

                  // Property details
                  _buildDetailRow(
                    imageAsset: 'assets/Logos/Location.png',
                    fallbackIcon: Icons.location_on,
                    label: 'Preferred Location',
                    value: post.preferredLocation,
                    isMultiLine: true,
                  ),
                  SizedBox(height: 12.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/flat.png',
                    fallbackIcon: Icons.home,
                    label: 'Property Type',
                    value: post.propertyTypeLabel,
                  ),
                  SizedBox(height: 12.h),

                  _buildDetailRowWithAction(
                    imageAsset: 'assets/Logos/Land&plotSize.png',
                    fallbackIcon: Icons.landscape,
                    label: 'Required Land Size',
                    value: LandValueHelper.formatValue(
                      _landSizeValue,
                      _landSizeUnit,
                      prefix: 'Min',
                    ),
                    actionWidget: ChangeMetricsPopup(
                      selectedUnit: _landSizeUnit,
                      onUnitChanged: (newUnit) {
                        setState(() {
                          _landSizeUnit = newUnit;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildDetailRowWithAction(
                    imageAsset: 'assets/Logos/Land&plotSize.png',
                    fallbackIcon: Icons.landscape,
                    label: 'Required Plot Size',
                    value: LandValueHelper.formatValue(
                      _plotSizeValue,
                      _plotSizeUnit,
                      prefix: 'Min',
                    ),
                    actionWidget: ChangeMetricsPopup(
                      selectedUnit: _plotSizeUnit,
                      onUnitChanged: (newUnit) {
                        setState(() {
                          _plotSizeUnit = newUnit;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/DistanceFromRoad.png',
                    fallbackIcon: Icons.straighten,
                    label: 'Distance from Road',
                    value: post.distanceFromRoad,
                  ),
                  SizedBox(height: 12.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/Budget Range.png',
                    fallbackIcon: Icons.attach_money,
                    label: 'Budget Range',
                    value: post.budgetRange,
                  ),

                  SizedBox(height: 16.h),

                  // Description section
                  if (post.description != null) ...[
                    _buildDescriptionSection(),
                    SizedBox(height: 16.h),
                  ],

                  // Offers Received section
                  _buildOffersReceivedSection(),

                  SizedBox(height: 16.h),

                  // Status section
                  _buildStatusSection(),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                post.postId,
                style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
              ),
              Text(
                '${post.timestampPrefix} ${post.timestamp}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.close, color: AppColors.grey600, size: 24.sp),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    String? imageAsset,
    IconData? fallbackIcon,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                fallbackIcon ?? Icons.info,
                size: 20.sp,
                color: AppColors.primary,
              );
            },
          )
        else
          Icon(
            fallbackIcon ?? Icons.info,
            size: 20.sp,
            color: AppColors.primary,
          ),
        SizedBox(width: 12.w),
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
                maxLines: isMultiLine ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithAction({
    required String label,
    required String value,
    required Widget actionWidget,
    String? imageAsset,
    IconData? fallbackIcon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset,
            width: 20.w,
            height: 20.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                fallbackIcon ?? Icons.info,
                size: 20.sp,
                color: AppColors.primary,
              );
            },
          )
        else
          Icon(
            fallbackIcon ?? Icons.info,
            size: 20.sp,
            color: AppColors.primary,
          ),
        SizedBox(width: 12.w),
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
        actionWidget,
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final description = post.description ?? '';
    final maxLines = _isDescriptionExpanded ? 100 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final textSpan = TextSpan(
              text: description,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.grey600,
                height: 1.5,
              ),
            );
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: 2,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final isOverflowing = textPainter.didExceedMaxLines;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOverflowing) ...[
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      _isDescriptionExpanded ? 'Show less' : 'Read more',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOffersReceivedSection() {
    if (post.offersReceived.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offers Received',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 12.h),
        ...post.offersReceived.map((offer) => _buildOfferCard(offer)),
      ],
    );
  }

  Widget _buildOfferCard(OfferReceived offer) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        widget.controller.goToOfferDetails(post, offer);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: offer.propertyImageUrl != null
                  ? Image.asset(
                      offer.propertyImageUrl!,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property title
                  Text(
                    offer.propertyTitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Asking price
                  Row(
                    children: [
                      Text(
                        'Asking Price: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        '৳ ${offer.propertyPrice}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Property type tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: offer.propertyTypeColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      offer.propertyTypeLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Offered time
                  Text(
                    'Offered: ${offer.offeredTime}',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.image,
        size: 30.sp,
        color: AppColors.primary.withAlpha(100),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: post.statusColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                post.statusLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),

            // Offers count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: post.hasOffers
                    ? AppColors.error.withAlpha(20)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: post.hasOffers ? AppColors.error : AppColors.grey300,
                ),
              ),
              child: Text(
                '${post.offersCount} Offers Received',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: post.hasOffers ? AppColors.error : AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
