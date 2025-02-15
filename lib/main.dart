// import 'package:flutter/material.dart';
// import 'package:flutter_smarthome/utils/navigation_controller.dart';
// import 'package:fluwx/fluwx.dart';
// import 'dart:io';
// import 'base_tabbar_controller.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:oktoast/oktoast.dart'; 
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import './utils/user_manager.dart';
// import './controllers/login_page.dart';
// final navigatorKey = GlobalKey<NavigatorState>();

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await UserManager.instance.init();
//   // 全局设置证书验证豁免
//   HttpOverrides.global = MyHttpOverrides();
//   runApp(
//     OKToast(
//       child: MyApp(),
//     ),
//   );
//   _registerWxApi(); // 注册微信 API
// }

// //注册微信 API
// void _registerWxApi() {
//   // 注册微信
//   registerWxApi(
//     appId: "wx8531759f373d8a56",
//     doOnAndroid: true,
//     doOnIOS: true,
//     universalLink: "https://crs.gazolife.cn/ios/",
//   );
// }
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812), // 设计稿尺寸，例如iPhone X设计稿尺寸
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//           home: FutureBuilder<bool>(
//             // 检查是否已登录
//             future: _checkIfLoggedIn(),
//             builder: (context, snapshot) {
//               // 如果还在加载中
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }
              
//               // 根据登录状态返回相应页面
//               return BaseTabBarController();
//             },
//           ),
//           builder: EasyLoading.init(), // 在这里初始化 EasyLoading

//         );
//       },
//     );
//   }


//   Future<bool> _checkIfLoggedIn() async {
//     // 从 UserManager 获取用户信息
//     final user = await UserManager.instance.user;
//     // 如果用户信息存在，则认为已登录
//     return user != null;
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_smarthome/utils/navigation_controller.dart';
import 'package:fluwx/fluwx.dart';
import 'dart:io';
import 'base_tabbar_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart'; 
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './utils/user_manager.dart';
import './controllers/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserManager.instance.init();
  
  // 设置导航监听
  await NavigationController.setupNavigationHandler();
  
  // 全局设置证书验证豁免
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(
    OKToast(
      child: MyApp(),
    ),
  );
  _registerWxApi(); // 注册微信 API
}

//注册微信 API
void _registerWxApi() {
  registerWxApi(
    appId: "wx8531759f373d8a56",
    doOnAndroid: true,
    doOnIOS: true,
    universalLink: "https://crs.gazolife.cn/ios/",
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: NavigationController.navigatorKey, // 使用 NavigationController 的 key
          debugShowCheckedModeBanner: false,
          home: FutureBuilder<bool>(
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return BaseTabBarController();
            },
          ),
          builder: EasyLoading.init(),
        );
      },
    );
  }

  Future<bool> _checkIfLoggedIn() async {
    final user = await UserManager.instance.user;
    return user != null;
  }
}