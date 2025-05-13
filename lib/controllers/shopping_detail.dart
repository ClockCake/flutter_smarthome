import 'dart:async'; // 导入Completer
import 'dart:ffi'; // 注意：dart:ffi通常用于与C代码交互，这里似乎未使用，可以考虑移除除非确实需要

import 'package:card_swiper/card_swiper.dart'; // 轮播图库
import 'package:flutter/foundation.dart';     // 为了 Factory (虽然在新版WebView中可能不再直接需要为WebView设置手势)
import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart'; // 不需要显式导入
// import 'package:flutter/src/widgets/placeholder.dart'; // 不需要显式导入
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 以下是你的项目特定导入，请确保路径正确
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:flutter_smarthome/controllers/shopping_business.dart';
import 'package:flutter_smarthome/controllers/shopping_car_list.dart';
import 'package:flutter_smarthome/controllers/shopping_cart_sku.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';
import 'package:oktoast/oktoast.dart';             // Toast库
import 'package:webview_flutter/webview_flutter.dart'; // WebView库

class ShoppingDetailPageWidget extends StatefulWidget {
  final String commodityId; // 商品ID

  // 构造函数
  const ShoppingDetailPageWidget({Key? key, required this.commodityId}) : super(key: key);

  @override
  State<ShoppingDetailPageWidget> createState() => _ShoppingDetailPageWidgetState();
}

class _ShoppingDetailPageWidgetState extends State<ShoppingDetailPageWidget> {
  final ScrollController _scrollController = ScrollController(); // 页面滚动控制器
  double _opacity = 0.0; // AppBar 透明度
  Map<String, dynamic>? _shoppingDetail; // 商品详情数据，改为可空
  List<String> imageList = []; // Banner图片URL数组
  late bool isLogin; // 用户是否登录

  // --- WebView 相关状态 ---
  bool _isLoading = true; // 初始加载状态 (数据获取 + WebView准备)
  double _webViewHeight = 100.h; // WebView初始高度
  bool _isWebViewReady = false; // WebView是否已准备好加载内容

  late final WebViewController _webViewController; // WebView控制器
  final Completer<void> _pageLoadedCompleter = Completer<void>(); // 页面加载完成信号
  static const String _heightChannelName = 'PageHeight'; // JS通道名称

