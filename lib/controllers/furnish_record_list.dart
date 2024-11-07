import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/components/step-indicator.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class FurnishRecordListWidget extends StatefulWidget {
  const FurnishRecordListWidget({super.key});

  @override
  State<FurnishRecordListWidget> createState() => _FurnishRecordListWidgetState();
}

class _FurnishRecordListWidgetState extends State<FurnishRecordListWidget> {
  @override
  void initState() {
    super.initState();
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
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildDesignerCell();
            },
          )
        ),
      ),
    );
  }


  //单元格
  Widget _buildDesignerCell(){
    return Column(
      children: [
        SizedBox(height: 24.h),
        Text('2024/5/25 17:06',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
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
                child: _buildSubCell(),
              ),
            ),
            
          ],
        ),
        SizedBox(height: 32.h),

      ],
    );
  }

  Widget _buildSubCell(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            '已收到您的装修需求，马上为您分配设计师',
            style: TextStyle(
              color: HexColor('#222222'),
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildFurnishInfo(),
        SizedBox(height: 16.h),
        StepIndicator(currentStep: 0, steps: ['已发送招标', '设计师接单', '确认方案', '生成合同'],),
      ],
    );
  }

  //装修信息
  Widget _buildFurnishInfo(){
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
              '姓名：张三',
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
              '联系方式：13888888888',
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
              '所在区域：全屋装修',
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
              '房屋类型：现代简约',
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
              '房屋户型: 三室两厅',
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
              '房屋面积：120㎡',
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
              '装修类型：全屋装修',
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
              '需求备注：无',
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
}