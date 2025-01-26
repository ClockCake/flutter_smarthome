import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class QuoteSelectedStylesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> styles;
  const QuoteSelectedStylesDialog({super.key,required this.styles});

  @override
  State<QuoteSelectedStylesDialog> createState() => _QuoteSelectedStylesDialogState();
}

class _QuoteSelectedStylesDialogState extends State<QuoteSelectedStylesDialog> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight / 2;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 50.h,
                child: Stack(
                  children: [
                    // Center text
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        '已选风格',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Close button aligned to the right
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
           Divider(height: 1.h),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: widget.styles.map((style) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${style['roomName'] ?? 'null'}',
                            style:  TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: NetworkImageHelper().getCachedNetworkImage(imageUrl: style['pic'] ?? '', width: 93.w, height: 62.h),
                                ),
                                SizedBox(width: 12.w,),
                                Text(
                                  style['dictLabel'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: HexColor('#222222'),
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}