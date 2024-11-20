import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativePageWidget extends StatefulWidget {
  const NativePageWidget({super.key});

  @override
  State<NativePageWidget> createState() => _NativePageWidgetState();
}

class _NativePageWidgetState extends State<NativePageWidget> {
  static const String viewType = 'native_ios_view';

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    final size = MediaQuery.of(context).size;
    
    // 在 iOS 平台上使用 UiKitView
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
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
      );
    }
    
    // 其他平台的 fallback
    return const Center(
      child: Text('This feature is only available on iOS'),
    );
  }
}