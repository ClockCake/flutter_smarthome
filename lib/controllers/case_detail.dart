import 'dart:async'; // 导入Completer
import 'package:flutter/foundation.dart'; // 主要为了 Factory (虽然在新版WebView中可能不再直接需要为WebView设置手势)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/dialog/appointment-dialog.dart'; // 确认弹窗路径
import 'package:flutter_smarthome/network/api_manager.dart';       // 确认ApiManager路径
import 'package:flutter_smarthome/utils/hex_color.dart';          // 确认HexColor路径
import 'package:flutter_smarthome/utils/network_image_helper.dart'; // 确认NetworkImageHelper路径
import 'package:flutter_smarthome/utils/string_utils.dart';     // 确认StringUtils路径
import 'package:webview_flutter/webview_flutter.dart';     // 导入WebView包
import 'package:oktoast/oktoast.dart';                       // 导入oktoast

class CaseDetailWidget extends StatefulWidget {
  final String title;
  final String caseId;
  const CaseDetailWidget({
    super.key,
    required this.title,
    required this.caseId,
  });

  @override
  State<CaseDetailWidget> createState() => _CaseDetailWidgetState();
}

class _CaseDetailWidgetState extends State<CaseDetailWidget> {
  // 案例详情数据，设为可空，初始为null表示未加载
  Map<String, dynamic>? _caseDetail;
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0; // AppBar透明度
  bool _isLoading = true; // 初始加载状态
  double _webViewHeight = 100.h; // WebView初始高度
  bool _isWebViewReady = false; // WebView是否已准备好

  // --- WebView 相关状态 ---
  late final WebViewController _webViewController;
  final Completer<void> _pageLoadedCompleter = Completer<void>();
  static const String _heightChannelName = 'PageHeight'; // JS通道名称

