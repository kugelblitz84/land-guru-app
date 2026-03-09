import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../properties/widgets/metrics_conversion_row.dart';
import '../models/deal_models.dart';

/// Resell property popup with options to update price or keep as is
class ResellPropertyPopup extends StatefulWidget {
  final Deal deal;
  final LandUnit landUnit;
  final VoidCallback onSuccess;

  const ResellPropertyPopup({
    super.key,
    required this.deal,
    required this.landUnit,
    required this.onSuccess,
  });

  @override
  State<ResellPropertyPopup> createState() => _ResellPropertyPopupState();
}

class _ResellPropertyPopupState extends State<ResellPropertyPopup> {
  // 0 = option selection, 1 = update price form
  int _currentStep = 0;

  // Option: true = update price, false = keep as is
  bool _updatePrice = true;

  // Price update fields
  late TextEditingController _landSizeController;
  late TextEditingController _pricePerKathaController;
  LandUnit _selectedUnit = LandUnit.katha;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final landValue = _extractLandValue(widget.deal.soldLandAmount);
    _landSizeController = TextEditingController(text: landValue.toString());
    _pricePerKathaController = TextEditingController(text: '800000');
    _selectedUnit = widget.landUnit;
  }

  @override
  void dispose() {
    _landSizeController.dispose();
    _pricePerKathaController.dispose();
    super.dispose();
  }

  double _extractLandValue(String? value) {
    if (value == null) return 5.0;
    final cleaned = value
        .replaceAll(RegExp(r'[Kk]atha'), '')
        .replaceAll(RegExp(r'[Dd]ecimal'), '')
        .replaceAll(RegExp(r'[Aa]cre'), '')
        .replaceAll(RegExp(r'[Bb]igha'), '')
        .replaceAll(RegExp(r'[Ss]qft'), '')
        .trim();
    return double.tryParse(cleaned) ?? 5.0;
  }

  String _calculateAskingPrice() {
    final landSize = double.tryParse(_landSizeController.text) ?? 0;
    final pricePerKatha = double.tryParse(_pricePerKathaController.text) ?? 0;
    final total = landSize * pricePerKatha;
    return _formatPrice(total);
  }

  String _formatPrice(double price) {
    return CurrencyFormatter.format(price);
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: _currentStep == 0
            ? _buildOptionSelectionStep()
            : _buildPriceUpdateStep(),
      ),
    );
  }

  Widget _buildOptionSelectionStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resell this property',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close, color: AppColors.grey600, size: 24.sp),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        Text(
          'Choose a option',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        SizedBox(height: 12.h),

        // Option 1: Update Price
        _buildOptionTile(
          title: 'Update Price',
          subtitle: 'Configure the price of the property',
          isSelected: _updatePrice,
          onTap: () => setState(() => _updatePrice = true),
        ),
        SizedBox(height: 12.h),

        // Option 2: Keep as it is
        _buildOptionTile(
          title: 'Keep as it is',
          subtitle: 'List the post without updating the price',
          isSelected: !_updatePrice,
          onTap: () => setState(() => _updatePrice = false),
        ),
        SizedBox(height: 24.h),

        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_updatePrice) {
                      setState(() => _currentStep = 1);
                    } else {
                      _handleSubmit();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _updatePrice ? 'Next' : 'List as a Sell Post',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_updatePrice) ...[
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward, size: 20.sp),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withAlpha(50)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
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
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceUpdateStep() {
    final askingPrice = _calculateAskingPrice();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentStep = 0),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.grey900,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Resell this property',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: AppColors.grey600, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Update Price option indicator
          _buildOptionTile(
            title: 'Update Price',
            subtitle: 'Configure the price of the property',
            isSelected: true,
            onTap: () {},
          ),
          SizedBox(height: 20.h),

          // Land Size field (read-only)
          _buildLabel('Land Size', isRequired: false),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _landSizeController,
                  keyboardType: TextInputType.number,
                  enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedUnit.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.grey400),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Price Per Katha field
          Row(
            children: [
              Text(
                'Price Per ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                ),
              ),
              Text(
                _selectedUnit.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _pricePerKathaController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixText: '৳ ',
              prefixStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey700,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey900),
          ),
          SizedBox(height: 20.h),

          // Asking Price display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                Text(
                  'Asking Price',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
                SizedBox(height: 8.h),
                Text(
                  '৳ $askingPrice',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Previous Price
          Row(
            children: [
              Text(
                'Previous Price  ',
                style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
              ),
              Text(
                '৳ ${widget.deal.soldPrice}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Update & List as a Sell Post',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey900,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(fontSize: 14.sp, color: AppColors.error),
          ),
      ],
    );
  }
}

