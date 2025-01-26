import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double indicatorWidth;
  final Color indicatorColor;
  final double indicatorHeight;
  
  const CustomTabIndicator({
    this.indicatorWidth = 20,
    this.indicatorColor = Colors.blue,
    this.indicatorHeight = 2,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(
      this,
      indicatorWidth,
      indicatorColor,
      indicatorHeight,
      onChanged,
    );
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final double indicatorWidth;
  final Color indicatorColor;
  final double indicatorHeight;

  _CustomPainter(
    this.decoration,
    this.indicatorWidth,
    this.indicatorColor,
    this.indicatorHeight,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint();
    paint.color = indicatorColor;
    paint.style = PaintingStyle.fill;
    
    // 计算指示器的位置
    final indicatorStartX = rect.left + (rect.width - indicatorWidth) / 2;
    final indicatorEndX = indicatorStartX + indicatorWidth;
    final indicatorY = rect.bottom - indicatorHeight;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          indicatorStartX,
          indicatorY,
          indicatorWidth,
          indicatorHeight,
        ),
        const Radius.circular(1.0),
      ),
      paint,
    );
  }
}