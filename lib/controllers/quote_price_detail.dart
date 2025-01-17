import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';

class QuotePriceDetailWidget extends StatefulWidget {
  final int bedroomCount;  //卧室数量
  final int livingRoomCount;  //客厅数量
  final int bathroomCount;  //卫生间数量
  final int kitchenCount;  //厨房数量
  final double area;  //面积
  final String packageId;  //方案id
  const QuotePriceDetailWidget({Key? key, required this.bedroomCount, required this.livingRoomCount, required this.bathroomCount, required this.area, required this.kitchenCount, required this.packageId}) : super(key: key);
  
  @override
  State<QuotePriceDetailWidget> createState() => _QuotePriceDetailWidgetState();
}

class _QuotePriceDetailWidgetState extends State<QuotePriceDetailWidget> {
  late Map<String, dynamic>_detailData = {}; //报价明细数据
  @override
  void initState() {
    super.initState();
    _getQuotePriceDetail();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '报价明细',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Placeholder(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar(){
     return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              '免费领取设计方案和精准报价',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
    );
  }

  Future<void> _getQuotePriceDetail() async {
     final apiManager = ApiManager();
     final result = await apiManager.post(
        '/api/valuation/quick/quote/whole',
        data: {'packageId':widget.packageId,'area':widget.area,'bedroomNumber':widget.bedroomCount,'livingRoomNumber':widget.livingRoomCount,'toiletRoomNumber':widget.bathroomCount,'kitchenRoomNumber':widget.kitchenCount},
     );
      if(result != null  && mounted){
        setState(() {
          _detailData = result;
        });
      }

  }
}