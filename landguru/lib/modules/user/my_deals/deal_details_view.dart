import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/enums/property_type.dart';
import '../../../core/services/nested_navigation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../properties/widgets/metrics_conversion_row.dart';
import '../properties/for_sale/property_details/widgets/property_details_widgets.dart';
import 'models/deal_models.dart';
import 'resell_property/resell_property.dart';

/// Unified Deal Details view - handles both Sold and Bought properties
/// For Bought properties, includes "Resell this property" functionality
class DealDetailsView extends StatefulWidget {
  const DealDetailsView({super.key});

  @override
  State<DealDetailsView> createState() => _DealDetailsViewState();
}

class _DealDetailsViewState extends State<DealDetailsView> {
  late Deal deal;
  bool _isDescriptionExpanded = false;

  // Metrics units
  LandUnit _selectedLandUnit = LandUnit.katha;

  // Expandable sections state
  final Map<int, bool> _expandedFeatures = {};

  // Demo data for unlocked features
  final List<String> _dueDiligenceItems = [
    'Title deed verification completed',
    'Encumbrance certificate verified',
    'Property tax records checked',
    'No pending litigation confirmed',
    'Boundary verification done',
  ];

  final List<_OwnerHistory> _ownershipHistory = [
    _OwnerHistory(
      name: 'Abdul Rahman',
      period: '2020 - Present',
      isCurrent: true,
    ),
    _OwnerHistory(
      name: 'Mohammad Ali',
      period: '2015 - 2020',
      isCurrent: false,
    ),
    _OwnerHistory(name: 'Karim Uddin', period: '2010 - 2015', isCurrent: false),
  ];

  final List<String> _legalDocuments = [
    'Original Sale Deed',
    'Mutation Certificate',
    'Tax Payment Receipts',
    'Encumbrance Certificate',
    'NOC from Society',
  ];

