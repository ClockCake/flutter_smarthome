import 'package:flutter/material.dart';
import 'base_tabbar_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart'; 
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './utils/user_manager.dart';
import './controllers/login_page.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await UserManager.instance.init();
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
          home: FutureBuilder<bool>(
            // 检查是否已登录
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              // 如果还在加载中
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // 根据登录状态返回相应页面
              return snapshot.data == true 
                ? BaseTabBarController() 
                : LoginPage();
            },
          ),
          builder: EasyLoading.init(), // 在这里初始化 EasyLoading

        );
      },
    );
  }


  Future<bool> _checkIfLoggedIn() async {
    // 从 UserManager 获取用户信息
    final user = await UserManager.instance.user;
    // 如果用户信息存在，则认为已登录
    return user != null;
  }
}