  @override
  void initState() {
    super.initState();

    // --- 初始化 WebView 控制器 (与之前案例一致) ---
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_pageLoadedCompleter.isCompleted) { _pageLoadedCompleter.complete(); }
            _injectJSForHeight(); // 页面加载完注入JS
            if (mounted) { setState(() { _isWebViewReady = true; }); }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('页面资源错误: ${error.description}');
             if (!_pageLoadedCompleter.isCompleted) { _pageLoadedCompleter.completeError(error); }
             if (mounted) { setState(() { _isLoading = false; }); } // 加载失败停止指示器
          },
        ),
      )
      ..addJavaScriptChannel(
        _heightChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          // --- 处理接收到的高度信息 (与之前案例一致) ---
          final String heightStr = message.message;
          final double? height = double.tryParse(heightStr);
          debugPrint("收到WebView高度信息: $heightStr");
          if (height != null && height > 0 && mounted) {
            final newHeight = height; // 直接使用，不再加buffer
            debugPrint("解析后高度: $newHeight");
            if ((newHeight - _webViewHeight).abs() > 1.0 || _isLoading) {
               setState(() {
                 _webViewHeight = newHeight;
                 if (_isLoading) { _isLoading = false; } // 收到有效高度后，停止加载状态
                 debugPrint("更新WebView高度为: $_webViewHeight");
               });
            } else {
              debugPrint("新高度与当前高度差别不大，不更新UI");
            }
          } else if (mounted && height == 0) {
            debugPrint("收到高度为0或解析失败");
            setState(() {
               if (_isLoading) {
                  _isLoading = false;
                  _webViewHeight = 50.h; // 给个最小高度
               }
            });
          }
        },
      );

    _scrollController.addListener(_onScroll); // 监听滚动
    _getCaseDetail(); // 获取案例详情数据
  }

  // --- 注入JS获取高度 (与之前案例一致) ---
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
          } else { console.error('JS通道 "$_heightChannelName" 未找到！'); }
          if (document.body.style.overflow !== 'hidden') {
             document.body.style.overflow = 'hidden';
             document.body.style.margin = '0';
             document.body.style.padding = '16px'; // JS设置内边距
             console.log("设置 body overflow: hidden");
          }
        }
        sendHeight("立即");
        setTimeout(function() { sendHeight("延迟300ms"); }, 300);
        setTimeout(function() { sendHeight("延迟1000ms"); }, 1000);
      } catch (e) { console.error('执行JS获取高度时出错:', e); }
    '''
       .replaceAll('\$_heightChannelName', _heightChannelName) // 替换所有占位符
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
    _scrollController.removeListener(_onScroll); // 移除滚动监听
    _scrollController.dispose(); // 释放滚动控制器
    super.dispose();
  }

  // 滚动监听，更新AppBar透明度
  void _onScroll() {
    if (!mounted) return; // 检查组件是否挂载
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    if (_opacity != opacity) {
      setState(() { _opacity = opacity; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 加载状态判断：数据未获取到(_caseDetail为null) 或 正在加载中(_isLoading为true)
    final bool showLoading = _isLoading || _caseDetail == null;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // AppBar背景透明
      appBar: AppBar(
        elevation: 0, // 无阴影
        backgroundColor: Colors.white.withOpacity(_opacity), // 根据滚动改变透明度
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white, // 图标颜色变化
        ),
        title: Text(
          widget.title, // 使用传入的页面标题
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity), // 标题颜色变化
            fontSize: 16.sp, // 调整标题字体大小
          ),
        ),
      ),
      body: showLoading
          ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
          : CustomScrollView( // 使用CustomScrollView实现复杂滚动效果
              controller: _scrollController,
              slivers: [
                // --- Sliver 1: 顶部背景图片 ---
                SliverToBoxAdapter(
                  child: _buildTopBackgroundImage(context), // 构建顶部图片
                ),

                // --- Sliver 2: 案例标题 ---
                SliverToBoxAdapter( // 或者用 SliverPadding + SliverToBoxAdapter
                   child: Padding(
                     padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 10.h), // 调整间距
                     child: Text(
                       _caseDetail?['caseTitle'] ?? '案例标题加载中...', // 显示案例标题，处理null
                       style: TextStyle(
                         fontSize: 18.sp,
                         color: HexColor('#333333'),
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                 ),

                 // --- Sliver 3: 设计师信息 ---
                 SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildPersonalInfo(), // 构建设计师信息区域
                    ),
                 ),

                 // --- Sliver 4: 案例基本信息 ---
                 SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h), // 调整间距
                      child: _buildCaseInfo(), // 构建案例基本信息区域
                    ),
                 ),

                 // --- Sliver 5: "设计简介"标题 ---
                 SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h, bottom: 4.h), // 调整间距
                      child: Text(
                        '设计简介',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: HexColor('#333333'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                 ),

                // --- Sliver 6: WebView 内容区域 ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: _webViewHeight, // 使用动态获取的高度
                    child: _isWebViewReady // 确保WebView准备好再渲染
                        ? WebViewWidget(
                            controller: _webViewController,
                            // 不需要 gestureRecognizers
                          )
                        : Container( // 占位符
                            alignment: Alignment.center,
                            height: _webViewHeight,
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  // 构建顶部背景图片 Widget
  Widget _buildTopBackgroundImage(BuildContext context) {
    // 默认图片URL，以防API数据中没有图片
    const String defaultImage = 'https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png';

    // 安全地从 _caseDetail 获取图片列表
    List<String> pics = []; // 初始化为空列表
    final dynamic caseMainPicData = _caseDetail?['caseMainPic'];
    if (caseMainPicData is List) {
      // 确认是List类型再进行转换
      try {
        pics = List<String>.from(caseMainPicData.where((item) => item is String));
      } catch (e) {
        debugPrint("解析 caseMainPic 出错: $e");
        pics = []; // 出错则置为空
      }
    }

    // 如果列表为空或没有获取到数据，使用默认图片，否则使用第一张
    final String imageUrl = pics.isEmpty ? defaultImage : pics.first;

    // 返回包含网络图片的 SizedBox
    return SizedBox(
      width: double.infinity,
      // 高度包含状态栏高度
      height: 150.h + MediaQuery.of(context).padding.top,
      child: NetworkImageHelper().getCachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover, // 图片填充方式
      ),
    );
  }

  // 构建设计师个人信息区域 Widget
  Widget _buildPersonalInfo() {
    // 安全地获取设计师擅长风格列表
    List<String> excelStyles = [];
    final dynamic excelStyleData = _caseDetail?['excelStyle'];
    if (excelStyleData is List) {
      try {
         excelStyles = List<String>.from(excelStyleData.where((item) => item is String));
      } catch (e) {
         debugPrint("解析 excelStyle 出错: $e");
      }
    }

    // 准备显示的文本信息
    final String styleText = excelStyles.isEmpty ? "" : StringUtils.joinList(excelStyles); // 擅长风格
    final String caseCountText = StringUtils.formatDisplay(
      _caseDetail?['caseNumber'], // 案例数量
      prefix: '案例作品',
      suffix: '套',
      defaultValue: '案例作品 N/A 套', // 处理null或无效值
    );
    // 组合风格和案例数量文本，只有风格不为空时才加分隔符
    final String combinedInfo = styleText.isNotEmpty
        ? '$styleText | $caseCountText'
        : caseCountText;

    // 返回 Row 布局
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // 主轴对齐方式
      crossAxisAlignment: CrossAxisAlignment.center, // 交叉轴对齐方式
      children: [
        // 设计师头像
        ClipOval( // 圆形裁剪
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: _caseDetail?['avatar'] ?? 'https://fileserver.gazolife.cn/2025/4/20250423_40d0c34c94ee99542fd4e8fe127681ce_20250423104550A695.png', // 头像URL，处理null
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
            // 可以添加 placeholder 或 errorWidget
          ),
        ),
        SizedBox(width: 12.w), // 头像和文字间距
        // 设计师姓名和信息
        Expanded( // 使用Expanded占据剩余空间，避免长文本溢出
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 文字左对齐
            children: [
              Text(
                _caseDetail?['realName'] ?? '设计师', // 姓名，处理null
                style: TextStyle(
                  fontSize: 15.sp,
                  color: HexColor('#222222'),
                  fontWeight: FontWeight.w500, // 加一点粗细
                ),
                maxLines: 1, // 最多一行
                overflow: TextOverflow.ellipsis, // 溢出显示省略号
              ),
              SizedBox(height: 4.h), // 姓名和下方信息间距
              Text(
                combinedInfo, // 显示组合后的信息
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#999999'),
                ),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w), // 信息和按钮间距
        // 预约按钮
        InkWell( // 添加点击波纹效果
          onTap: _showDialog, // 点击时显示弹窗
          borderRadius: BorderRadius.circular(14.w), // 匹配按钮圆角
          child: Container(
            width: 56.w,
            height: 28.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black, // 背景色
              borderRadius: BorderRadius.circular(14.w), // 圆角
            ),
            child: Text(
              '预约',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white, // 文字颜色
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建案例基本信息区域 Widget
  Widget _buildCaseInfo() {
    // 安全地获取设计风格列表
    List<String> designStyles = [];
    final dynamic designStyleData = _caseDetail?['designStyle'];
     if (designStyleData is List) {
        try {
           designStyles = List<String>.from(designStyleData.where((item) => item is String));
        } catch (e) {
           debugPrint("解析 designStyle 出错: $e");
        }
     }
    // 使用 '、' 连接设计风格
    final String styleText = StringUtils.joinList(designStyles, separator: '、');

    // 返回信息容器
    return Container(
      width: double.infinity, // 宽度撑满
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w), // 内边距
      decoration: BoxDecoration(
        color: HexColor('#F8F8F8'), // 背景色
        borderRadius: BorderRadius.circular(4.w), // 圆角
      ),
      child: IntrinsicHeight( // 让分隔线与内容等高
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子项均匀分布
          children: [
            // 户型信息列
            _buildInfoColumn('户型', _caseDetail?['householdType'] ?? 'N/A'),
            // 分隔线
            _buildVerticalDivider(),
            // 建筑面积列
            _buildInfoColumn(
              '建筑面积',
              StringUtils.formatDisplay(
                _caseDetail?['area'],
                suffix: '㎡',
                defaultValue: 'N/A', // 处理null或无效值
              ),
            ),
            // 分隔线
            _buildVerticalDivider(),
            // 设计风格列
            _buildInfoColumn('设计风格', styleText.isNotEmpty ? styleText : 'N/A'),
          ],
        ),
      ),
    );
  }

  // 辅助方法：构建信息列 (用于户型、面积、风格)
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),
        ),
        SizedBox(height: 4.h), // 标签和值之间的间距
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),
           maxLines: 1, // 最多一行
           overflow: TextOverflow.ellipsis, // 超出显示省略号
        ),
      ],
    );
  }

  // 辅助方法：构建垂直分隔线
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      // height: 24.w, // 高度由IntrinsicHeight控制
      color: HexColor('#EEEEEE'), // 分隔线颜色
      margin: EdgeInsets.symmetric(horizontal: 8.w), // 水平间距，根据需要调整
    );
  }


  // 显示预约弹窗
  void _showDialog() {
    // 检查mounted状态，虽然show方法通常自己会处理
    if (!mounted) return;
    AppointmentBottomSheet.show(
      context,
      onSubmit: (name, contact) {
        // 回调中通常不需要再次检查mounted，因为是同步执行的
        debugPrint('预约姓名: $name, 联系方式: $contact');
        _handleSubmit(name, contact); // 调用提交方法
      },
    );
  }

  // 获取案例详情数据的异步方法
  Future<void> _getCaseDetail() async {
    // 初始 _isLoading 为 true，无需再次设置
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/cases/detail', // API端点
        queryParameters: { 'id': widget.caseId }, // 查询参数
      );
      // 检查组件是否仍然挂载以及响应是否有效
      if (response != null && mounted) {
        setState(() {
          _caseDetail = response; // 更新状态
          // 注意：加载HTML的操作现在移到这里触发
          String rawHtml = _caseDetail?['caseInfo'] ?? '';
          // String cleanHtml = rawHtml.replaceAll(RegExp(r'style="[^"]*"'), '');
          String finalHtml = """
            <!DOCTYPE html><html><head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>body{font-family: sans-serif; word-wrap: break-word;} img{max-width: 100%; height: auto; display: block;}</style>
            </head><body>$rawHtml</body></html>
          """;
           _webViewController.loadHtmlString(finalHtml); // 加载HTML
        });
      } else if (mounted) {
         // 如果响应为空或组件已卸载
         setState(() { _isLoading = false; }); // 停止加载状态
         debugPrint("获取案例详情失败或组件已卸载");
      }
    } catch (e) {
      debugPrint('获取案例详情API调用出错：$e');
      if (mounted) {
        setState(() { _isLoading = false; }); // API出错也停止加载
        // 可以考虑显示错误提示
        // showToast('加载案例详情失败: $e');
      }
    }
  }

  // 处理预约提交的异步方法
  void _handleSubmit(String name, String contact) async {
     // 可以考虑在这里添加一个加载指示器
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home/overall/quick/appointment', // 提交API端点
        data: { 'userName': name, 'userPhone': contact }, // 提交数据
      );
      // 检查组件是否仍然挂载
      if (mounted) {
        if (response != null) {
           // 提交成功提示
           showToast('预约成功');
           // 可以在这里关闭弹窗或执行其他操作
        } else {
           // 处理提交失败的情况
           showToast('预约失败，请稍后重试');
        }
      }
    } catch (e) {
      debugPrint('预约提交API调用出错：$e');
      if (mounted) {
         // API调用出错提示
         showToast('预约服务出错: $e');
      }
    } finally {
       // 无论成功或失败，都可以在这里移除加载指示器
    }
  }
}