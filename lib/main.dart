import 'package:flutter/material.dart';
import 'base_tabbar_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart'; // 确保添加此依赖
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(
    OKToast(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 设计稿尺寸，例如iPhone X设计稿尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BaseTabBarController(),
          builder: EasyLoading.init(), // 在这里初始化 EasyLoading

        );
      },
    );
  }
}
