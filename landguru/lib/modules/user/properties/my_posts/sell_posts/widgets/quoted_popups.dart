import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../models/sell_post_models.dart';

/// Payment Method enum
enum PaymentMethod { sslCommerz, mobileBanking }

/// Requote Dialog - Shows service fees breakdown and allows user to enter requote offer
class RequoteDialog extends StatefulWidget {
  final BillBreakdown billBreakdown;
  final Future<void> Function(double mandatoryFee, double optionalFee) onSubmit;

  const RequoteDialog({
    super.key,
    required this.billBreakdown,
    required this.onSubmit,
  });

  /// Show the requote dialog
  static Future<void> show(
    BuildContext context, {
    required BillBreakdown billBreakdown,
    required Future<void> Function(double mandatoryFee, double optionalFee)
    onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RequoteDialog(billBreakdown: billBreakdown, onSubmit: onSubmit),
    );
  }

  @override
  State<RequoteDialog> createState() => _RequoteDialogState();
}

class _RequoteDialogState extends State<RequoteDialog> {
  late TextEditingController _mandatoryFeeController;
  late TextEditingController _optionalFeeController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mandatoryFeeController = TextEditingController(text: '2000');
    _optionalFeeController = TextEditingController(text: '2000');
  }

  @override
  void dispose() {
    _mandatoryFeeController.dispose();
    _optionalFeeController.dispose();
    super.dispose();
  }

  double get _totalRequotedValue {
    final mandatory =
        double.tryParse(_mandatoryFeeController.text.replaceAll(',', '')) ?? 0;
    final optional =
        double.tryParse(_optionalFeeController.text.replaceAll(',', '')) ?? 0;
    return mandatory + optional;
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    final mandatory =
        double.tryParse(_mandatoryFeeController.text.replaceAll(',', '')) ?? 0;
    final optional =
        double.tryParse(_optionalFeeController.text.replaceAll(',', '')) ?? 0;

    await widget.onSubmit(mandatory, optional);

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Requote',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        color: AppColors.grey600,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Service Fees Section
                _buildServiceFeesSection(),

                SizedBox(height: 20.h),

                // Requote Your Offer Section
                _buildRequoteOfferSection(),

                SizedBox(height: 24.h),

                // Requote Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Requote',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceFeesSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Fees',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),

          SizedBox(height: 12.h),

          // Mandatory Service Fees
          _buildServiceFeeCategory(
            'Mandatory Service Fees',
            widget.billBreakdown.mandatoryServices,
            widget.billBreakdown.mandatoryTotal,
          ),

          SizedBox(height: 14.h),

          // Optional Service Fees
          _buildServiceFeeCategory(
            'Optional Service Fees',
            widget.billBreakdown.optionalServices,
            widget.billBreakdown.optionalTotal,
          ),

          SizedBox(height: 12.h),

          // Total Payable
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              Text(
                '৳ ${widget.billBreakdown.totalPayable.toInt()}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFeeCategory(
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
        ...services.map((service) => _buildServiceItem(service.name)),
      ],
    );
  }

  Widget _buildServiceItem(String name) {
    return Padding(
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
              name,
              style: TextStyle(fontSize: 12.sp, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequoteOfferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requote Your Offer',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),

        SizedBox(height: 12.h),

        // Mandatory Service Fees Input
        Text(
          'Mandatory Service Fees',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPriceInputField(_mandatoryFeeController),

        SizedBox(height: 12.h),

        // Optional Service Fees Input
        Text(
          'Optional Service Fees',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPriceInputField(_optionalFeeController),

        SizedBox(height: 16.h),

        // Total Requoted Value
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withAlpha(30)),
          ),
          child: Column(
            children: [
              Text(
                'Total Requoted Value',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '৳ ${_totalRequotedValue.toInt()}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInputField(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          Text(
            '৳',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}

/// Requote Submitted Dialog - Success confirmation after requote submission
class RequoteSubmittedDialog extends StatelessWidget {
  final String propertyTitle;
  final double requotedAmount;
  final int requotedTimes;
  final VoidCallback onClose;

  const RequoteSubmittedDialog({
    super.key,
    required this.propertyTitle,
    required this.requotedAmount,
    required this.requotedTimes,
    required this.onClose,
  });

  /// Show the requote submitted dialog
  static Future<void> show(
    BuildContext context, {
    required String propertyTitle,
    required double requotedAmount,
    required int requotedTimes,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RequoteSubmittedDialog(
        propertyTitle: propertyTitle,
        requotedAmount: requotedAmount,
        requotedTimes: requotedTimes,
        onClose: onClose,
      ),
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
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    propertyTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    color: AppColors.grey500,
                    size: 24.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Email/Envelope Icon
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.mail_outline, color: AppColors.white, size: 36.sp),
                  Positioned(
                    right: 12.w,
                    top: 16.h,
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              'Requote Submitted',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),

            SizedBox(height: 8.h),

            // Amount
            Text(
              '৳ ${requotedAmount.toInt()}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'It may take up to 1-3 business days for reviewing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),

            SizedBox(height: 24.h),

            // Status and Requoted Times
            Row(
              children: [
                // Status
                Expanded(
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

                // Requoted Times
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Requoted',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$requotedTimes Times',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pay & Activate Post Dialog - Shows payment method selection
class PayAndActivateDialog extends StatefulWidget {
  final double totalPayable;
  final int quotationRevisions;
  final Future<void> Function(PaymentMethod method) onPay;

  const PayAndActivateDialog({
    super.key,
    required this.totalPayable,
    required this.quotationRevisions,
    required this.onPay,
  });

  /// Show the pay and activate dialog
  static Future<void> show(
    BuildContext context, {
    required double totalPayable,
    required int quotationRevisions,
    required Future<void> Function(PaymentMethod method) onPay,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PayAndActivateDialog(
        totalPayable: totalPayable,
        quotationRevisions: quotationRevisions,
        onPay: onPay,
      ),
    );
  }

  @override
  State<PayAndActivateDialog> createState() => _PayAndActivateDialogState();
}

class _PayAndActivateDialogState extends State<PayAndActivateDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.sslCommerz;
  bool _isProcessing = false;

  Future<void> _handlePay() async {
    setState(() => _isProcessing = true);
    await widget.onPay(_selectedMethod);
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pay & Activate Post',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: AppColors.grey600,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Total Payable Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withAlpha(30)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Payable',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '৳ ${widget.totalPayable.toInt()}',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Choose Payment Method
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),

              SizedBox(height: 12.h),

              // SSL Commerz Option
              _buildPaymentMethodOption(
                PaymentMethod.sslCommerz,
                'SSL Commerz',
                'All payment methods in one place',
                Icons.credit_card,
              ),

              SizedBox(height: 10.h),

              // Mobile Banking Option
              _buildPaymentMethodOption(
                PaymentMethod.mobileBanking,
                'Mobile Banking',
                'Bkash, Nagad, Rocket',
                Icons.phone_android,
              ),

              SizedBox(height: 20.h),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : Text(
                          'Pay',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16.h),

              // Status and Quotation Revised
              Row(
                children: [
                  // Status
                  Column(
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Quoted',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  // Quotation Revised
                  Text(
                    'Quotation Revised: ${widget.quotationRevisions} times',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20.w,
              height: 20.h,
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
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: 12.w),

            // Icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),

            SizedBox(width: 12.w),

            // Title and subtitle
            Column(
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
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.grey500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment Confirmed Dialog - Success confirmation after payment
class PaymentConfirmedDialog extends StatelessWidget {
  final double amount;
  final String propertyTitle;
  final String propertyPrice;
  final String propertyType;
  final String? imageUrl;
  final VoidCallback onClose;

  const PaymentConfirmedDialog({
    super.key,
    required this.amount,
    required this.propertyTitle,
    required this.propertyPrice,
    required this.propertyType,
    this.imageUrl,
    required this.onClose,
  });

  /// Show the payment confirmed dialog
  static Future<void> show(
    BuildContext context, {
    required double amount,
    required String propertyTitle,
    required String propertyPrice,
    required String propertyType,
    String? imageUrl,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentConfirmedDialog(
        amount: amount,
        propertyTitle: propertyTitle,
        propertyPrice: propertyPrice,
        propertyType: propertyType,
        imageUrl: imageUrl,
        onClose: onClose,
      ),
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
              'Service Fee Payment Confirmed',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Amount
            Text(
              '৳ ${amount.toInt()}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Your sell post will be live soon.\nIt may take up to 1-3 business days for reviewing',
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
                    child: imageUrl != null
                        ? Image.asset(
                            imageUrl!,
                            width: 64.w,
                            height: 64.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                  SizedBox(width: 12.w),

                  // Property info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propertyTitle,
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
                          'Price: ৳ $propertyPrice',
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
                            propertyType,
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
}
