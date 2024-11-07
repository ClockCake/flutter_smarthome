import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class DottedLine extends StatelessWidget {
  final Color color;
  final double height;
  final double dotDiameter;
  final double dotSpacing;

  const DottedLine({
    Key? key,
    this.color = const Color(0xFF222222),
    this.height = 0.5,
    this.dotDiameter = 2.0, // 减小点的大小
    this.dotSpacing = 2.0, // 减小点的间距
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // 确保垂直居中
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotCount = (constraints.maxWidth / (dotDiameter + dotSpacing)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(dotCount, (_) {
              return Container(
                width: dotDiameter,
                height: dotDiameter,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Color activeColor;
  final Color inactiveColor;
  final double lineWidth;
  final double circleSize;
  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.steps,
    this.activeColor = const Color(0xFF222222),
    this.inactiveColor = const Color(0xFFDADBDD),
    this.lineWidth = 2.0,
    this.circleSize = 24.0,
    this.activeTextStyle = const TextStyle(
      color: Color(0xFF222222),
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
    this.inactiveTextStyle = const TextStyle(
      color: Color(0xFFDADBDD),
      fontSize: 11,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: IntrinsicHeight( // 使用IntrinsicHeight确保所有元素垂直对齐
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index % 2 == 0) {
              final stepIndex = index ~/ 2;
              final isActive = stepIndex <= currentStep;

              return Expanded(
                flex: 5, // 增加文字区域的宽度比例
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: isActive ? activeColor : inactiveColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: circleSize * 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        steps[stepIndex],
                        style: isActive ? activeTextStyle : inactiveTextStyle,
                        textAlign: TextAlign.center,
                        maxLines: 2, // 允许文字换行
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final isActive = index ~/ 2 <= currentStep - 1;
              return Expanded(
                flex: 1, // 减小连接线的宽度比例
                child: Center( // 确保DottedLine垂直居中
                  child: Container(
                    height: circleSize, // 使连接线与圆圈高度一致
                    child: DottedLine(
                      color: isActive ? activeColor : inactiveColor,
                      dotDiameter: 2.0, // 更小的点
                      dotSpacing: 1.0, // 更小的间距
                    ),
                  ),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}