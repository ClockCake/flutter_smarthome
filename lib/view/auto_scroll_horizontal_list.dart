import 'dart:async';
import 'package:flutter/material.dart';

/// 一个可复用的自动横向滚动列表 Widget
class AutoScrollHorizontalList extends StatefulWidget {
  /// 列表项的构建器
  final IndexedWidgetBuilder itemBuilder;

  /// 列表项的数量
  final int itemCount;

  /// 每秒滚动的像素数
  final double scrollSpeed;

  /// 每次滚动的时间间隔（毫秒）
  final int scrollInterval;

  /// 列表的高度
  final double height;

  /// 列表项的宽度
  final double itemWidth;

  /// 列表项的间距
  final EdgeInsetsGeometry padding;

  /// 列表的背景颜色
  final Color backgroundColor;

  AutoScrollHorizontalList({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollSpeed = 50.0,
    this.scrollInterval = 100,
    this.height = 150.0,
    this.itemWidth = 150.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  _AutoScrollHorizontalListState createState() => _AutoScrollHorizontalListState();
}

class _AutoScrollHorizontalListState extends State<AutoScrollHorizontalList> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isScrollingForward = true;

  @override
  void initState() {
    super.initState();
    // 启动定时器，每隔一段时间滚动一点
    _timer = Timer.periodic(
      Duration(milliseconds: widget.scrollInterval),
      _scroll,
    );
  }

  void _scroll(Timer timer) {
    if (!_scrollController.hasClients) return;

    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;

    // 计算每次滚动的距离
    double delta = (widget.scrollSpeed / 1000) * widget.scrollInterval;

    if (_isScrollingForward) {
      if (currentScroll + delta >= maxScroll) {
        _isScrollingForward = false;
        _scrollController.animateTo(
          maxScroll,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(currentScroll + delta);
      }
    } else {
      if (currentScroll - delta <= 0) {
        _isScrollingForward = true;
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(currentScroll - delta);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: widget.itemWidth,
            margin: widget.padding,
            child: widget.itemBuilder(context, index),
          );
        },
      ),
    );
  }
}