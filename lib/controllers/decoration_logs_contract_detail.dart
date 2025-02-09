import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_project_list.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class DecorationLogsContractDetailWiget extends StatefulWidget {
  final String contractId;
  const DecorationLogsContractDetailWiget({super.key,required this.contractId});

  @override
  State<DecorationLogsContractDetailWiget> createState() => _DecorationLogsContractDetailWigetState();
}

class _DecorationLogsContractDetailWigetState extends State<DecorationLogsContractDetailWiget> {
  Map<String, dynamic> _contractDetail = {}; // 合同详情
  bool _isLoading = true; // 添加加载状态标志

  @override
  void initState() {
    super.initState();
    _getCurrentData();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // 如果正在加载，显示加载指示器
    if (_isLoading) {
      return Scaffold(
        backgroundColor: HexColor('#F8F8F8'),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text('标准合同', 
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final contractInfo = _contractDetail['contractInfo'];
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('标准合同', 
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('${contractInfo['contractTypeDisPlay'] ?? ''}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
                    ),
                    SizedBox(height: 8.h,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('设计方案: ${contractInfo['packageName'] ?? ''}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                    ),
                    SizedBox(height: 8.h,),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Text('合同编号: ${contractInfo['contractNo'] ?? ''}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            //跳转到合同清单页面
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DecorationLogsProjectListWidget(contractId: widget.contractId)));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Row(
                              children: [
                                Text('查看合同清单', style: TextStyle(fontSize: 12.sp, color: HexColor('#CA9C72')),),
                                Icon(Icons.arrow_forward_ios, size: 12.sp, color: HexColor('#CA9C72'),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.h,)
                  ],
                ),
              )
            ),
            SizedBox(height: 16.h,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('合同总价', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),

                  ),
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      Text('直接费',style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                      Spacer(),
                      Text('¥${contractInfo['directPrice'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      SizedBox(width: 16.w,),

                    ],
                  ),
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      Text('税金',style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                      Spacer(),
                      Text('¥${contractInfo['taxPrice'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      SizedBox(width: 16.w,),

                    ],
                  ),
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      Text('服务费',style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                      Spacer(),
                      Text('¥${contractInfo['managePrice'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      SizedBox(width: 16.w,),

                    ],
                  ),
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      Text('优惠',style: TextStyle(fontSize: 14.sp, color: HexColor('#999999')),),
                      Spacer(),
                      Text('¥${contractInfo['discountPrice'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      SizedBox(width: 16.w,),

                    ],
                  ),
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      Spacer(),
                      Text('合计:  ¥${contractInfo['contractPrice'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'),fontWeight: FontWeight.bold),),
                      SizedBox(width: 16.w,),
                    ],
                  ),
                  SizedBox(height: 16.h,),
                ],

              ),
            ),
            SizedBox(height: 8.h,),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      Text('付款方式', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
                      SizedBox(width: 4.w,),
                      Text('(分期付款)', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                      
                    ],
                  ),
                  SizedBox(height: 16.h,),
                  ListView.builder(
                    itemCount: _contractDetail['payList'].length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final payItem = _contractDetail['payList'][index];
                      return Container(
                        width: double.infinity,
                        height: 50.h,
                        child: Row(
                          children: [
                            SizedBox(width: 16.w,),
                            Text('${index + 1}', style: TextStyle(fontSize: 14.sp, color: HexColor('#FFB26D')),),
                            SizedBox(width: 16.w,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('¥${payItem['price'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'),fontWeight: FontWeight.bold),),
                                SizedBox(height: 4.h,),
                                Text('第${_convertString(payItem['type'])}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  //写个转换的方法传入字符串返回String
  String _convertString(String str) {
    String result = '一期';
    switch (str) {
      case '1':
         result = '一期';
        break;
      case '2':
         result = '二期';
        break;
      case '3':
         result = '三期';
        break;
      case '4':
         result = '四期';
        break;
      default:
        break;
    }

    return result;
  }

  Future<void> _getCurrentData() async {
    setState(() {
      _isLoading = true; // 开始加载时设置状态
    });

    try {
      final apiManager = ApiManager();
      final result = await apiManager.get(
        '/api/furnish/logs/contract/detail',
        queryParameters: {'contractId': widget.contractId}
      );
      
      if (mounted) {
        setState(() {
          _contractDetail = result;
          _isLoading = false; // 加载完成后更新状态
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // 发生错误时也需要更新状态
        });
        // 可以在这里添加错误处理逻辑
      }
    }
  }
}