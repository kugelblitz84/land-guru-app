import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../properties_controller.dart';
import '../widgets/metrics_conversion_row.dart';
import '../widgets/metrics_input_field.dart';

/// Popup dialog shown when user taps on an "Offered by you" card
/// Shows detailed view of the wanted post and the user's offer
class OfferedByYouPopup extends StatefulWidget {
  final LandWantedPost post;

  const OfferedByYouPopup({super.key, required this.post});

  /// Show the popup as a dialog
  static Future<void> show(BuildContext context, LandWantedPost post) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: OfferedByYouPopup(post: post),
      ),
    );
  }

  @override
  State<OfferedByYouPopup> createState() => _OfferedByYouPopupState();
}

class _OfferedByYouPopupState extends State<OfferedByYouPopup> {
  // Units for land size and plot size
  LandUnit _landSizeUnit = LandUnit.katha;
  LandUnit _plotSizeUnit = LandUnit.katha;

  // Parsed values (in the original unit - Katha)
  double _landSizeValue = 0;
  double _plotSizeValue = 0;

  // Description expansion state
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _parseValues();
  }

  /// Parse the numeric values from the post strings
  void _parseValues() {
    _landSizeValue = _parseNumericValue(widget.post.requiredLandSize);
    _plotSizeValue = _parseNumericValue(widget.post.requiredPlotSize);
  }

  double _parseNumericValue(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[Mm]in\s*'), '')
        .replaceAll(RegExp(r'[Mm]ax\s*'), '')
        .replaceAll(RegExp(r'[Kk]atha'), '')
        .replaceAll(RegExp(r'[Dd]ecimal'), '')
        .replaceAll(RegExp(r'[Aa]cre'), '')
        .replaceAll(RegExp(r'[Bb]igha'), '')
        .replaceAll(RegExp(r'[Ss]qft'), '')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatValue(double value, LandUnit unit) {
    if (value == 0) return 'Not specified';
    final converted = LandUnitConverter.convert(value, LandUnit.katha, unit);
    if (converted >= 1) {
      return 'Min ${converted.toStringAsFixed(converted.truncateToDouble() == converted ? 0 : 2)} ${unit.label}';
    }
    return 'Min ${converted.toStringAsFixed(4)} ${unit.label}';
  }

  LandWantedPost get post => widget.post;

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

                  SizedBox(height: 20.h),

                  // Posted By section
                  Text(
                    'Posted By',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildPostedBySection(),

                  SizedBox(height: 20.h),

                  // Property details
                  _buildDetailRow(
                    imageAsset: 'assets/Logos/Location.png',
                    fallbackIcon: Icons.location_on,
                    label: 'Preferred Location',
                    value: post.preferredLocation,
                    isMultiLine: true,
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/flat.png',
                    fallbackIcon: Icons.home,
                    label: 'Property Type',
                    value: post.propertyType,
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRowWithAction(
                    imageAsset: 'assets/Logos/Land&plotSize.png',
                    fallbackIcon: Icons.landscape,
                    label: 'Required Land Size',
                    value: _formatValue(_landSizeValue, _landSizeUnit),
                    actionWidget: ChangeMetricsPopup(
                      selectedUnit: _landSizeUnit,
                      onUnitChanged: (newUnit) {
                        setState(() {
                          _landSizeUnit = newUnit;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRowWithAction(
                    imageAsset: 'assets/Logos/Land&plotSize.png',
                    fallbackIcon: Icons.landscape,
                    label: 'Required Plot Size',
                    value: _formatValue(_plotSizeValue, _plotSizeUnit),
                    actionWidget: ChangeMetricsPopup(
                      selectedUnit: _plotSizeUnit,
                      onUnitChanged: (newUnit) {
                        setState(() {
                          _plotSizeUnit = newUnit;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/DistanceFromRoad.png',
                    fallbackIcon: Icons.straighten,
                    label: 'Distance from Road',
                    value: post.distanceFromRoad,
                  ),
                  SizedBox(height: 16.h),

                  _buildDetailRow(
                    imageAsset: 'assets/Logos/Budget Range.png',
                    fallbackIcon: Icons.attach_money,
                    label: 'Budget Range',
                    value: post.budgetRange,
                  ),

                  SizedBox(height: 20.h),

                  // Description section with read more
                  _buildDescriptionSection(),

                  SizedBox(height: 20.h),

                  // Your offer section
                  _buildYourOfferSection(),

                  SizedBox(height: 20.h),

                  // Status section
                  _buildStatusSection(),

                  SizedBox(height: 16.h),
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

  Widget _buildPostedBySection() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.grey300,
            backgroundImage: _buildPostedByAvatarProvider(),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.postedBy,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.white,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Posted: ${post.postedTime}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
              ),
            ],
          ),
        ],
      ),
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
    final description = post.description ?? 'No description available.';
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
            // Create a text painter to check if text overflows
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

  Widget _buildYourOfferSection() {
    if (post.offeredPropertyTitle == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your offer',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
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
                child: post.offeredPropertyImageUrl != null
                    ? Image.asset(
                        post.offeredPropertyImageUrl!,
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
                      post.offeredPropertyTitle!,
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
                          '৳ ${post.offeredPropertyPrice ?? '0'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Property type tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: post.offeredPropertyTypeColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        post.offeredPropertyTypeLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        'assets/images/Properties demo/Gazipur Water Zone.jpg',
        width: 70.w,
        height: 70.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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
        },
      ),
    );
  }

  Widget _buildStatusSection() {
    if (post.offerStatus == OfferStatus.none) {
      return const SizedBox.shrink();
    }

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
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Primary status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: post.offerStatusColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                post.offerStatusLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),

            // View Appointment button
            if (post.showViewAppointment)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Get.find<PropertiesController>().onViewAppointment(post);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'View Appointment',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

            // Pending Admin Review badge
            if (post.showPendingAdminReview)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.grey400),
                ),
                child: Text(
                  'Pending Admin Review',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  ImageProvider _buildPostedByAvatarProvider() {
    final avatar = post.postedByAvatarUrl?.trim();
    if (avatar != null && avatar.isNotEmpty) {
      final isNetwork =
          avatar.startsWith('http://') || avatar.startsWith('https://');
      if (isNetwork) {
        return NetworkImage(avatar);
      }
      return AssetImage(avatar);
    }

    return const AssetImage('assets/images/User_DP/Farhan.jpg');
  }
}
