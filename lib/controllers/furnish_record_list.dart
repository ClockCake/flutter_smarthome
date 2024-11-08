import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/components/step-indicator.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class FurnishRecordListWidget extends StatefulWidget {
  const FurnishRecordListWidget({super.key});

  @override
  State<FurnishRecordListWidget> createState() => _FurnishRecordListWidgetState();
}

class _FurnishRecordListWidgetState extends State<FurnishRecordListWidget> {
  List<Map<String, dynamic>> _recordList = [];

  @override
  void initState() {
    super.initState();
    _getFurnishRecordList();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 顶部导航栏白色黑字
        title: const Text('我要装修'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: HexColor('#F8F8F8'), // 设置背景色
        child: SafeArea(
          child: _recordList.isEmpty ? 
            EmptyStateWidget(
              onRefresh: _getFurnishRecordList,
              emptyText: '暂无数据',
              buttonText: '点击刷新',
            ) 
              
            : ListView.builder(
            itemCount: _recordList.length,
            itemBuilder: (context, index) {
              return _buildDesignerCell(_recordList[index]);
            },
          ),
        ),
      ),
    );
  }


  //单元格
  Widget _buildDesignerCell(Map<String, dynamic> record) {
    return Column(
      children: [
        SizedBox(height: 24.h),
        Text(record['createTime'],style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 36.w,
              height: 36.w,
              child: CircleAvatar(
                radius: 18.w,
                backgroundImage: const AssetImage('assets/images/icon_furnish_kefu.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
            Expanded(  // 使用 Expanded 包裹 Container
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: _buildSubCell(record),
              ),
            ),
            
          ],
        ),
        SizedBox(height: 32.h),

      ],
    );
  }

  Widget _buildSubCell(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            record['title'],
            style: TextStyle(
              color: HexColor('#222222'),
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildFurnishInfo(record),
        SizedBox(height: 16.h),
        StepIndicator(currentStep: record['decorationProgress'] - 1, steps: ['已发送招标', '设计师接单', '确认方案', '生成合同'],),
      ],
    );
  }

  //装修信息
  Widget _buildFurnishInfo(Map<String, dynamic> record) {
    return Container(
      margin: EdgeInsets.only(left: 16.w,right: 16.w,top: 16.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: HexColor('#F8F8F8'),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start  ,
        children: [
         Padding(
           padding: EdgeInsets.only(left: 16.w,top: 12.h),
            child: Text(
              '装修信息',
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              // ignore: prefer_interpolation_to_compose_strings
              '姓名：' + record['name'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '联系方式：' + record['phone'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '所在区域：' + record['region'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '房屋类型：' + record['roomType'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '房屋户型:  ' + record['bedroomNumber'].toString() + '室' + record['livingRoomNumber'].toString() + '厅' + record['kitchenRoomNumber'].toString() + '厨' + record['toiletRoomNumber'].toString() + '卫',
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '房屋面积：' + record['area'].toString() + '㎡',
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '装修类型：' + record['decorateType'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '需求备注：' + record['remark'],
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 12.sp,
                
              ),
              softWrap: true,  // 允许换行
            ),
          ),
          SizedBox(height: 12.h),

         
        ],
      ),
    );
  }

  //获取装修记录
  Future<void> _getFurnishRecordList() async {
     try {
      // 请求接口
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/furnish/record',
        queryParameters: null,
      );
      if (response != null) {
        _recordList = List<Map<String, dynamic>>.from(response);
        setState(() {
           
        });

      }
     } catch (e) {
       // 错误处理
     }
     
  }
}