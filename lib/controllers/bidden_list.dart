import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class BiddenListWidget extends StatefulWidget {
  const BiddenListWidget({super.key});

  @override
  State<BiddenListWidget> createState() => _BiddenListWidgetState();
}

class _BiddenListWidgetState extends State<BiddenListWidget> {
  List<Map<String,dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    getBiddenData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#F8F8F8'),
        appBar: AppBar(
          elevation: 0,
          title: const Text('招标',style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildListCell(items[index]);
            },
          )
    );
  }

  Widget _buildListCell(Map<String,dynamic> item) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 0, 0),
                child: Text('设计师${item['name']}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16.h, 16.w, 0),
                child: Text('招标成功', style: TextStyle(fontSize: 14.sp, color: HexColor('#FFAF2A'))),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
                color: HexColor('#F8F8F8'),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 0),
                        child: Text('${item['name']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#2A2A2A'))),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                        child: Text('${item['phone']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10.h, 16.w, 0),
                        child: Text('${item['decorateType']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                        child: Icon(
                          Icons.location_on,  // 使用位置图标
                          size: 16.sp,
                          color: HexColor('#999999'),
                        ),

                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 0, 16.w, 0),
                        child: Text('${item['city']}${item['region']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 16.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '120m²',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: HexColor('#666666'),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '公寓房',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: HexColor('#666666'),
                          ),
                        ),
                      ),
                    ],
                ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void>getBiddenData() async {
    // 获取招标数据
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get('/api/home/tender');
      if (response != null){
         setState(() {
           items = List<Map <String,dynamic>>.from(response['succData']);
         });
      }
    }
    catch(e){
      print('获取招标数据失败：$e');
    } 
  }
}