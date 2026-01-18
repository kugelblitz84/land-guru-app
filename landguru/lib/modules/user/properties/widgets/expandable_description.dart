import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// A widget that shows description text with "Show more/less" toggle
/// when the text exceeds maxLines
class ExpandableDescription extends StatefulWidget {
  final String text;
  final String? title;
  final int maxLines;
  final TextStyle? textStyle;
  final TextStyle? titleStyle;

  const ExpandableDescription({
    super.key,
    required this.text,
    this.title,
    this.maxLines = 1,
    this.textStyle,
    this.titleStyle,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle ??
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.grey600,
          height: 1.5,
        );

    final titleStyle = widget.titleStyle ??
        TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: titleStyle),
          SizedBox(height: 8.h),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            // Create a TextPainter to check if text overflows
            final textSpan = TextSpan(text: widget.text, style: textStyle);
            final textPainter = TextPainter(
              text: textSpan,
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: constraints.maxWidth);

            // Check if the text overflows
            _hasOverflow = textPainter.didExceedMaxLines;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  firstChild: Text(
                    widget.text,
                    style: textStyle,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(
                    widget.text,
                    style: textStyle,
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (_hasOverflow) ...[
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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
}
