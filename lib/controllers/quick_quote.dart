import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smarthome/utils/login_redirect.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';

class QuickQuoteWidget extends StatefulWidget {
  final int index;  // 0 是整装， 1 是 翻新 2 是软装
  const QuickQuoteWidget({
    super.key,
    required this.index,
  });

  @override
  State<QuickQuoteWidget> createState() => _QuickQuoteWidgetState();
}

class _QuickQuoteWidgetState extends State<QuickQuoteWidget> {
  // 为这个页面定义一个新的 viewType，避免与其他原生视图冲突
  static const String viewType = 'native_quote_view';

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
      return UserManager.instance.isLoggedIn 
        ? Scaffold(
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: UiKitView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: <String, dynamic>{
                  'initialWidth': size.width,
                  'initialHeight': size.height,
                  'tabBarHeight': 49.0,
                  'index':widget.index,
                  // 可以根据需要添加其他参数
                },
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: GoLoginButton(
                onLoginSuccess: () {
                  // 登录成功后刷新页面
                  setState(() {});
                },
              ),
            ),
          );
    }
    
    // 其他平台的 fallback
    return const Scaffold(
      body: Center(
        child: Text('This feature is only available on iOS'),
      ),
    );
  }
}