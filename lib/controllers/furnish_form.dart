import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class FurnishFormWidget extends StatefulWidget {
  const FurnishFormWidget({super.key});

  @override
  State<FurnishFormWidget> createState() => _FurnishFormWidgetState();
}

class _FurnishFormWidgetState extends State<FurnishFormWidget> {
 //获取的网络数据字典数组
  List<Map<String, dynamic>> _areaList = [];
  List<Map<String, dynamic>> _houseTypeList = [];
  List<Map<String, dynamic>> _decorationTypeList = [];
 @override
  void initState() {
    super.initState();
    _fetchData();
  }
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
            _buildFooter(),
          ],
        ),
      )
    );
  }

  //头部
  Widget _buildHeader() {
    return Container(
      color: HexColor('#FFF7F0'), // 设置背景色
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            SizedBox(width: 16.w,),
            Text('我要装修', style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold),),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              width: 108.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.book, color: HexColor('#FFA555'), size: 16.sp,),
                  SizedBox(width: 4.w,),
                  Text('装修记录', style: TextStyle(color: HexColor('#FFA555'), fontSize: 12.sp),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //中间表单
  Widget _buildForm(){
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
           Row(
            children: [
              Text('姓名', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入姓名',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
           ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('联系方式', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入手机号',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('所在区域', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          print('点击了所在区域');
                        },
                        child: TextField( //不可点击
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '请选择所在区域',
                            hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    ),
                    Icon(Icons.arrow_forward_ios, color: HexColor('#999999'), size: 16.sp,),
                  ],
                )
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('房屋类型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField( //不可点击
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: '请选择房屋类型',
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: HexColor('#999999'), size: 16.sp,),
                  ],
                )
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //房屋户型 x 室 x 厅 x 厨 x 卫   其中 x 为输入框
          Row(
            children: [
              Text('房屋户型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('室', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('厅', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('厨', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('卫', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //房屋面积
          Row(
            children: [
              Text('房屋面积', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入房屋面积',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Text('㎡', style: TextStyle(color: Colors.black, fontSize: 14.sp),),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //装修类型
          Row(
            children: [
              Text('装修类型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField( //不可点击
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: '请选择装修类型',
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: HexColor('#999999'), size: 16.sp,),
                  ],
                )
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //需求备注
          Row(
            children: [
              Text('需求备注', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入需求备注',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //尾部退出按钮
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: InkWell(
        onTap: () {
          print('点击了确认按钮');
        },
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: HexColor('#111111'),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text('确认', style: TextStyle(color: Colors.white, fontSize: 15.sp),),
          ),
        ),
      )
    );
  }
  

  //网络请求
  Future<void> _fetchData() async {
   try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/furnish/area',
        queryParameters: {
          'parentId': '3101', // 上海市的id
        },
      );

      if (response != null) {
        _areaList = response;
        setState(() {
           
        });

      }
    } catch (e) {
      print(e);
    }
  }
  
}