import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/utils/login_event.dart';
import 'package:flutter_smarthome/utils/login_redirect.dart'; 
import 'package:flutter_smarthome/utils/user_manager.dart';

class NativePageWidget extends StatefulWidget {
  const NativePageWidget({super.key});

  @override
  State<NativePageWidget> createState() => _NativePageWidgetState();
}

class _NativePageWidgetState extends State<NativePageWidget> {
  static const String iosViewType = 'native_ios_smartlife';
  static const String androidViewType = 'native_android_smartlife';
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
        // 订阅登录事件
    _subscription = eventBus.stream.listen((event) {
      if (event is LoginEvent && event.success && TargetPlatform.android == defaultTargetPlatform) {
        setState(() {});  // 刷新UI
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();  // 取消订阅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    final size = MediaQuery.of(context).size;
    
    if (!UserManager.instance.isLoggedIn) {
      return Center(
        child: GoLoginButton(
          onLoginSuccess: () {
            setState(() {});
          },
        ),
      );
    }

    // 根据平台返回不同的实现
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return SizedBox(
          width: size.width,
          height: size.height,
          child: UiKitView(
            viewType: iosViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{
              'initialWidth': size.width,
              'initialHeight': size.height,
              'tabBarHeight': 49.0,
            },
            creationParamsCodec: const StandardMessageCodec(),
         
          ),
        );
        
      case TargetPlatform.android:
        return SizedBox(
          width: size.width,
          height: size.height,
          child: AndroidView(
            viewType: androidViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{
              'initialWidth': size.width,
              'initialHeight': size.height,
              'tabBarHeight': 49.0,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        );
        
      default:
        return const Center(
          child: Text('此平台暂不支持 智能家居 功能'),
        );
    }
  }
}