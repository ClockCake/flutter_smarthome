import 'dart:async'; // 导入Completer

import 'package:flutter/foundation.dart'; // 为了 Factory (虽然在新版WebView中可能不再直接需要为WebView设置手势)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart'; // 确认你的ApiManager路径
import 'package:flutter_smarthome/utils/hex_color.dart';      // 确认你的HexColor路径
import 'package:flutter_smarthome/utils/network_image_helper.dart'; // 确认你的NetworkImageHelper路径
import 'package:webview_flutter/webview_flutter.dart'; // 导入WebView包

// (修正类名拼写错误：Wiget -> Widget)
class ActivityDetailWidget extends StatefulWidget {
  final String title;
  final String activityId;
  const ActivityDetailWidget({
    super.key,
    required this.title,
    required this.activityId,
  });

  @override
  State<ActivityDetailWidget> createState() => _ActivityDetailWidgetState();
}

class _ActivityDetailWidgetState extends State<ActivityDetailWidget> {
  // 活动详情数据，允许为null
  Map<String, dynamic>? _activityDetail;
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0; // AppBar透明度
  bool _isLoading = true; // 初始时显示加载指示器
  double _webViewHeight = 100.h; // WebView的初始高度
  bool _isWebViewReady = false; // 标记WebView是否已准备好并加载了内容

  // WebView控制器
  late final WebViewController _webViewController;
  // 用于确保JS在页面加载完成后执行
  final Completer<void> _pageLoadedCompleter = Completer<void>();

  // JavaScript通道名称，用于从JS接收高度 (可以复用)
  static const String _heightChannelName = 'PageHeight';