  final List<_ServiceVerification> _serviceVerifications = [
    _ServiceVerification(
      serviceName: 'Ownership History Validation',
      assignedAgent: 'Farhan Ahmed',
      agentRole: 'Senior Agent',
      isVerified: true,
    ),
    _ServiceVerification(
      serviceName: 'Deed Writing Service',
      assignedAgent: 'Adv. Rahman',
      agentRole: 'Legal Advisor',
      isVerified: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    deal = args?['deal'] as Deal? ?? _createDemoDeal();
  }

  Deal _createDemoDeal() {
    return Deal(
      id: 'demo',
      postId: '#POST-1042',
      propertyTitle: 'Modern Duplex Villa',
      propertyImageUrl:
          'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
      propertyType: PropertyType.flat,
      location:
          'Block-C, Banani, Banani Thana, Dhaka North City Corporation, Dhaka-1213, Dhaka, Bangladesh.',
      soldPrice: '40,00,000',
      status: DealStatus.bought,
      dealDate: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          'A stunning newly renovated villa featuring an open-concept '
          "living area, chef's kitchen with top-tier appliances, and a "
          'private backyards oasis. The property offers modern amenities '
          'and a serene environment perfect for family living.',
      soldLandAmount: '15 Katha',
      plotSize: '15 Katha',
      distanceFromRoad: '200m-750m',
      propertyPhotos: [
        'assets/images/Properties Listing - For Sale Images/modern duplex villa.jpg',
        'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
        'assets/images/Properties demo/Gazipur Water Zone.jpg',
      ],
      otherPartyId: 'seller_1',
      otherPartyName: 'Farhan',
      otherPartyVerified: true,
      hasHideDueDiligence: true,
      hasPropertyVideo: true,
      hasOwnershipHistory: true,
    );
  }

  bool get _isBoughtDeal => deal.status == DealStatus.bought;

  bool _isFeatureExpanded(int index) => _expandedFeatures[index] ?? false;

  void _toggleFeatureExpansion(int index) {
    setState(() {
      _expandedFeatures[index] = !(_expandedFeatures[index] ?? false);
    });
  }

  String _getFormattedDealDate() {
    final now = DateTime.now();
    final diff = now.difference(deal.dealDate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${deal.dealDate.day}/${deal.dealDate.month}/${deal.dealDate.year}';
    }
  }

  double _getLandValueInKatha(String? value) {
    if (value == null) return 0;
    final cleaned = value
        .replaceAll(RegExp(r'[Kk]atha'), '')
        .replaceAll(RegExp(r'[Dd]ecimal'), '')
        .replaceAll(RegExp(r'[Aa]cre'), '')
        .replaceAll(RegExp(r'[Bb]igha'), '')
        .replaceAll(RegExp(r'[Ss]qft'), '')
        .trim();
    return double.tryParse(cleaned) ?? 0;
  }

  String _getConvertedLandAmount(double kathaValue) {
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

  Map<LandUnit, double> _getAllConversions(double kathaValue) {
    return LandUnitConverter.getAllConversions(kathaValue, LandUnit.katha);
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
          'Property Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            _buildPropertyImage(),
            SizedBox(height: 10.h),

            // Title and Tags
            _buildTitleSection(),
            SizedBox(height: 8.h),
            _buildTagsSection(),
            SizedBox(height: 12.h),

            // Final Deal Amount
            _buildFinalDealAmountSection(),
            SizedBox(height: 12.h),

            // Sold To / Bought From
            _buildOtherPartySection(),
            SizedBox(height: 12.h),

            // Description
            PropertyDescriptionSection(
              description: deal.description ?? 'No description available.',
              isExpanded: _isDescriptionExpanded,
              onToggle: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Location
            PropertyDetailRow(
              imageAsset: 'assets/Logos/Location.png',
              label: 'Location',
              value: deal.location,
            ),
            SizedBox(height: 16.h),

            // Land Amount & Plot Size
            _buildLandAmountRow(
              label: _isBoughtDeal ? 'Bought Land Amount' : 'Sold Land Amount',
              value: deal.soldLandAmount,
            ),
            SizedBox(height: 16.h),
            _buildLandAmountRow(label: 'Plot Size', value: deal.plotSize),
            SizedBox(height: 16.h),

            // Distance from Road
            PropertyDetailRow(
              imageAsset: 'assets/Logos/DistanceFromRoad.png',
              label: 'Distance from Road',
              value: deal.distanceFromRoad ?? 'Not specified',
            ),
            SizedBox(height: 16.h),

            // Land Shape
            const LandShapeSection(),
            SizedBox(height: 12.h),

            // Property Photos
            if (deal.propertyPhotos != null && deal.propertyPhotos!.isNotEmpty)
              PropertyPhotosSection(photos: deal.propertyPhotos!),
            SizedBox(height: 12.h),

            // Unlocked Features Section (with blue background)
            Container(
              color: AppColors.propertyDetailsBackground,
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _buildUnlockedFeaturesSection(),
                  SizedBox(height: 12.h),
                ],
              ),
            ),

            // Resell button for Bought properties
            if (_isBoughtDeal) ...[
              SizedBox(height: 16.h),
              _buildResellButton(),
              SizedBox(height: 24.h),
            ],
          ],
        ),
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
        child: deal.propertyImageUrl != null
            ? Image.asset(
                deal.propertyImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/images/Properties demo/5 katha Plot in Purbacahl.jpg',
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
            deal.propertyTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          Text(
            deal.postId,
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
          _buildTag(deal.propertyTypeLabel, deal.propertyTypeColor),
          _buildTag('Sell Post', AppColors.primary),
          _buildTag(
            _isBoughtDeal ? 'Bought' : 'Sold',
            AppColors.success,
            icon: Icons.check_circle,
          ),
          _buildTag('Unlocked', AppColors.success, icon: Icons.lock_open),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: AppColors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalDealAmountSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _isBoughtDeal
              ? AppColors.primaryLight.withAlpha(80)
              : AppColors.success.withAlpha(20),
          borderRadius: BorderRadius.circular(12.r),
          border: _isBoughtDeal
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(color: AppColors.success, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              'FINAL DEAL AMOUNT',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '৳ ${deal.soldPrice}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: _isBoughtDeal ? AppColors.primary : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherPartySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.otherPartyLabel,
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
                  backgroundImage: const AssetImage(
                    'assets/images/User_DP/Farhan.jpg',
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.otherPartyName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (deal.otherPartyVerified)
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
                      'Posted: ${_getFormattedDealDate()}',
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

  Widget _buildLandAmountRow({required String label, String? value}) {
    final kathaValue = _getLandValueInKatha(value);
    final convertedValue = _getConvertedLandAmount(kathaValue);
    final conversions = _getAllConversions(kathaValue);
    final currentUnit = _selectedLandUnit.label;

    final conversionsMap = <String, double>{};
    conversions.forEach((unit, val) {
      if (unit.label != currentUnit) {
        conversionsMap[unit.label] = val;
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: PropertyDetailRowWithAction(
        imageAsset: 'assets/Logos/Land&plotSize.png',
        label: label,
        value: convertedValue,
        actionWidget: ChangeMetricsPopup(
          selectedUnit: _selectedLandUnit,
          onUnitChanged: (unit) {
            setState(() => _selectedLandUnit = unit);
          },
        ),
        conversions: conversionsMap,
        currentUnit: currentUnit,
      ),
    );
  }

  Widget _buildResellButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showResellPopup,
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
                'Resell this property',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You can now make this as a sell post!',
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showResellPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResellPropertyPopup(
        deal: deal,
        landUnit: _selectedLandUnit,
        onSuccess: () {
          Navigator.of(context).pop();
          _showResellSuccessPopup();
        },
      ),
    );
  }

  void _showResellSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResellSuccessPopup(
        deal: deal,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildUnlockedFeaturesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.lock_open, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Unlocked Features',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Feature items
          _buildExpandableFeature(
            index: 0,
            title: 'Risk & Due Diligence Checklist',
            subtitle: 'Get further verification about this property',
            icon: Icons.checklist_rounded,
            iconColor: AppColors.primary,
            expandedContent: _buildDueDiligenceContent(),
          ),
          _buildExpandableFeature(
            index: 1,
            title: 'Property Video',
            subtitle: 'Get a video tour of the property before buying',
            icon: Icons.videocam_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildVideoContent(),
          ),
          _buildExpandableFeature(
            index: 2,
            title: 'Ownership History',
            subtitle: 'Get to know the connected owners history',
            icon: Icons.history,
            iconColor: AppColors.grey600,
            expandedContent: _buildOwnershipHistoryContent(),
          ),
          _buildExpandableFeature(
            index: 3,
            title: 'Validated Legal Documents',
            subtitle: 'Get to see which documents will be provided',
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildLegalDocumentsContent(),
          ),
          _buildExpandableFeature(
            index: 4,
            title: 'Pentagraph Map',
            subtitle: 'Detailed Mouza map of the area',
            icon: Icons.map_outlined,
            iconColor: AppColors.primary,
            expandedContent: _buildPentagraphMapContent(),
          ),
          _buildExpandableFeature(
            index: 5,
            title: 'Services Taken',
            subtitle: 'Get to see which services was taken by the user',
            icon: Icons.miscellaneous_services_outlined,
            iconColor: AppColors.warning,
            expandedContent: _buildServicesTakenContent(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFeature({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget expandedContent,
    bool isLast = false,
  }) {
    final isExpanded = _isFeatureExpanded(index);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLight.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(20),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _toggleFeatureExpansion(index),
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.grey600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
              child: expandedContent,
            ),
        ],
      ),
    );
  }

  Widget _buildDueDiligenceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ..._dueDiligenceItems.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.success,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.grey700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 8.h),
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: Center(
            child: Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 40.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ..._ownershipHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final owner = entry.value;
          final isLast = index == _ownershipHistory.length - 1;
          final isFirst = index == 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.primary.withAlpha(20)
                          : AppColors.grey100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFirst ? AppColors.primary : AppColors.grey300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: isFirst ? AppColors.primary : AppColors.grey400,
                      size: 18.sp,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40.h, color: AppColors.grey300),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.white : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isFirst
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey900,
                            ),
                          ),
                          if (owner.period.isNotEmpty)
                            Text(
                              owner.period,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isFirst
                                    ? AppColors.primary
                                    : AppColors.grey500,
                              ),
                            ),
                        ],
                      ),
                      if (owner.isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegalDocumentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ..._legalDocuments.map(
          (doc) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    doc,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Documents will be handed over after successful purchase',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.grey500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPentagraphMapContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: Image.asset(
              'assets/images/Maps/PentaGraphMap.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 48.sp,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Pentagraph Map',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Agent images for services
  static const List<String> _agentImages = [
    'assets/images/User_DP/abrar.jpg',
    'assets/images/User_DP/Farhan.jpg',
    'assets/images/User_DP/forhad.jpg',
    'assets/images/User_DP/jahangir.jpg',
    'assets/images/User_DP/rahman.jpg',
    'assets/images/User_DP/sahil.jpg',
  ];

  Widget _buildServicesTakenContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.grey200),
        SizedBox(height: 12.h),
        ..._serviceVerifications.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          final isLast = index == _serviceVerifications.length - 1;
          final agentImage = _agentImages[index % _agentImages.length];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 100.h,
                      color: AppColors.grey300,
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.serviceName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          if (service.isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(20),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'ASSIGNED AGENT',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: AppColors.grey200,
                            backgroundImage: AssetImage(agentImage),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.assignedAgent,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey900,
                                ),
                              ),
                              if (service.agentRole.isNotEmpty)
                                Text(
                                  service.agentRole,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.grey500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// Helper classes for demo data
class _OwnerHistory {
  final String name;
  final String period;
  final bool isCurrent;

  _OwnerHistory({
    required this.name,
    required this.period,
    required this.isCurrent,
  });
}

class _ServiceVerification {
  final String serviceName;
  final String assignedAgent;
  final String agentRole;
  final bool isVerified;

  _ServiceVerification({
    required this.serviceName,
    required this.assignedAgent,
    required this.agentRole,
    required this.isVerified,
  });
}
