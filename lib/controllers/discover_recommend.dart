import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/bidden_list.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:gif_view/gif_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../view/auto_scroll_horizontal_list.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscoverRecommendWidget extends StatefulWidget {
  @override
  _DiscoverRecommendWidgetState createState() =>
      _DiscoverRecommendWidgetState();
}

class _DiscoverRecommendWidgetState extends State<DiscoverRecommendWidget> with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  // Banner数据
  List <Map<String,dynamic>> imageList = [];
  // 文字数组
  final List<String> titleList = ['整装', '翻新', '软装'];
  final List<String> localImages = [
    'assets/images/icon_home_renew.png',
    'assets/images/icon_home_renew.png', 
    'assets/images/icon_home_soft.png',

  ];

  List <Map<String,dynamic>> currentBiddenList = []; // 当前招标列表
  List <Map<String,dynamic>> sucessBiddenList = []; // 招标成功列表
  int monthlyNumber = 0; // 本月招标数量
  bool get wantKeepAlive => true;  // 保持页面状态

  List <Map<String,dynamic>> recommendList = [];

  @override
  void initState() {
    super.initState();
    getBannerData();
    getBiddenData();
  }
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CircularProgressIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手加载更多");
            } else {
              body = Text("");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView( // 将 Column 改为 ListView
          children: [
            SizedBox(height: 20.h),
            _buildBanner(),
            SizedBox(height: 24.h),
            _buildRecommendationSection(),
            _buildTenderSection(),
            _buildOnlineSiteSection(),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.w, top: 16.h),
              child: Text(
                '推荐案例',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.h),
            _buildCaseList(),
          ],
        ),
      ),
    );
  }

  // 构建轮播图
  Widget _buildBanner() {
    return SizedBox(
      height: 250.h,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final item  = imageList[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // 设置圆角
            child: NetworkImageHelper().getCachedNetworkImage(
              imageUrl: item['packagePic'] ?? "",
              fit: BoxFit.cover,
            ),
          );
        },
        autoplay: true,
        itemCount: imageList.length,
        viewportFraction: 0.8,
        scale: 0.9,
        onIndexChanged: (index) {
        
        },
      ),
    );
  }

  // 构建推荐区域
  Widget _buildRecommendationSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 176.h,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 装修计算器
              InkWell(
                onTap: () {
                  print('点击了装修计算器');
                },
                child: Container(
                  color: HexColor('#F8F8F8'),
                  height: 88.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 0, 0),
                        child: Row(
                          children: [
                            Text('装修计算器',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10.w),
                            Icon(Icons.arrow_forward_ios,
                                size: 16.sp, color: Colors.black),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 4.h, 0, 0),
                        child: Text(
                          '王女士・13室1厅1厨1卫・120m²・22w',
                          style: TextStyle(
                              fontSize: 12.sp, color: HexColor('#999999')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 功能按钮行
              Container(
                color: Colors.white,
                height: 88.h,
                child: Row(
                  children: List.generate(titleList.length, (i) {
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          print('点击了${titleList[i]}按钮');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              localImages[i],
                              width: 40.w,
                              height: 40.h,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              titleList[i],
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          // 装修计算器GIF
          Positioned(
            right: 16.w,
            top: 16.h,
            child: GifView.asset(
              'assets/images/calculator.gif',
              height: 70,
              width: 70,
              frameRate: 30, // 默认为15 FPS
            ),
          ),
        ],
      ),
    );
  }

  // 构建招标区域
  Widget _buildTenderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: HexColor('#F8F8F8'),
        ),
        child: Column(
          children: [
            // 招标标题
            _buildTenderTitle(),
            // 滚动列表
            _buildAutoScrollList(),
            // 无限滚动通知
            _buildInfiniteMarquee(),
          ],
        ),
      ),
    );
  }

  // 构建招标标题
  Widget _buildTenderTitle() {
    return Container(
      margin: EdgeInsets.all(12.h),
      child: Row(
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              '招标',
              style: TextStyle(fontSize: 11.sp, color: Colors.white),
            ),
          ),
          Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '本月招标 ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '$monthlyNumber',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: HexColor('#FFA555'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' 家',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建自动滚动列表
  Widget _buildAutoScrollList() {
    return AutoScrollHorizontalList(
      itemCount: currentBiddenList.length,
      scrollSpeed: 100.0,
      scrollInterval: 100,
      height: 80.h,
      itemWidth: 150.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      backgroundColor: HexColor('#F8F8F8'),
      itemBuilder: (context, index) {
        final item  = currentBiddenList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BiddenListWidget()),
            ); 
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Text( '${item['region']}${item['name']}发起',
                      style: TextStyle(
                          color: HexColor('#222222'), fontSize: 11.sp)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text('${item['decorateType']}招标',
                      style: TextStyle(
                          color: HexColor('#999999'), fontSize: 11.sp)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// 构建无限滚动通知
Widget _buildInfiniteMarquee() {
  return Container(
    margin: EdgeInsets.all(12.h),
    height: 30.h,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
    ),
    child: sucessBiddenList.isNotEmpty
        ? InfiniteMarquee(
            frequency: const Duration(milliseconds: 40),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              // 确保 index 在合法范围内
              final int adjustedIndex = index % sucessBiddenList.length;
              // 处理负数索引
              final int finalIndex = adjustedIndex < 0
                  ? adjustedIndex + sucessBiddenList.length
                  : adjustedIndex;

              final item = sucessBiddenList[finalIndex];
              final text =
                  '${item['city']}${item['region']}${item['name']}招标成功';
              return GestureDetector(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BiddenListWidget()),
                    );       
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 30.h,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/icon_home_trumpet.png',
                            width: 12.w, height: 12.h),
                        SizedBox(width: 8.w),
                        Text(
                          text,
                          style: TextStyle(
                              fontSize: 12.sp, color: HexColor('#666666')),
                        ),
                        Text(
                          '招标成功',
                          style: TextStyle(
                              fontSize: 12.sp, color: HexColor('#FFA555')),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 12.sp, color: HexColor('#666666')),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : SizedBox.shrink(),
  );
}

  // 构建在线工地区域
  Widget _buildOnlineSiteSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Stack(
        children: [
          Container(
            height: 80.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: HexColor('#F8F8F8'),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Image(
                    image: AssetImage('assets/images/icon_home_house.png')),
                SizedBox(width: 16.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('在线工地',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text('已有34586个工地正在施工',
                        style: TextStyle(
                            fontSize: 12.sp, color: HexColor('#999999'))),
                  ],
                )
              ],
            ),
          ),
          // 背景地图图片
          Positioned.fill(
            child: Image.asset(
              'assets/images/icon_home_map.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // 修改案例列表构建方法
  Widget _buildCaseList() {
    return ListView.builder( // 使用 ListView.builder 而不是 Column
      shrinkWrap: true, // 允许在 ListView 中嵌套 ListView
      physics: NeverScrollableScrollPhysics(), // 禁用内部滚动
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '案例',
                        style: TextStyle(fontSize: 11.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded( // 添加 Expanded 防止文本溢出
                    child: Text(
                      '另类美式风，打造独一无二的家',
                      style: TextStyle(fontSize: 15.sp, color: HexColor('#222222')),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
              child: Text(
                '采用浅色为主、深色为辅的装修理念，灰色的墙壁、蓝色的墙柜和橡木色的地板，拒绝美式的沉闷就这么简单',
                style: TextStyle(fontSize: 13.sp, color: HexColor('#666666')),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox( // 使用 SizedBox 替代 Container
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: 16.w),
                    width: 120.w,
                    height: 100.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImageHelper().getCachedNetworkImage(
                        imageUrl:
                            'https://image.iweekly.top/i/2024/07/26/66a30d068028b.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 1.h,
              color: HexColor('#F8F8F8'),
            ),
          ],
        );
      },
    );
  }

  Future<void>getBannerData() async {
    // 获取轮播图数据
    try{
      final response = await ApiManager().get('/api/home/banner');
      if (response != null){
        setState(() {
          imageList = List<Map <String,dynamic>>.from(response);

        });
      }
    }
    catch(e){
      print('获取轮播图数据失败：$e');
    } 
  }

  Future<void>getBiddenData() async {
    // 获取招标数据
    try{
      final response = await ApiManager().get('/api/home/tender');
      if (response != null){
         setState(() {
          currentBiddenList = List<Map <String,dynamic>>.from(response['latest']);
          sucessBiddenList = List<Map <String,dynamic>>.from(response['succData']);
          monthlyNumber = response['monthlyNumber'];
         });
      }
    }
    catch(e){
      print('获取招标数据失败：$e');
    } 
  }

  Future<void>getRecommendData() async {
    // 获取推荐数据
    try{
      final response = await ApiManager().get('/api/home/recommend/case');
      if (response != null){
         setState(() {
          recommendList = List<Map <String,dynamic>>.from(response);
         });
      }
    }
    catch(e){
      print('获取推荐数据失败：$e');
    } 
  }

  void _onRefresh() async {
    pageNum = 1;
    recommendList.clear();
    await getRecommendData();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await getRecommendData();
    if (recommendList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }
}