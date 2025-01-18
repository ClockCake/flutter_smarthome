import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/dialog/appointment-dialog.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/number_formatter.dart';
import 'package:oktoast/oktoast.dart';

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
        title: const Text(
          '报价明细',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildDetailContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDetailContent(){
    return SingleChildScrollView(
      child: Column(
        children: [
           _buildTopInfo(),
           _buildDetailItem(),
           SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildTopInfo(){
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        height: 130.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             RichText(
                text: TextSpan(
                  text: NumberFormatter.removeTrailingZeros(_detailData?['quickPriceResult']?['totalPrice'] ?? 0),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' 万',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp,
                        
                      ),
                    ),
                  ],
                ),
             ),
             SizedBox(height: 8.h),
             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.bedroomCount}室${widget.livingRoomCount}厅${widget.bathroomCount}卫 · ${NumberFormatter.removeTrailingZeros(widget.area)}㎡',
                    style: TextStyle(
                      color: HexColor('#999999'),
                      fontSize: 12.sp,
                    ),
                  ),
                  
                ],
             )
           ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ListView.builder(
          shrinkWrap: true, // 添加此属性使ListView高度自适应内容
          physics: NeverScrollableScrollPhysics(), 
          itemCount: _detailData?['material']?.length ?? 0,
          itemBuilder: (context, index){
            final material= _detailData?['material']?[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 16.h),
                  child: Text(
                    material?['budgetDisplay'] ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: material?['items']?.length ?? 0,
                  itemBuilder: (context, index){
                    final item = material?['items']?[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              color: HexColor('#F5F5F5'),
                            ),
                            child: NetworkImageHelper().getNetworkImage(imageUrl: item?['skuPic'].length == 0 ? 'https://image.iweekly.top/i/2025/01/18/678b68afc1a68.png' : item?['skuPic'],fit: BoxFit.cover),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item?['materialName'] ?? '',
                                style: TextStyle(
                                  color: HexColor('#333333'),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '品牌：${item?['brandName'] ?? ''}',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '规格：${item?['sku'] ?? ''}',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(
                            'x${NumberFormatter.removeTrailingZeros(item?['quotaUsage'] ?? 0)}',
                            style: TextStyle(
                              color: HexColor('#999999'),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(){
     return SafeArea(
      child: GestureDetector(
        onTap: _showDialog,
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
      ),
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

    //展示弹框
  void _showDialog() {
     AppointmentBottomSheet.show(
      context,
      onSubmit: (name, contact) {
        print('姓名: $name');
        print('联系方式: $contact');
        _handleSubmit(name, contact);
      },
    );
  }
    //全局预约提交
  void _handleSubmit(String name, String contact) async{
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home/overall/quick/appointment',
        data: {
          'userName': name,
          'userPhone': contact,
        },
      );
      if (response != null) {
         showToast('预约成功');
      }
    }catch(e){
      print(e);
    }
  }
}