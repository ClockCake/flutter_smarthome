import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class QuoteRenovationAreaPageWidget extends StatefulWidget {
  const QuoteRenovationAreaPageWidget({super.key});

  @override
  State<QuoteRenovationAreaPageWidget> createState() => _QuoteRenovationAreaPageWidgetState();
}

class _QuoteRenovationAreaPageWidgetState extends State<QuoteRenovationAreaPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '快速报价',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             _buildTips(),
             SizedBox(height: 16.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  _buildTips(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 12.h),
           Text(
              '请您选择新居结构',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            '您可以通过增加或减少按钮来选择您相应房间的数量为您的新家搭配理想方案',
            style: TextStyle(
              color: HexColor('#999999'),
              fontSize: 12.sp,
            ),
          ),
        ]
      )
    );
  }
    //底部按钮
  _buildBottomButton() {
    return GestureDetector(
      onTap: () {

      },
      child: SafeArea(
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
                '查看报价',
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
}