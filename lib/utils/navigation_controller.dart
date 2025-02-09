import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/controllers/my_project_list.dart';

class NavigationController {
  static const platform = MethodChannel('com.smartlife.navigation');
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // 控制导航栏显示隐藏
  static Future<void> showNavigationBar() async {
    try {
      await platform.invokeMethod('showNavigationBar');
    } on PlatformException catch (e) {
      print("Failed to show navigation bar: '${e.message}'.");
    }
  }

  static Future<void> hideNavigationBar() async {
    try {
      await platform.invokeMethod('hideNavigationBar');
    } on PlatformException catch (e) {
      print("Failed to hide navigation bar: '${e.message}'.");
    }
  }

  // 返回到上一页
  static Future<void> popToFlutter() async {
    try {
      await platform.invokeMethod('popToFlutter');
    } on PlatformException catch (e) {
      print("Failed to pop: '${e.message}'.");
    }
  }

  // 设置导航监听
  static Future<void> setupNavigationHandler() async {
    platform.setMethodCallHandler((call) async {
      print("Received method call: ${call.method}");
      return await handleNavigation(call);
    });
  }

  static Future<dynamic> handleNavigation(MethodCall call) async {
    print("Handling navigation: ${call.method}");
    switch (call.method) {
      case 'showProjectList':
        final context = navigatorKey.currentContext;
        print("Context available: ${context != null}");
        if (context != null) {
          try {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyProjectListPage()),
            );
            print("Navigation successful");
          } catch (e) {
            print("Navigation error: $e");
          }
        } else {
          print("Context is null!");
        }
        break;
    }
  }
}