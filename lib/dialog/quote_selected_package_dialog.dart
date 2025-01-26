import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class QuoteSelectedPackageDialog extends StatefulWidget {
  final List<Map<String, dynamic>> packages;
  const QuoteSelectedPackageDialog({super.key, required this.packages});

  @override
  State<QuoteSelectedPackageDialog> createState() => _QuoteSelectedPackageDialogState();
}

class _QuoteSelectedPackageDialogState extends State<QuoteSelectedPackageDialog> {
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
                        '已选方案',
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
                    children: widget.packages.map((package) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${package['roomName'] ?? 'null'} ${package['area'] ?? 'null'}m²',
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
                                  child: NetworkImageHelper().getCachedNetworkImage(imageUrl: package['packagePic'] ?? '', width: 93.w, height: 62.h),
                                ),
                                SizedBox(width: 12.w,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      package['packageName'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: HexColor('#333333'),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '100m²仅需 ',
                                            style: TextStyle(
                                              color:HexColor('#999999'),
                                              fontSize: 12.sp
                                            )
                                          ),
                                          TextSpan(
                                            text: '${package['basePrice'] ?? 0}',
                                            style: TextStyle(
                                              color: const Color(0xFFFFA555),
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          TextSpan(
                                            text: ' 元',
                                            style: TextStyle(
                                              color:HexColor('#999999'),
                                              fontSize: 12.sp
                                            )
                                          )
                                        ]
                                      ),
                                    )
                                  ],
                                )
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