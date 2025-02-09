import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:oktoast/oktoast.dart';

class DecorationLogsParamsWidget extends StatefulWidget {
  final String customerProjectId;
  const DecorationLogsParamsWidget({super.key,required this.customerProjectId});

  @override
  State<DecorationLogsParamsWidget> createState() => _DecorationLogsParamsWidgetState();
}

class _DecorationLogsParamsWidgetState extends State<DecorationLogsParamsWidget> {
  List<Map<String, dynamic>> result = []; // 量房参数
  @override
  void initState() {
    super.initState();
    _getParams();
    
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('量房参数', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: HexColor('#FFF9EE'),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16.w,),
                    Image.asset('assets/images/icon_decoration_info.png', width: 14.w, height: 14.h,),
                    SizedBox(width: 8.w,),
                    Expanded(  // 添加 Expanded 组件
                      child: Text(
                        '量房参数将影响人工和材料的数量；如无疑问请确认该量房参数，如有疑问请联系设计师', 
                        style: TextStyle(fontSize: 12.sp, color: HexColor('#CA9C72')),
                        maxLines: 2,
                      ),
                    ),                    
                    SizedBox(width: 16.w,),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h,),
            ListView.builder(
              itemCount: result.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = result[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h,),
                      Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text('${data['roomTypeDisplay'] ?? ''}', style: TextStyle(fontSize: 16.sp, color: HexColor('#333333'),fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 16.h,),
                      Row(
                        children: [
                          Text('地面面积', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                          Spacer(),
                          Text('${data['landArea'] ?? ''}㎡', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                        ],
                      ),
                      SizedBox(height: 16.h,),
                      Row(
                        children: [
                          Text('墙面面积', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                          Spacer(),
                          Text('${data['wallArea'] ?? ''}㎡', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                        ],
                      ),
                      SizedBox(height: 16.h,),
                      Row(
                        children: [
                          Text('地面周长', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                          Spacer(),
                          Text('${data['perimeter'] ?? ''}m', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                        ],
                      ),
                      SizedBox(height: 16.h,),
                      Row(
                        children: [
                          Text('层高', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                          Spacer(),
                          Text('${data['floorHeight'] ?? ''}m', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            //二次确认框
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('确认量房参数', style: TextStyle(fontSize: 16.sp, color: Colors.black),),
                  content: Text('确认量房参数将影响人工和材料的数量，如无疑问请确认该量房参数，如有疑问请联系设计师', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('取消', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                    ),
                    TextButton(
                      onPressed: () {
                        _confirmParams();
                        Navigator.pop(context);
                      },
                      child: Text('确认', style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                    ),
                  ],
                );
              }
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
              ),
              child: Center(
                child: Text('确认', style: TextStyle(fontSize: 16.sp, color: Colors.white),),
              ),
            ),
         )
        )
      )
    );
  }

  Future<void> _getParams() async {
    // 获取量房参数
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/estimate/params',
      queryParameters: {'customerProjectId': widget.customerProjectId},
    );
    if(result != null && mounted) {
      setState(() {
        this.result = List<Map<String, dynamic>>.from(result);
      });
    }
  }

  //确认量房参数
  Future<void> _confirmParams() async {
    final apiManager = ApiManager();
    final result = await apiManager.post(
      '/api/furnish/logs/estimate/submit',
      data: {'customerProjectId': widget.customerProjectId},
    );
    showToast('确认参数成功');
  }
}