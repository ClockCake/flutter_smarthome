import 'package:flutter/services.dart';

class NavigationController {
  static const platform = MethodChannel('com.yourapp.navigation');

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
}