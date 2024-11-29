import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/utils/login_redirect.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';

class NativePageWidget extends StatefulWidget {
  const NativePageWidget({super.key});

  @override
  State<NativePageWidget> createState() => _NativePageWidgetState();
}

class _NativePageWidgetState extends State<NativePageWidget> {
  static const String viewType = 'native_ios_view';

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
    // 获取屏幕尺寸
    final size = MediaQuery.of(context).size;
    
    // 在 iOS 平台上使用 UiKitView
    if (defaultTargetPlatform == TargetPlatform.iOS) {

    return UserManager.instance.isLoggedIn ?
      SizedBox(
        width: size.width,
        height: size.height,
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: <String, dynamic>{
            'initialWidth': size.width,
            'initialHeight': size.height,
            'tabBarHeight': 49.0, //
          },
          creationParamsCodec: StandardMessageCodec(),
        ),
      )
      :      
       Center(
        child: GoLoginButton(
          onLoginSuccess: () {
            // 登录成功后刷新页面
            setState(() {
              
            });
          },
        ),
      );
    }
    
    // 其他平台的 fallback
    return const Center(
      child: Text('This feature is only available on iOS'),
    );
  }
}