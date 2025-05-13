import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  final String? emptyText;
  final String? buttonText;

  const EmptyStateWidget({
    Key? key,
    required this.onRefresh,
    this.emptyText,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 暂无数据图标
          Container(
            width: 66.w,
            height: 66.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/icon_empty_data.png'),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // 暂无数据文本
          Text(
            emptyText ?? '暂无数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: HexColor('#999999'),
            ),
          ),
          const SizedBox(height: 24),
          // 刷新按钮
          ElevatedButton(
            onPressed: onRefresh,
            //背景色
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
            ),
            child: Text(buttonText ?? '点击刷新', style: TextStyle(fontSize: 14.sp,color: Colors.white),),
          ),
        ],
      ),
    );
  }
}