  @override
  void initState() {
    super.initState();

    // 初始化WebView控制器 (与之前的代码相同)
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_pageLoadedCompleter.isCompleted) {
              _pageLoadedCompleter.complete();
            }
            _injectJSForHeight(); // 页面加载完后注入JS获取高度
            if (mounted) {
              setState(() {
                _isWebViewReady = true; // WebView准备就绪
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''页面资源错误: code: ${error.errorCode} description: ${error.description} errorType: ${error.errorType}''');
            if (!_pageLoadedCompleter.isCompleted) {
               _pageLoadedCompleter.completeError(error);
            }
             if (mounted) {
               setState(() { _isLoading = false; }); // 加载失败也停止指示器
             }
          },
        ),
      )
      ..addJavaScriptChannel(
        _heightChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          // (与之前的代码相同) 处理接收到的高度信息
          final String heightStr = message.message;
          final double? height = double.tryParse(heightStr);
          debugPrint("收到WebView高度信息: $heightStr");

          if (height != null && height > 0 && mounted) {
            // **移除之前的 + 16.0 缓冲区**
            final newHeight = height;
            debugPrint("解析后高度: $newHeight");

            // 只有当新高度与当前高度显著不同时才更新，避免不必要的重绘
            if ((newHeight - _webViewHeight).abs() > 1.0 || _isLoading) {
               setState(() {
                 _webViewHeight = newHeight;
                 if (_isLoading) { _isLoading = false; } // 收到有效高度后，停止加载状态
                 debugPrint("更新WebView高度为: $_webViewHeight");
               });
            } else {
              debugPrint("新高度 $newHeight 与当前高度 $_webViewHeight 差别不大，不更新UI");
            }
          } else if (mounted && height == 0) {
            debugPrint("收到高度为0或解析失败");
            setState(() {
               if (_isLoading) { // 确保只在加载过程中设置一次
                  _isLoading = false;
                  _webViewHeight = 50.h; // 给一个最小高度
               }
            });
          }
        },
      );

    _scrollController.addListener(_onScroll); // 监听滚动
    _getActivityDetail(); // 开始获取活动数据
  }

  // (与之前的代码相同) 注入并执行用于获取高度和禁用滚动的JS代码
  Future<void> _injectJSForHeight() async {
    final String jsCode = '''
      try {
        function sendHeight(source) {
          let height = document.body.scrollHeight;
          if (!height || height < 50) { height = document.documentElement.scrollHeight; }
          console.log(source + " 计算高度: " + height);
          if (window.$_heightChannelName && window.$_heightChannelName.postMessage) {
            window.$_heightChannelName.postMessage(height.toString());
            console.log(source + " 发送高度: " + height);
          } else { console.error('JavaScript通道 "$_heightChannelName" 未找到！'); }
          if (document.body.style.overflow !== 'hidden') {
             document.body.style.overflow = 'hidden';
             document.body.style.margin = '0';
             document.body.style.padding = '16px'; // 在JS里设置内边距
             console.log("设置 body overflow: hidden");
          }
        }
        sendHeight("立即");
        setTimeout(function() { sendHeight("延迟300ms"); }, 300);
        setTimeout(function() { sendHeight("延迟1000ms"); }, 1000);
      } catch (e) { console.error('执行JS获取高度时出错:', e); }
    '''
       .replaceAll('\$_heightChannelName', _heightChannelName)
       .replaceAll('\$_heightChannelName', _heightChannelName)
       .replaceAll('\$_heightChannelName', _heightChannelName);

    try {
       await _pageLoadedCompleter.future;
       await _webViewController.runJavaScript(jsCode);
       debugPrint("已注入并执行(含延迟的)获取高度的JS");
    } catch (e) {
       debugPrint("执行JS时出错: $e");
       if (mounted) {
         setState(() {
           _isLoading = false;
           _webViewHeight = 100.h;
         });
       }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // 移除监听器
    _scrollController.dispose();
    // 注意: 新版 webview_flutter 的 WebViewController 不需要手动 dispose
    super.dispose();
  }

  // 滚动监听，更新AppBar透明度
  void _onScroll() {
    if (!mounted) return;
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    if (_opacity != opacity) {
      setState(() { _opacity = opacity; });
    }
  }

  // 获取活动详情数据
  Future<void> _getActivityDetail() async {
    // 初始 _isLoading 就是 true, 这里不需要显式设置
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/activity/detail', // 活动详情API端点
        queryParameters: { 'id': widget.activityId },
      );
      if (response != null && mounted) {
        _activityDetail = response; // 更新活动数据

        // 准备HTML给WebView
        String rawHtml = _activityDetail?['resourceInfo'] ?? ''; // 获取HTML内容
        // String cleanHtml = rawHtml.replaceAll(RegExp(r'style="[^"]*"'), ''); // 移除内联样式

        // (与之前的代码相同) 准备HTML结构
        String finalHtml = """
          <!DOCTYPE html>
          <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
              body { /* 基础样式由JS注入，这里可留空或写其他必要样式 */
                 font-family: sans-serif;
                 word-wrap: break-word;
              }
              img { max-width: 100%; height: auto; display: block; }
              /* 其他样式 */
            </style>
          </head>
          <body>
            $rawHtml
          </body>
          </html>
        """;

        // 开始加载HTML，后续由NavigationDelegate处理
        _webViewController.loadHtmlString(finalHtml);

        // 注意: 不在这里设置 _isLoading = false; 等待JS通道回调
      } else if (mounted) {
         setState(() { _isLoading = false; }); // 如果没有获取到数据，停止加载
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('未能加载活动数据')),
         );
      }
    } catch (e) {
      debugPrint('获取活动详情出错：$e');
      if (mounted) {
         setState(() { _isLoading = false; }); // 出错时停止加载
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('加载活动失败: $e')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // **修改加载状态判断逻辑**：在数据加载完成且WebView准备好之前都显示加载指示器
    // 或者当 _activityDetail 为 null 时也显示加载 (因为API调用可能失败)
    final bool showLoading = _isLoading || _activityDetail == null;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // AppBar背景透明需要
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(_opacity),
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white,
        ),
        title: Text(
          widget.title, // 使用传入的标题
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity),
            fontSize: 16.sp,
          ),
        ),
      ),
      body: showLoading // 根据加载状态显示内容或指示器
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // --- Sliver 1: 顶部背景图片 ---
                SliverToBoxAdapter(
                  child: SizedBox( // 使用SizedBox替代Container如果只设置尺寸
                    width: double.infinity,
                    height: 150.h + MediaQuery.of(context).padding.top,
                    child: _buildTopBackgroundImage(context),
                  ),
                ),

                // --- Sliver 2: 活动标题和日期 ---
                SliverList( // 使用SliverList来展示标题和日期更清晰
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                      child: Text(
                        _activityDetail?['resourceTitle'] ?? '无标题活动', // 活动标题
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: HexColor('#333333'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h), // 标题和日期之间的间距
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w), // 与标题左右边距对齐
                      child: Row(
                        children: [
                          Container( // 日期前的小装饰点
                            width: 4.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: HexColor('#FFB26D'),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          // 活动有效期，处理可能的null值
                          Text(
                            '${_activityDetail?['effectiveTimeBegin'] ?? "开始时间未知"} - ${_activityDetail?['effectiveTimeEnd'] ?? "结束时间未知"}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: HexColor('#999999'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h), // 日期和下方WebView内容之间的间距 (padding在JS中设置)
                  ]),
                ),

                // --- Sliver 3: WebView 内容区域 ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    // **重点：使用从JS获取的高度 _webViewHeight**
                    height: _webViewHeight,
                    child: _isWebViewReady // 确保WebView已加载至少一次后再显示
                        ? WebViewWidget(
                            controller: _webViewController,
                            // **重要：移除手势识别器**
                            // gestureRecognizers: { ... } // 不需要了
                          )
                        : Container( // WebView未准备好时的占位符
                            alignment: Alignment.center,
                            height: _webViewHeight, // 保持高度一致避免跳动
                            // 可以选择在此处也显示加载指示器，如果需要的话
                            // child: CircularProgressIndicator(),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  // 构建顶部背景图
  Widget _buildTopBackgroundImage(BuildContext context) {
    // 使用 null-aware 操作符安全访问可能为 null 的 _activityDetail
    String imageUrl = _activityDetail?['mainPic'] ?? ""; // 获取图片URL或空字符串
    if (imageUrl.isEmpty) {
      // 如果没有图片URL，返回一个占位颜色块
      return Container(
        width: double.infinity,
        height: 150.h + MediaQuery.of(context).padding.top,
        color: Colors.grey[300], // 灰色占位
      );
    }
    // 如果有URL，加载网络图片
    return NetworkImageHelper().getCachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover, // 图片填充方式
      width: double.infinity, // 宽度撑满
      height: 150.h + MediaQuery.of(context).padding.top, // 高度计算
    );
  }
}