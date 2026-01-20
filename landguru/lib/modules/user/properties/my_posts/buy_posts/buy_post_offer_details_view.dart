import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/services/nested_navigation_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../property_details/widgets/property_details_widgets.dart';
import '../../widgets/metrics_conversion_row.dart';
import 'models/buy_post_models.dart';
import 'widgets/offer_accepted_popup.dart';

/// Offer Details View - Shows details of a property offer received on a buy post
class BuyPostOfferDetailsView extends StatefulWidget {
  const BuyPostOfferDetailsView({super.key});

  @override
  State<BuyPostOfferDetailsView> createState() =>
      _BuyPostOfferDetailsViewState();
}

class _BuyPostOfferDetailsViewState extends State<BuyPostOfferDetailsView> {
  late BuyPost buyPost;
  late OfferReceived offer;
  bool _isDescriptionExpanded = false;

  // Units for land size and plot size
  LandUnit _selectedLandUnit = LandUnit.katha;

  // Parsed values (in the original unit - Katha)
  double _landSizeValue = 0;
  double _plotSizeValue = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    buyPost = args['buyPost'] as BuyPost;
    offer = args['offer'] as OfferReceived;
    _parseValues();
  }

  /// Parse the numeric values from the offer strings
  void _parseValues() {
    _landSizeValue = LandValueHelper.parseNumericValue(
      offer.sellableLandAmount ?? '',
    );
    _plotSizeValue = LandValueHelper.parseNumericValue(offer.plotSize ?? '');
  }

  String _getConvertedValue(double kathaValue) {
    final sqft = LandUnitConverter.toSqft(kathaValue, LandUnit.katha);
    final converted = LandUnitConverter.fromSqft(sqft, _selectedLandUnit);

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
    final sqft = LandUnitConverter.toSqft(kathaValue, LandUnit.katha);
    final conversions = LandUnitConverter.getAllConversions(
      sqft,
      LandUnit.sqft,
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

                  // Distance from Road
                  PropertyDetailRow(
                    imageAsset: 'assets/Logos/DistanceFromRoad.png',
                    label: 'Distance from Road',
                    value: offer.distanceFromRoad ?? 'Not specified',
                  ),
                  SizedBox(height: 16.h),

                  // Location
                  PropertyDetailRow(
                    imageAsset: 'assets/Logos/Location.png',
                    label: 'Location',
                    value: offer.location ?? 'Not specified',
                  ),
                  SizedBox(height: 16.h),

                  // Property Photos
                  if (offer.propertyPhotos != null &&
                      offer.propertyPhotos!.isNotEmpty)
                    PropertyPhotosSection(photos: offer.propertyPhotos!),
                  SizedBox(height: 12.h),

                  // How Offering Works section
                  const HowToBuySection(),
                  SizedBox(height: 12.h),

                  // Offered By section
                  _buildOfferedBySection(),

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
        child: offer.propertyImageUrl != null
            ? Image.asset(
                offer.propertyImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
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
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.propertyTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '৳ ${offer.propertyPrice}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            offer.postId ?? '',
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
          _buildTag(offer.propertyTypeLabel, offer.propertyTypeColor),
          _buildTag('Offer Post', AppColors.primary),
          if (offer.status == OfferReceivedStatus.accepted ||
              offer.status == OfferReceivedStatus.pendingAdminReview)
            _buildTag('Buyer accepted your offer', AppColors.success)
          else if (offer.status == OfferReceivedStatus.pendingAdminReview)
            _buildStatusTag(
              'Pending Buyer Review',
              AppColors.grey200,
              AppColors.grey700,
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
    final description = offer.description ?? 'No description available.';
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

  Widget _buildOfferedBySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.status == OfferReceivedStatus.accepted ||
                    offer.status == OfferReceivedStatus.pendingAdminReview
                ? 'Offered To'
                : 'Offered By',
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
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.grey200,
                  backgroundImage: offer.sellerImageUrl != null
                      ? AssetImage(offer.sellerImageUrl!)
                      : null,
                  child: offer.sellerImageUrl == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.grey500,
                          size: 28.sp,
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.sellerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (offer.sellerVerified)
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
                      'Offered: ${offer.offeredTime}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    String buttonText;
    VoidCallback onPressed;

    if (offer.status == OfferReceivedStatus.pending) {
      buttonText = 'Accept Offer';
      onPressed = () => _acceptOffer();
    } else if (offer.status == OfferReceivedStatus.accepted ||
        offer.status == OfferReceivedStatus.pendingAdminReview) {
      buttonText = 'Complete this post';
      onPressed = () => _completePost();
    } else {
      buttonText = 'Make this a sell post instead';
      onPressed = () => _makeAsSellPost();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
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
                buttonText,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (offer.status == OfferReceivedStatus.pendingAdminReview) ...[
            SizedBox(height: 8.h),
            Text(
              'Unless you complete this post, we won\'t be able to fix appointment',
              style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ],
          if (offer.status != OfferReceivedStatus.pending &&
              offer.status != OfferReceivedStatus.pendingAdminReview) ...[
            SizedBox(height: 8.h),
            Text(
              'You can make changes after 3 days, at 12:00pm, 13 Jan 2026',
              style: TextStyle(fontSize: 11.sp, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _acceptOffer() {
    OfferAcceptedPopup.show(
      context,
      offer: offer,
      onClose: () {
        NestedNavigationService.back();
        NestedNavigationService.back();
      },
    );
  }

  void _completePost() {
    Get.snackbar(
      'Complete Post',
      'Navigate to complete post flow',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _makeAsSellPost() {
    Get.snackbar(
      'Make Sell Post',
      'Navigate to create sell post from this offer',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
