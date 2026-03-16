import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../for_sale/property_details/widgets/property_details_widgets.dart';
import '../../widgets/metrics_conversion_row.dart';
import 'models/offered_post_models.dart';
import 'offered_posts_controller.dart';

/// Details View for an Offered Post
class OfferedPostDetailsView extends StatefulWidget {
  const OfferedPostDetailsView({super.key});

  @override
  State<OfferedPostDetailsView> createState() => _OfferedPostDetailsViewState();
}

class _OfferedPostDetailsViewState extends State<OfferedPostDetailsView> {
  late OfferedPost offeredPost;
  bool _isDescriptionExpanded = false;
  late final OfferedPostsController? _offeredPostsController;

  // Units for land size and plot size
  LandUnit _selectedLandUnit = LandUnit.katha;

  // Parsed values (in the original unit - Katha)
  double _landSizeValue = 0;
  double _plotSizeValue = 0;
  double _shareUnitValue = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    offeredPost = args['offeredPost'] as OfferedPost;
    _offeredPostsController = Get.isRegistered<OfferedPostsController>()
        ? Get.find<OfferedPostsController>()
        : null;
    _parseValues();
    _loadOfferedPostDetails();
  }

  Future<void> _loadOfferedPostDetails() async {
    final offerId = offeredPost.id.trim();
    if (offerId.isEmpty) return;

    final controller = _offeredPostsController;
    if (controller == null) {
      return;
    }

    final details = await controller.loadOfferDetailsById(offerId: offerId);
    if (!mounted || details == null) {
      return;
    }

    setState(() {
      offeredPost = details;
      _parseValues();
    });
  }

  /// Parse the numeric values from the post strings
  void _parseValues() {
    _landSizeValue = LandValueHelper.parseNumericValue(
      offeredPost.sellableLandAmount ?? '',
    );
    _plotSizeValue = LandValueHelper.parseNumericValue(
      offeredPost.plotSize ?? '',
    );
    _shareUnitValue = LandValueHelper.parseNumericValue(
      offeredPost.shareUnit ?? '',
    );
  }

  String _getConvertedValue(double kathaValue) {
    final converted = LandUnitConverter.convert(
      kathaValue,
      LandUnit.katha,
      _selectedLandUnit,
    );

    String formattedNumber;
    if (converted >= 1) {
      formattedNumber = converted.toStringAsFixed(
        converted.truncateToDouble() == converted ? 0 : 2,
      );
    } else {
      formattedNumber = converted.toStringAsFixed(4);
    }
    return '$formattedNumber ${_selectedLandUnit.label}';
  }

  Map<String, double> _getAllConversions(double kathaValue) {
    final conversions = LandUnitConverter.getAllConversions(
      kathaValue,
      LandUnit.katha,
    );
    final currentUnit = _selectedLandUnit.label;

    final conversionsMap = <String, double>{};
    conversions.forEach((unit, value) {
      if (unit.label != currentUnit) {
        conversionsMap[unit.label] = value;
      }
    });
    return conversionsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => NestedNavigationService.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.grey900, size: 24.sp),
        ),
        title: Text(
          'Offer Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Image
                  _buildPropertyImage(),
                  SizedBox(height: 10.h),

                  // Title and Price
                  _buildTitleSection(),
                  SizedBox(height: 8.h),

                  // Tags
                  _buildTagsSection(),
                  SizedBox(height: 12.h),

                  // Description
                  _buildDescriptionSection(),
                  SizedBox(height: 16.h),

                  // Sellable Land Amount
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: PropertyDetailRowWithAction(
                      imageAsset: 'assets/Logos/Land&plotSize.png',
                      label: 'Sellable Land Amount',
                      value: _getConvertedValue(_landSizeValue),
                      actionWidget: ChangeMetricsPopup(
                        selectedUnit: _selectedLandUnit,
                        onUnitChanged: (newUnit) {
                          setState(() => _selectedLandUnit = newUnit);
                        },
                      ),
                      conversions: _getAllConversions(_landSizeValue),
                      currentUnit: _selectedLandUnit.label,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Plot Size
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: PropertyDetailRowWithAction(
                      imageAsset: 'assets/Logos/Land&plotSize.png',
                      label: 'Plot Size',
                      value: _getConvertedValue(_plotSizeValue),
                      actionWidget: ChangeMetricsPopup(
                        selectedUnit: _selectedLandUnit,
                        onUnitChanged: (newUnit) {
                          setState(() => _selectedLandUnit = newUnit);
                        },
                      ),
                      conversions: _getAllConversions(_plotSizeValue),
                      currentUnit: _selectedLandUnit.label,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Share Unit (only shown if property has share unit)
                  if (offeredPost.shareUnit != null &&
                      offeredPost.shareUnit!.isNotEmpty &&
                      _shareUnitValue > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: PropertyDetailRowWithAction(
                        imageAsset: 'assets/Logos/Land&plotSize.png',
                        label: 'Share Unit',
                        value: _getConvertedValue(_shareUnitValue),
                        actionWidget: ChangeMetricsPopup(
                          selectedUnit: _selectedLandUnit,
                          onUnitChanged: (newUnit) {
                            setState(() => _selectedLandUnit = newUnit);
                          },
                        ),
                        conversions: _getAllConversions(_shareUnitValue),
                        currentUnit: _selectedLandUnit.label,
                      ),
                    ),
                  if (offeredPost.shareUnit != null &&
                      offeredPost.shareUnit!.isNotEmpty &&
                      _shareUnitValue > 0)
                    SizedBox(height: 16.h),

                  // Distance from Road
                  PropertyDetailRow(
                    imageAsset: 'assets/Logos/DistanceFromRoad.png',
                    label: 'Distance from Road',
                    value:
                        '${offeredPost.distanceFromRoadMin} - ${offeredPost.distanceFromRoadMax}',
                  ),
                  SizedBox(height: 16.h),

                  // Location
                  PropertyDetailRow(
                    imageAsset: 'assets/Logos/Location.png',
                    label: 'Location',
                    value: offeredPost.location ?? 'N/A',
                  ),
                  SizedBox(height: 16.h),

                  // Property Photos
                  if (offeredPost.propertyPhotos != null &&
                      offeredPost.propertyPhotos!.isNotEmpty)
                    PropertyPhotosSection(photos: offeredPost.propertyPhotos!),
                  SizedBox(height: 12.h),

                  // Offered To section (Buyer info)
                  _buildOfferedToSection(),

                  SizedBox(height: 16.h),

                  // Bottom action button (inside scroll)
                  _buildBottomAction(),

                  SizedBox(height: 24.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: _buildPrimaryImage(),
      ),
    );
  }

  Widget _buildPrimaryImage() {
    final image = offeredPost.propertyImageUrl?.trim();
    if (image == null || image.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/images/Properties demo/Luxury 3 Bed Apartment.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.primary.withAlpha(50),
          child: Center(
            child: Icon(
              Icons.image,
              size: 60.sp,
              color: AppColors.primary.withAlpha(100),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offeredPost.propertyTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '৳ ${offeredPost.propertyPrice}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            offeredPost.postId,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          _buildTag(
            offeredPost.propertyTypeLabel,
            offeredPost.propertyTypeColor,
          ),
          _buildTag('Offer Post', AppColors.primary),
          if (offeredPost.status == OfferedPostStatus.buyerAccepted)
            _buildTag('Buyer accepted your offer', AppColors.success)
          else
            _buildStatusTag(
              'Pending Buyer Review',
              AppColors.grey200,
              AppColors.grey600,
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final description = offeredPost.description ?? 'No description available.';
    final shouldTruncate = description.length > 150;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
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
          Text(
            _isDescriptionExpanded || !shouldTruncate
                ? description
                : '${description.substring(0, 150)}...',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.grey700,
              height: 1.5,
            ),
          ),
          if (shouldTruncate)
            GestureDetector(
              onTap: () => setState(
                () => _isDescriptionExpanded = !_isDescriptionExpanded,
              ),
              child: Text(
                _isDescriptionExpanded ? 'Show Less' : 'Read More',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfferedToSection() {
    final buyerName = offeredPost.buyerName.trim().isNotEmpty
        ? offeredPost.buyerName.trim()
        : 'Unknown Buyer';
    final timestamp = offeredPost.timestamp.trim();
    final timestampPrefix = offeredPost.timestampPrefix.trim();
    final hasTimestamp = timestamp.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offered To',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(50.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(40),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildBuyerAvatar(),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyerName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (offeredPost.buyerVerified)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 10.sp,
                                color: AppColors.white,
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
                        hasTimestamp
                            ? '${timestampPrefix.isNotEmpty ? '$timestampPrefix ' : ''}$timestamp'
                            : 'Time not available',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerAvatar() {
    final image = offeredPost.buyerImageUrl?.trim();
    final avatarSize = 60.r;

    if (image == null || image.isEmpty) {
      return _buildBuyerAvatarFallback(avatarSize);
    }

    return ClipOval(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildBuyerAvatarFallback(avatarSize),
        ),
      ),
    );
  }

  Widget _buildBuyerAvatarFallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: AppColors.grey500, size: 28.sp),
    );
  }

  Widget _buildBottomAction() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                _getButtonText(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _getHelpText(),
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (offeredPost.status == OfferedPostStatus.buyerAccepted) {
      return 'Complete this post';
    }
    return 'Make this a sell post instead';
  }

  VoidCallback? _getButtonAction() {
    if (offeredPost.status == OfferedPostStatus.buyerAccepted) {
      return _completePost;
    }
    return _makeSellPost;
  }

  String _getHelpText() {
    if (offeredPost.status == OfferedPostStatus.buyerAccepted) {
      return "Unless you complete this post, we won't be able to fix appointment";
    }
    return 'You can now make changes to this post';
  }

  void _completePost() {
    Get.snackbar(
      'Complete Post',
      'Navigating to complete post flow...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _makeSellPost() {
    _convertAndNavigateToSellPost();
  }

  Future<void> _convertAndNavigateToSellPost() async {
    final controller = Get.isRegistered<OfferedPostsController>()
        ? Get.find<OfferedPostsController>()
        : Get.put(OfferedPostsController());

    final converted = await controller.convertOfferToSellPost(offeredPost);
    if (!converted) {
      return;
    }

    if (!mounted) {
      return;
    }

    Get.snackbar(
      'Success',
      'Offer converted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.toNamed(
      AppRoutes.CREATE_SELL_POST_INFO,
      arguments: {'fromOfferedPost': true, 'offeredPost': offeredPost},
    );
  }
}
