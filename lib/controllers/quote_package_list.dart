import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/controllers/quote_price_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class QuotePackageListWidget extends StatefulWidget {

  final RenovationType renovationType;   //装修类型
  final int bedroomCount;  //卧室数量
  final int livingRoomCount;  //客厅数量
  final int bathroomCount;  //卫生间数量
  final int kitchenCount;  //厨房数量
  final double area;  //面积
  const QuotePackageListWidget({super.key, required this.renovationType, required this.bedroomCount, required this.livingRoomCount, required this.bathroomCount, required this.area,required this.kitchenCount});

  @override
  State<QuotePackageListWidget> createState() => _QuotePackageListWidgetState();
}

class _QuotePackageListWidgetState extends State<QuotePackageListWidget> {
  List<Map<String, dynamic>> _packageList = []; //方案列表
  @override
  void initState() {
    super.initState();
    _getPackageList();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '方案列表',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 添加横向拉伸
            children: [
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w), // 添加水平内边距
                child: Text(
                  '选择方案',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center, // 文本居中
                ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '${widget.bedroomCount}室${widget.livingRoomCount}厅${widget.bathroomCount}卫 · ${widget.area}㎡',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: _buildPackageList(),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildPackageList() {
      // Add shrinkWrap: true and physics: NeverScrollableScrollPhysics()
      // to prevent nested scrolling behavior
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _packageList.length,
        itemBuilder: (context, index) {
          final item = _packageList[index];
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: NetworkImageHelper().getCachedNetworkImage(
                      imageUrl: item['packagePic'] ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150.h,
                    ),
                  ),
                  SizedBox(height: 12.h,),
                  Row(
                    children: [
                      Expanded(  // Wrap Column with Expanded to prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
                          children: [
                            SizedBox(height: 8.h,),
                            Text(
                              item['packageName'] ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 4.h,),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '100m²仅需',
                                    style: TextStyle(
                                      color: HexColor('#999999'),
                                      fontSize: 12.sp
                                    )
                                  ),
                                  TextSpan(
                                    text: '${item['basePrice'] ?? 0}',
                                    style: TextStyle(
                                      color: HexColor('#FFA555'),
                                      fontSize: 16.sp
                                    )
                                  ),
                                  TextSpan(
                                    text: '元',
                                    style: TextStyle(
                                      color: HexColor('#999999'),
                                      fontSize: 12.sp
                                    )
                                  )
                                ]
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigation code here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuotePriceDetailWidget(
                                packageId: item['packageId'],
                                bedroomCount: widget.bedroomCount,
                                livingRoomCount: widget.livingRoomCount,
                                bathroomCount: widget.bathroomCount,
                                area: widget.area,
                                kitchenCount: widget.kitchenCount,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: HexColor('#000000')),
                          ),
                          child: Text(
                            '选择方案',
                            style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 13.sp
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(width: 16.w,),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
  }

  Future<void> _getPackageList() async {
    //获取方案列表
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/valuation/packages/whole',
    );
    if (result != null && mounted) {
      setState(() {
        _packageList = List<Map<String, dynamic>>.from(result);
      });
    }
  }
}