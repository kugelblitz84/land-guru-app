import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../properties_controller.dart';
import '../widgets/metrics_conversion_row.dart';
import '../widgets/metrics_input_field.dart';

class LandWantedOfferPopup extends StatefulWidget {
  final LandWantedPost post;

  const LandWantedOfferPopup({super.key, required this.post});

  static Future<void> show(BuildContext context, LandWantedPost post) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: LandWantedOfferPopup(post: post),
      ),
    );
  }

  @override
  State<LandWantedOfferPopup> createState() => _LandWantedOfferPopupState();
}

class _LandWantedOfferPopupState extends State<LandWantedOfferPopup> {
  LandUnit _landSizeUnit = LandUnit.katha;
  LandUnit _plotSizeUnit = LandUnit.katha;
  double _landSizeValue = 0;
  double _plotSizeValue = 0;

  @override
  void initState() {
    super.initState();
    _parseValues();
  }

  void _parseValues() {
    // Parse "Min 5 Katha" → 5.0
    _landSizeValue = _parseNumericValue(widget.post.requiredLandSize);
    _plotSizeValue = _parseNumericValue(widget.post.requiredPlotSize);
  }

  double _parseNumericValue(String value) {
    // Remove common prefixes and suffixes, extract number
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

  /// Format value for display
  String _formatValue(double value, LandUnit unit) {
    if (value == 0) return 'Not specified';
    final converted = LandUnitConverter.fromSqft(
      LandUnitConverter.toSqft(value, LandUnit.katha), // Original is in Katha
      unit,
    );
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
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Row(
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
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: AppColors.grey600,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

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

                  // Description section
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Client is looking for a ready flat in Dhanmondi area. Must have parking and be above 2nd floor.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grey600,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Action buttons
                  _buildActionButtons(context),

                  SizedBox(height: 12.h),

                  // Terms and conditions
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey600,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By offering, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms & Condition',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // How offering works section
                  _buildHowOfferingWorks(),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
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
          // Avatar
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.grey300,
            child: Icon(Icons.person, color: AppColors.grey600, size: 28.sp),
          ),
          SizedBox(width: 12.w),
          // Name and details
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
        // Icon
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
        // Label and value
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
        // Icon
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
        // Label and value
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
        // Action widget (e.g., ChangeMetricsPopup)
        actionWidget,
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Offer from existing posts button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.toNamed(
                AppRoutes.OFFER_FROM_EXISTING_LIST,
                arguments: {'postId': post.id, 'postTitle': post.title},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Offer from your existing Posts',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Create new sell post and offer button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.toNamed(
                AppRoutes.CREATE_OFFER_INFO,
                arguments: {'postId': post.id, 'postTitle': post.title},
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Create new sell post and offer',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowOfferingWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How offering works ?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOfferingStep(
              imageAsset: 'assets/Logos/How Offering Work/You send offer.png',
              fallbackIcon: Icons.send,
              label: 'You send offer',
            ),
            _buildArrow(),
            _buildOfferingStep(
              imageAsset:
                  'assets/Logos/How Offering Work/Buyers review and accepts.png',
              fallbackIcon: Icons.person_search,
              label: 'Buyer reviews\nand accepts',
            ),
            _buildArrow(),
            _buildOfferingStep(
              imageAsset:
                  'assets/Logos/How Offering Work/We schedule appointment.png',
              fallbackIcon: Icons.calendar_today,
              label: 'We schedule\nappointment',
            ),
            _buildArrow(),
            _buildOfferingStep(
              imageAsset:
                  'assets/Logos/How Offering Work/Meet with the buyer.png',
              fallbackIcon: Icons.people,
              label: 'Meet with\nthe buyer',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfferingStep({
    required String label,
    String? imageAsset,
    IconData? fallbackIcon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset,
                      width: 22.w,
                      height: 22.h,
                      color: AppColors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          fallbackIcon ?? Icons.info,
                          color: AppColors.white,
                          size: 22.sp,
                        );
                      },
                    )
                  : Icon(
                      fallbackIcon ?? Icons.info,
                      color: AppColors.white,
                      size: 22.sp,
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Icon(Icons.arrow_forward, size: 16.sp, color: AppColors.grey400),
    );
  }
}
