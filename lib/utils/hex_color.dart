import 'package:flutter/material.dart';

class HexColor extends Color {
  // 构造函数，传入16进制颜色字符串
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  // 将16进制颜色字符串转换为整数值
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // 如果没有透明度信息，默认透明度为 100% (FF)
    }
    return int.parse(hexColor, radix: 16);
  }
}