  @override
  void initState() {
    super.initState();
    // 获取当前登录状态
    isLogin = UserManager.instance.isLoggedIn;
    // 添加滚动监听
    _scrollController.addListener(_onScroll);

    // --- 初始化 WebView 控制器 (与之前案例一致) ---
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 启用JS
      ..setBackgroundColor(Colors.white) // 背景设为白色
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // 页面加载完成回调
            if (!_pageLoadedCompleter.isCompleted) { _pageLoadedCompleter.complete(); }
            _injectJSForHeight(); // 注入JS获取高度
            if (mounted) { setState(() { _isWebViewReady = true; }); } // 标记WebView准备就绪
          },
          onWebResourceError: (WebResourceError error) {
            // 网页资源加载错误处理
            debugPrint('页面资源错误: ${error.description}');
             if (!_pageLoadedCompleter.isCompleted) { _pageLoadedCompleter.completeError(error); }
             if (mounted) { setState(() { _isLoading = false; }); } // 错误也停止加载指示
          },
        ),
      )
      ..addJavaScriptChannel(
        _heightChannelName, // 注册JS通道
        onMessageReceived: (JavaScriptMessage message) {
          // --- 处理从JS接收到的高度信息 (与之前案例一致) ---
          final String heightStr = message.message;
          final double? height = double.tryParse(heightStr);
          debugPrint("收到WebView高度信息: $heightStr");
          if (height != null && height > 0 && mounted) {
            final newHeight = height; // 直接使用高度
            debugPrint("解析后高度: $newHeight");
            // 高度变化较大或仍在加载时更新UI
            if ((newHeight - _webViewHeight).abs() > 1.0 || _isLoading) {
               setState(() {
                 _webViewHeight = newHeight;
                 if (_isLoading) { _isLoading = false; } // 收到有效高度，停止整体加载状态
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

    // 开始获取商品详情数据
    _getShoppingDetail();
  }

  // --- 注入JS获取高度 (与之前案例一致) ---
  Future<void> _injectJSForHeight() async {
    // JS 代码，获取body高度，禁用滚动，通过通道发回 Flutter
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
       .replaceAll('\$_heightChannelName', _heightChannelName) // 替换所有通道名称占位符
       .replaceAll('\$_heightChannelName', _heightChannelName)
       .replaceAll('\$_heightChannelName', _heightChannelName);

    try {
       await _pageLoadedCompleter.future; // 等待页面基础加载完成
       await _webViewController.runJavaScript(jsCode); // 执行JS
       debugPrint("已注入并执行(含延迟的)获取高度的JS");
    } catch (e) {
       debugPrint("执行JS时出错: $e");
       if (mounted) {
         setState(() {
           // JS出错也需要停止加载状态，并给WebView一个默认高度
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
    // WebViewController 在新版本中通常不需要手动 dispose
    super.dispose();
  }

  // 滚动监听回调，更新AppBar透明度
  void _onScroll() {
    if (!mounted) return; // 检查组件是否挂载
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    if (_opacity != opacity) {
      setState(() { _opacity = opacity; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 加载状态判断：数据未获取(_shoppingDetail为null) 或 正在加载中(_isLoading为true)
    final bool showLoading = _isLoading || _shoppingDetail == null;

    return Scaffold(
      backgroundColor: Colors.white, // 页面背景色
      extendBodyBehindAppBar: true, // AppBar背景透明需要
      appBar: AppBar(
        elevation: 0, // 无阴影
        backgroundColor: Colors.white.withOpacity(_opacity), // 根据滚动改变透明度
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white, // 图标颜色变化
        ),
        title: Text(
          // 商品详情页通常不在AppBar显示标题，或者显示 '商品详情'
          _opacity >= 0.5 ? (_shoppingDetail?['name'] ?? '商品详情') : '', // 滚动后显示商品名
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity), // 标题颜色变化
            fontSize: 16.sp,
          ),
        ),
      ),
      body: showLoading
          ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
          : CustomScrollView( // 使用CustomScrollView实现复杂滚动效果
              controller: _scrollController,
              slivers: [
                // --- Sliver 1: 顶部轮播图 ---
                SliverToBoxAdapter(
                  child: Container(
                    // 高度应适应轮播图内容，加上可能的顶部安全区域
                    height: 250.h + MediaQuery.of(context).padding.top,
                    // color: Colors.blue, // 测试背景色
                    child: _buildBanner(), // 构建轮播图
                  ),
                ),

                // --- Sliver 2: 商品基本信息 (价格、名称、商家) ---
                 SliverList(
                   delegate: SliverChildListDelegate([
                     SizedBox(height: 20.h), // 与轮播图间距
                     // 价格与积分行
                     Padding(
                       padding: EdgeInsets.symmetric(horizontal: 16.w),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.baseline, // 基线对齐
                         textBaseline: TextBaseline.alphabetic, // 设置基线类型
                         children: [
                           Text(
                             '¥ ${_shoppingDetail?['minPrice'] ?? 'N/A'}', // 最小价格，处理null
                             style: TextStyle(color: HexColor('#222222'), fontSize: 20.sp, fontWeight: FontWeight.bold), // 价格字体稍大
                           ),
                           SizedBox(width: 8.w),
                           Text(
                             '积分 ${_shoppingDetail?['minPointPrice'] ?? 'N/A'}', // 最小积分，处理null
                             style: TextStyle(color: HexColor('#CA9C72'), fontSize: 12.sp),
                           ),
                         ],
                       ),
                     ),
                     // 商品名称
                     Padding(
                       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0.h), // 调整间距
                       child: Text(
                         _shoppingDetail?['name'] ?? "商品名称加载中...", // 商品名，处理null
                         style: TextStyle(color: HexColor('#222222'), fontSize: 16.sp, fontWeight: FontWeight.w500), // 字体加粗一点
                         maxLines: 2, // 最多显示两行
                         overflow: TextOverflow.ellipsis, // 超出显示省略号
                       ),
                     ),
                     SizedBox(height: 12.h), // 名称与商家信息间距
                     // 商家信息行 (可点击)
                     InkWell( // 使用InkWell添加点击效果
                       onTap: () {
                         // 点击跳转到商家页面，确保数据有效
                         final String? businessId = _shoppingDetail?['businessId']?.toString();
                         final String? businessName = _shoppingDetail?['businessName']?.toString();
                         final String? businessLogo = _shoppingDetail?['businessLogo']?.toString();
                         if (businessId != null && businessName != null && businessLogo != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              ShoppingBusinessWidget(businessId: businessId, businessName: businessName, businessLogo: businessLogo)
                            ));
                         } else {
                           debugPrint("商家信息不完整，无法跳转");
                           showToast("无法打开商家页面");
                         }
                       },
                       child: Padding(
                         padding: EdgeInsets.symmetric(horizontal: 16.w),
                         child: Row(
                           children: [
                              // 商家Logo (如果需要显示)
                             _shoppingDetail?['businessLogo'] != null ?
                             Padding(
                               padding: EdgeInsets.only(right: 4.w),
                               child: NetworkImageHelper().getCachedNetworkImage(
                                  imageUrl: _shoppingDetail!['businessLogo'], // 确认非空后访问
                                  width: 18.w,
                                  height: 18.h,
                                  // 可以添加占位图或错误图
                               ),
                             ) : SizedBox.shrink(), // 如果Logo URL为空则不显示
                             // 商家名称
                             Expanded( // 允许商家名称换行或省略
                               child: Text(
                                  _shoppingDetail?['businessName'] ?? "商家信息加载中...", // 商家名，处理null
                                  style: TextStyle(color: HexColor('#666666'), fontSize: 12.sp), // 颜色稍浅
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             Icon(Icons.arrow_forward_ios, size: 12.sp, color: HexColor('#999999')), // 向右小箭头
                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: 12.h), // 商家信息下方间距
                   ]),
                 ),

                 // --- Sliver 3: 分隔区域 ---
                 SliverToBoxAdapter(
                   child: Container(
                     width: double.infinity,
                     height: 8.h, // 分隔区域高度
                     color: HexColor('#F8F8F8'), // 分隔区域颜色
                   ),
                 ),

                 // --- (注释掉的) 选择参数区域 ---
                 // SliverToBoxAdapter(
                 //   child: Container(
                 //     width: double.infinity,
                 //     height: 52.h,
                 //     color: Colors.white,
                 //     child: InkWell( // 使用InkWell方便添加点击事件
                 //       onTap: () {
                 //         // 点击选择参数的逻辑
                 //         // 可以考虑弹出底部弹窗或跳转页面
                 //       },
                 //       child: Padding(
                 //         padding: EdgeInsets.symmetric(horizontal: 16.w),
                 //         child: Row(
                 //           children: [
                 //             Text('参数', style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                 //             Spacer(),
                 //             Text('选择参数 ', style: TextStyle(color: HexColor('#222222'), fontSize: 14.sp)),
                 //             Icon(Icons.arrow_forward_ios, size: 16.sp, color: HexColor('#999999')),
                 //           ],
                 //         ),
                 //       ),
                 //     ),
                 //   ),
                 // ),
                 // --- (注释掉的) 参数区域下方的分隔 ---
                 // SliverToBoxAdapter(
                 //   child: Container(
                 //     width: double.infinity,
                 //     height: 8.h,
                 //     color: HexColor('#F8F8F8'),
                 //   ),
                 // ),


                 // --- Sliver 4: "商品详情" 标题 ---
                 SliverToBoxAdapter(
                   child: Padding(
                     padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h), // 调整间距
                     child: Text(
                       '商品详情',
                       style: TextStyle(color: HexColor('#222222'), fontSize: 16.sp, fontWeight: FontWeight.bold),
                     ),
                   ),
                 ),

                // --- Sliver 5: WebView 内容区域 ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: _webViewHeight, // 使用动态获取的高度
                    // color: Colors.green, // 测试背景色
                    child: _isWebViewReady // 确保WebView准备好再渲染
                        ? WebViewWidget(
                            controller: _webViewController,
                            // 不需要 gestureRecognizers
                          )
                        : Container( // 占位符，可以显示加载指示器或骨架屏
                            alignment: Alignment.center,
                            height: _webViewHeight, // 保持高度一致
                            // child: CircularProgressIndicator(), // 可选的加载指示
                          ),
                  ),
                ),
              ],
            ),
      // 底部导航栏 (收藏、购物车、加入购物车、立即购买)
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // 构建顶部轮播图 Widget
  Widget _buildBanner() {
    // 如果图片列表为空，显示占位符或加载指示
    if (imageList.isEmpty) {
      return Container(
        color: Colors.grey[200], // 浅灰色背景
        alignment: Alignment.center,
        // child: Text('图片加载中...'), // 可以放文字或指示器
      );
    }
    // 使用 card_swiper 构建轮播图
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        final item = imageList[index];
        // 使用 ClipRRect 添加圆角 (如果需要的话)
        // return ClipRRect(
        //   borderRadius: BorderRadius.circular(0), // Banner通常不需要圆角
        return NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item,
            fit: BoxFit.cover, // 图片填充方式
            // 可以添加 placeholder 和 errorWidget
          );
        // );
      },
      autoplay: true, // 自动播放
      itemCount: imageList.length, // 图片数量
      // viewportFraction: 1.0, // 每页占满宽度
      // scale: 1.0, // 不缩放
      // pagination: SwiperPagination( // 添加分页指示器 (小圆点)
      //    builder: DotSwiperPaginationBuilder(
      //      color: Colors.grey[400], // 未选中颜色
      //      activeColor: Theme.of(context).primaryColor, // 选中颜色
      //      size: 8.0, // 点的大小
      //      activeSize: 10.0, // 选中点的大小
      //    )
      // ),
      // control: SwiperControl(), // 添加左右箭头 (如果需要)
      onIndexChanged: (index) {
        // 轮播图切换时的回调
      },
    );
  }

  // 弹出底部弹窗 (用于登录或选择SKU)
  void _jumpToPage(int type, BuildContext contexts) {
    // 检查mounted状态
    if (!mounted) return;

    showModalBottomSheet(
      context: context, // 使用 build 方法传入的 context
      backgroundColor: Colors.transparent, // 背景透明，由子Widget控制背景
      isScrollControlled: true, // 允许内容滚动且高度可变
      shape: RoundedRectangleBorder( // 顶部圆角
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) { // 使用 modalContext
        // 未登录时，显示登录页
        if (!isLogin) {
          // 包裹一层，设置背景色和圆角，模拟弹窗效果
          return Container(
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
             ),
             // 限制最大高度，并允许内容滚动
             constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalContext).size.height * 0.8, // 限制最大高度为屏幕80%
             ),
             // 使用 MediaQuery 获取安全区域 padding
             padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom), // 处理键盘弹出
             child: LoginPage(onLoginSuccess: () {
               // 登录成功回调
               Navigator.pop(modalContext); // 关闭登录弹窗
               // 刷新当前页面状态，更新登录状态和可能依赖登录状态的数据
               setState(() {
                 isLogin = true;
               });
               _getShoppingDetail(); // 重新获取详情（可能包含购物车、收藏数量等）
            }),
          );
        } else {
          // 已登录时，显示SKU选择弹窗
          // 注意：确保 ShoppingCartSkuPopupWidget 内部处理了背景和圆角
          return ShoppingCartSkuPopupWidget(
            commodityId: widget.commodityId,
            type: type, // 1: 加入购物车, 2: 立即购买
            name: _shoppingDetail?['name'] ?? '', // 商品名称
            onCartSuccess: () {
              // 添加购物车或立即购买后续操作成功的回调
              Navigator.pop(modalContext); // 关闭SKU弹窗
              // 重新获取详情，更新购物车数量等
              _getShoppingDetail();
            },
          );
        }
      },
    );
  }

  // 构建底部导航栏 (操作按钮)
  Widget _buildBottomNavigationBar(BuildContext context) {
    // 获取底部安全区域高度
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      // 高度包含按钮本身高度和底部安全区域
      height: 60.h + bottomPadding,
      // 仅在内容区域应用内边距
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 8.h + bottomPadding // 底部内边距包含安全区域
      ),
      decoration: BoxDecoration(
        color: Colors.white, // 背景色
        // 可以添加顶部边框或阴影
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        // boxShadow: [ BoxShadow(...) ]
      ),
      child: Row(
        children: [
          // --- 收藏按钮 ---
          _buildBottomIcon(
            iconPath: (_shoppingDetail?['isCollection'] ?? "").isNotEmpty
                ? 'assets/images/icon_shopping_star_selected.png' // 已收藏图标
                : 'assets/images/icon_shopping_star.png', // 未收藏图标
            label: '${_shoppingDetail?['userCollectionCount'] ?? 0}', // 收藏数量
            onTap: () {
              if (!isLogin) { // 未登录提示
                showToast('请先登录');
                _jumpToPage(0, context); // 弹出登录
                return;
              }
              // 根据当前收藏状态调用添加或取消收藏
              (_shoppingDetail?['isCollection'] ?? "").isNotEmpty
                  ? _cancelCollection()
                  : _addCollection();
            },
          ),
          SizedBox(width: 24.w), // 图标按钮间距调整

          // --- 购物车按钮 ---
          _buildBottomIcon(
            iconPath: 'assets/images/icon_shopping_cart.png', // 购物车图标
            label: '${_shoppingDetail?['userCartCount'] ?? 0}', // 购物车数量
            onTap: () {
              if (!isLogin) { // 未登录提示
                showToast('请先登录');
                 _jumpToPage(0, context); // 弹出登录
                return;
              }
              // 跳转到购物车列表页
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                 ShoppingCarListWidget(onBackPressed: () => _getShoppingDetail()) // 返回时刷新详情
              ));
            },
          ),
          const Spacer(), // 占据中间空白区域

          // --- 加入购物车按钮 ---
          _buildBottomButton(
            text: '加入购物车',
            isPrimary: false, // 非主色按钮
            onTap: () => _jumpToPage(1, context), // 弹出SKU选择 (type 1)
          ),
          SizedBox(width: 10.w), // 按钮间距

          // --- 立即购买按钮 ---
          _buildBottomButton(
            text: '立即购买',
            isPrimary: true, // 主色按钮
            onTap: () => _jumpToPage(2, context), // 弹出SKU选择 (type 2)
          ),
        ],
      ),
    );
  }

  // 辅助方法：构建底部图标按钮 (收藏、购物车)
  Widget _buildBottomIcon({required String iconPath, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
        children: [
          Image.asset(iconPath, width: 20.w, height: 20.h),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(color: HexColor('#666666'), fontSize: 11.sp)), // 标签颜色稍浅
        ],
      ),
    );
  }

  // 辅助方法：构建底部操作按钮 (加入购物车、立即购买)
  Widget _buildBottomButton({required String text, required bool isPrimary, required VoidCallback onTap}) {
    return Expanded( // 让按钮能自动分配宽度
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42.h, // 按钮高度
          // width: 120.w, // 宽度由Expanded控制，不再固定
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // 根据是否是主按钮设置颜色和边框
            color: isPrimary ? HexColor('#222222') : Colors.white,
            borderRadius: BorderRadius.circular(21.h), // 圆角设为高度的一半，变成椭圆按钮
            border: isPrimary ? null : Border.all(color: HexColor('#222222'), width: 1), // 非主按钮有边框
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.black, // 文字颜色
              fontSize: 14.sp,
              fontWeight: FontWeight.w500, // 字体稍粗
            ),
          ),
        ),
      ),
    );
  }


  // --- 网络请求方法 ---

  // 获取商品详情
  Future<void> _getShoppingDetail() async {
    // 初始加载状态已在调用此方法前设置
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/shopping/commodity/detail', // API端点
        queryParameters: {'id': widget.commodityId}, // 商品ID
      );
      if (mounted && response != null) {
        // String rawHtml = response['commodityInfo'] ?? ''; // 获取HTML
        // _loadWebViewHtml(rawHtml); // 触发WebView加载

        setState(() {
          _shoppingDetail = Map<String, dynamic>.from(response); // 更新详情数据
          // 安全地解析图片列表
          final dynamic picUrlsData = _shoppingDetail?['picUrls'];
          if (picUrlsData is List) {
             imageList = List<String>.from(picUrlsData.where((item) => item is String));
          } else {
             imageList = []; // 如果数据格式不对或为空，则清空
          }
          // print("图片列表: $imageList");

           // *** 在获取数据后加载WebView内容 ***
           String rawHtml = _shoppingDetail?['commodityInfo'] ?? '';
           _loadWebViewHtml(rawHtml);

           // 注意：_isLoading状态由JS通道回调控制，这里不再设置
        });
      } else if (mounted) {
         // 获取失败或组件卸载
         setState(() { _isLoading = false; }); // 停止加载
         debugPrint("获取商品详情失败或组件已卸载");
      }
    } catch (e) {
      debugPrint('获取商品详情API调用出错：$e');
      if (mounted) {
        setState(() { _isLoading = false; }); // API出错也停止加载
        // showToast('加载商品详情失败');
      }
    }
  }

  // 加载HTML到WebView (辅助方法)
  void _loadWebViewHtml(String rawHtml) {
     if (!mounted) return;
    //  String cleanHtml = rawHtml.replaceAll(RegExp(r'style="[^"]*"'), ''); // 清理内联样式
     // 标准HTML结构
     String finalHtml = """
        <!DOCTYPE html><html><head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>body{font-family: sans-serif; word-wrap: break-word;} img{max-width: 100%; height: auto; display: block;}</style>
        </head><body>$rawHtml</body></html>
      """;
      // 确保 _webViewController 已初始化
      try {
        _webViewController.loadHtmlString(finalHtml);
      } catch (e) {
        debugPrint("加载HTML到WebView失败: $e");
      }
  }


  // 添加收藏
  Future<void> _addCollection() async {
    final String? commodityId = _shoppingDetail?['id']?.toString();
    if (commodityId == null) {
      showToast('商品信息错误，无法收藏');
      return;
    }
    try {
      final apiManager = ApiManager();
      // API端点确认：是 /api/home//collection/add 还是 /api/home/collection/add ?
      // businessType 7 代表商品类型，需要确认是否正确
      final response = await apiManager.post(
        '/api/home/collection/add', // 确认端点路径
        data: {'businessId': commodityId, "businessType": 7},
      );
      if (mounted && response != null) {
        showToast('收藏成功');
        _getShoppingDetail(); // 刷新详情以更新收藏状态和数量
      } else if (mounted) {
        showToast('收藏失败');
      }
    } catch (e) {
      debugPrint('添加收藏API调用出错：$e');
      if (mounted) {
        showToast('收藏操作失败: $e');
      }
    }
  }

  // 取消收藏
  Future<void> _cancelCollection() async {
    // 从 _shoppingDetail 获取收藏记录的ID
    final String? collectionId = _shoppingDetail?['isCollection']?.toString();
    if (collectionId == null || collectionId.isEmpty) {
      showToast('未找到收藏记录');
      return;
    }
    try {
      final apiManager = ApiManager();
      // 使用 deleteWithParameters 发送DELETE请求，并将ID放在请求体中
      final response = await apiManager.deleteWithParameters(
        '/api/home/collection/remove', // 确认端点路径
        data: {'id': collectionId},
      );
      if (mounted && response != null) {
        showToast('取消收藏成功');
        _getShoppingDetail(); // 刷新详情以更新收藏状态和数量
      } else if (mounted) {
         showToast('取消收藏失败');
      }
    } catch (e) {
      debugPrint('取消收藏API调用出错：$e');
      if (mounted) {
         showToast('取消收藏操作失败: $e');
      }
    }
  }
}