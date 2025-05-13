import 'dart:async'; // 导入Completer
import 'package:flutter/foundation.dart'; // 主要为了 Factory，虽然在这个版本中可能不需要了
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:webview_flutter/webview_flutter.dart'; // 导入WebView包

class ArticleDetailWidget extends StatefulWidget {
  final String title;
  final String articleId;
  const ArticleDetailWidget({
    super.key,
    required this.title,
    required this.articleId,
  });

  @override
  State<ArticleDetailWidget> createState() => _ArticleDetailWidgetState();
}

class _ArticleDetailWidgetState extends State<ArticleDetailWidget> {
  Map<String, dynamic> _articleDetail = {};
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;
  bool _isLoading = true; // 初始时显示加载指示器
  double _webViewHeight = 100.h; // WebView的初始高度，可以设为一个较小的值或加载指示器的高度
  bool _isWebViewReady = false; // 标记WebView是否已准备好并加载了内容

  // WebView控制器
  late final WebViewController _webViewController;
  // 用于确保JS在页面加载完成后执行
  final Completer<void> _pageLoadedCompleter = Completer<void>();

  // JavaScript通道名称，用于从JS接收高度
  static const String _heightChannelName = 'PageHeight';

  @override
  void initState() {
    super.initState();

    // 初始化WebView控制器
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 启用JS执行
      ..setBackgroundColor(Colors.white) // 设置背景色以匹配Scaffold
      // **重要：设置导航代理以监听页面加载完成事件**
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // 页面加载完成，通知Completer
             if (!_pageLoadedCompleter.isCompleted) {
               _pageLoadedCompleter.complete();
             }
            // 页面加载完成后，执行JS获取高度并禁用滚动
            _injectJSForHeight();
            if (mounted) {
              setState(() {
                _isWebViewReady = true; // WebView准备就绪
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // 处理加载错误
            debugPrint('''
              页面资源错误:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
             if (!_pageLoadedCompleter.isCompleted) {
               _pageLoadedCompleter.completeError(error); // 出错时完成Completer
             }
             if (mounted) {
               setState(() {
                 _isLoading = false; // 加载失败也停止指示器
               });
             }
          },
        ),
      )
// **重要：添加JavaScript通道以接收消息**
      ..addJavaScriptChannel(
        _heightChannelName, // 与JS中使用的通道名称匹配
        onMessageReceived: (JavaScriptMessage message) {
          // 收到从JS发送过来的高度信息
          final String heightStr = message.message;
          final double? height = double.tryParse(heightStr);
          debugPrint("收到WebView高度信息: $heightStr"); // 打印原始字符串

          if (height != null && height > 0 && mounted) {
            // **移除 + 16.0 的缓冲区**
            final newHeight = height;
            debugPrint("解析后高度: $newHeight");

            // 只有当新高度与当前高度显著不同时才更新，避免不必要的重绘
            // 可以设置一个阈值，例如相差超过 1px 才更新
            if ((newHeight - _webViewHeight).abs() > 1.0 || _isLoading) {
               setState(() {
                 _webViewHeight = newHeight;
                 // 收到有效高度后，可以认为加载完成
                 // 只有在 _isLoading 为 true 时才设置为 false，避免后续更新再次触发
                 if (_isLoading) {
                   _isLoading = false;
                 }
                 debugPrint("更新WebView高度为: $_webViewHeight");
               });
            } else {
               debugPrint("新高度 $newHeight 与当前高度 $_webViewHeight 差别不大，不更新UI");
            }
          } else if (mounted && height == 0) {
            // 如果收到高度为0，可能内容为空或计算出错，停止加载，使用默认或小高度
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

    _scrollController.addListener(_onScroll);
    _getArticleDetail(); // 开始获取文章数据
  }

// 注入并执行用于获取高度和禁用滚动的JS代码
  Future<void> _injectJSForHeight() async {
    // JS代码：获取文档总高度，并通过通道发送回Flutter，然后禁用body滚动
    // 改为主要使用 document.body.scrollHeight
    String jsCode = '''
      try {
        // 定义发送高度的函数
        function sendHeight(source) {
          // **尝试使用 body.scrollHeight，如果为0或很小，再尝试 documentElement**
          let height = document.body.scrollHeight;
          if (!height || height < 50) { // 如果body高度不合理，尝试documentElement
              height = document.documentElement.scrollHeight;
          }
          
          console.log(source + " 计算高度: " + height); // 增加日志，方便调试

          // 通过通道将高度发送回Flutter
          if (window.$_heightChannelName && window.$_heightChannelName.postMessage) {
            window.$_heightChannelName.postMessage(height.toString());
            console.log(source + " 发送高度: " + height);
          } else {
             console.error('JavaScript通道 "$_heightChannelName" 未找到！');
          }
          
          // 禁用body滚动（确保只执行一次或效果可叠加）
          if (document.body.style.overflow !== 'hidden') {
             document.body.style.overflow = 'hidden';
             document.body.style.margin = '0'; 
             document.body.style.padding = '16px'; // 依然在JS里设置内边距
             console.log("设置 body overflow: hidden");
          }
        }

        // 1. 页面加载后立即尝试发送一次高度
        sendHeight("立即");

        // 2. 延迟一段时间（例如 300ms）再发送一次高度，给图片等资源加载时间
        //    Flutter 端接收到后会再次 setState 更新高度
        setTimeout(function() {
            sendHeight("延迟300ms");
        }, 300);
        
        // 3. （可选）更长时间后再次尝试，捕获更慢的加载
        setTimeout(function() {
            sendHeight("延迟1000ms");
        }, 1000);


      } catch (e) {
         console.error('执行JS获取高度时出错:', e);
      }
    ''';
    
    // 替换所有通道名称占位符
    jsCode = jsCode.replaceAll('\$_heightChannelName', _heightChannelName)
                   .replaceAll('\$_heightChannelName', _heightChannelName)
                   .replaceAll('\$_heightChannelName', _heightChannelName);


    try {
       // 等待页面基本加载完成
       await _pageLoadedCompleter.future;
       // 执行JS
       await _webViewController.runJavaScript(jsCode);
       debugPrint("已注入并执行(含延迟的)获取高度的JS");
    } catch (e) {
       debugPrint("执行JS时出错: $e");
       if (mounted) {
         setState(() {
           _isLoading = false; // JS执行出错也停止加载
           _webViewHeight = 100.h; // 出错时给个默认高度
         });
       }
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听，更新AppBar透明度
  void _onScroll() {
    if (!mounted) return;
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    // 避免在高度计算完成前因滚动触发不必要的setState
    if (_opacity != opacity) {
       setState(() {
         _opacity = opacity;
       });
    }
  }

  // 获取文章详情数据
  Future<void> _getArticleDetail() async {
    // 已经是loading状态，不需要再次setState
    // setState(() { _isLoading = true; });
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/article/detail', // 确认API端点路径是否正确
        queryParameters: {'id': widget.articleId},
      );
      if (response != null && mounted) {
        _articleDetail = response;

        // 准备HTML给WebView
        String rawHtml = _articleDetail['resourceInfo'] ?? '';

        // **重要：准备HTML结构，viewport必须有，样式可以通过JS注入或在这里添加基础样式**
        String finalHtml = """
          <!DOCTYPE html>
          <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
              /* 基础样式：可以在这里设置，也可以完全依赖JS注入的样式 */
              body {
                /* margin: 0; */ /* 改为在JS中设置 */
                /* padding: 16px; */ /* 改为在JS中设置 */
                font-family: sans-serif; /* 设置默认字体 */
                word-wrap: break-word; /* 允许长单词换行 */
              }
              img { 
                max-width: 100%; /* 图片自适应宽度 */
                height: auto; 
                display: block; /* 避免图片下方多余空隙 */
              }
              /* 其他你需要的全局样式 */
            </style>
          </head>
          <body>
            $rawHtml
          </body>
          </html>
        """;

        // 使用loadHtmlString加载准备好的HTML
        // 注意：这里不直接await，因为加载过程由NavigationDelegate监听
         _webViewController.loadHtmlString(finalHtml);

      } else if (mounted) {
        // 如果response为空或组件已卸载
        setState(() {
           _isLoading = false; // 没有数据也停止加载
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未能加载文章数据')),
        );
      }
    } catch (e) {
      debugPrint('获取文章详情出错：$e');
      if (mounted) {
         setState(() {
           _isLoading = false; // 出错停止加载
         });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('加载文章失败: $e')),
         );
      }
    }
    // 注意： _isLoading 的状态现在主要由JS通道回调来控制，确保在收到高度后再设为false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // AppBar背景透明需要这个
      appBar: AppBar(
        elevation: 0, // 无阴影
        backgroundColor: Colors.white.withOpacity(_opacity), // 根据滚动改变透明度
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white, // 图标颜色根据透明度改变
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity), // 标题颜色根据透明度改变
            fontSize: 16.sp,
          ),
        ),
      ),
      // 使用三元运算符根据加载状态显示内容或指示器
      body: _isLoading && !_isWebViewReady // 在获取数据或WebView未准备好时显示加载动画
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController, // 绑定滚动控制器
              slivers: [
                // 顶部背景图片
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    height: 150.h + MediaQuery.of(context).padding.top, // 考虑状态栏高度
                    child: _buildTopBackgroundImage(context),
                  ),
                ),

                // 文章标题和发布时间
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                      child: Text(
                        _articleDetail['resourceTitle'] ?? '无标题', // 显示标题或默认值
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: HexColor('#333333'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: HexColor('#FFB26D'),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${_articleDetail['createTime'] ?? '未知日期'}', // 显示时间或默认值
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: HexColor('#999999'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 移除这里的SizedBox间距，因为内边距已由JS注入的body padding处理
                    // SizedBox(height: 16.h),
                  ]),
                ),

                // --- WebView 内容区域 ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    // **重点：使用从JS获取的高度 _webViewHeight**
                    height: _webViewHeight,
                    child: _isWebViewReady // 确保WebView已加载至少一次后再显示，避免空白或错误
                      ? WebViewWidget(
                          controller: _webViewController,
                          // **重要：移除手势识别器**
                          // 因为WebView内部滚动已被禁用，不需要它来竞争手势了
                          // gestureRecognizers: {
                          //  Factory<VerticalDragGestureRecognizer>(
                          //    () => VerticalDragGestureRecognizer(),
                          //  ),
                          //},
                        )
                      : Container( // WebView未准备好时可以显示占位符或保持之前的加载指示器
                          alignment: Alignment.center,
                          height: 100.h, // 给个初始占位高度
                          child: _isLoading ? const CircularProgressIndicator() : null,
                        ),
                  ),
                ),
              ],
            ),
    );
  }

  // 构建顶部背景图 (保持不变)
  Widget _buildTopBackgroundImage(BuildContext context) {
    String imageUrl = _articleDetail['mainPic'] ?? "";
    if (imageUrl.isEmpty) {
      return Container(color: Colors.grey[300]); // 无图时显示灰色背景
    }
    return NetworkImageHelper().getCachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 150.h + MediaQuery.of(context).padding.top,
    );
  }
}