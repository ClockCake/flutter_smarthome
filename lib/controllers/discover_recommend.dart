import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:gif_view/gif_view.dart';
import '../view/auto_scroll_horizontal_list.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
import 'package:cached_network_image/cached_network_image.dart';
class DiscoverRecommendWidget extends StatefulWidget {
  @override
  _DiscoverRecommendWidgetState createState() => _DiscoverRecommendWidgetState();
}

class _DiscoverRecommendWidgetState extends State<DiscoverRecommendWidget> {
 //图片数组
  final List<String> imageList = [
    'assets/images/icon_home_whole.png',
    'assets/images/icon_home_renew.png',
    'assets/images/icon_home_soft.png',
  ];
  //文字数组
  final List<String> titleList = ['整装', '翻新', '软装'];

  final List<String> _items = [
    '三字经',
    '水到渠成',
    '如鱼',
    '潜移默化',
    '帅',
    '人生苦短',
    '我用Flutter',
    '黑云压城城欲摧',
    '悬壶问道，月光转照'
 ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Column(
          children: [
           //轮播图
           SizedBox(height: 20.h),
           SizedBox(
              height: 250, // 设置轮播图的高度
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),  // 设置圆角
                  child: Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.fill,
                  ),
                 );
                },
                autoplay: true,
                itemCount: 10,
                viewportFraction: 0.8,
                scale: 0.9,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              height: 176.h,
              child: Stack(
                 children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            print('点击了推荐');
                          },
                          child:                         Container(
                          color: HexColor('#F8F8F8'),
                          height: 88.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Container(
                                  child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 0, 0),
                                          child: Text('装修计算器', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                        ),
                                        //右侧箭头在上面那个Padding的右侧,居中上面那个控件
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(10.w, 20.h, 0 , 0),
                                          child: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 0, 0),
                                  child: Text('王女士・13室1厅1厨1卫・120m²・22w',style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                                ),

                              ],
                            )
                          ),
                        ),  
                        Container(
                          color: Colors.white,
                          height: 88.h,
                          child: Row(
                            children: [
                              //从图片数组和文字数组中取值，一排按钮可点击
                              for (int i = 0; i < imageList.length; i++)
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      print('点击了第$i个按钮');
                                    },  
                                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        Image.asset(
                                          imageList[i],
                                          width: 40.w,
                                          height: 40.h,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          titleList[i],
                                          style: TextStyle(fontSize: 12.sp),
                                        )
                                      ],
                                    ),
                                  )
                                )
                            ],
                          ),
                         

                        )
                      ],
                    ),
                    Positioned(
                      right: 16.w,
                      top: 16.h,
                      child: GifView.asset(
                        'assets/images/calculator.gif',
                        height: 70,
                        width: 70,
                        frameRate: 30, // default is 15 FPS
                      ),
                    )
                 ],
              ),
            ),
            Padding(
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
                    Container(
                      margin: EdgeInsets.all(12.h),
                      child: Row(children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), // 控制Text的内边距
                          decoration: BoxDecoration(
                            color: Colors.black, // 背景颜色
                            borderRadius: BorderRadius.circular(6.0), // 圆角
                          ),
                          child: Text(
                            '招标',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '本月招标 ',
                                style: TextStyle(
                                  fontSize: 12.sp, // 普通文本的字体大小
                                  color: Colors.black, // 普通文本的颜色
                                ),
                              ),
                              TextSpan(
                                text: '98', // 数字部分
                                style: TextStyle(
                                  fontSize: 12.sp, // 数字的字体大小
                                  color: HexColor('#FFA555'),
                                  fontWeight: FontWeight.bold, // 可以设置为加粗
                                ),
                              ),
                              TextSpan(
                                text: ' 家',
                                style: TextStyle(
                                  fontSize: 12.sp, // 普通文本的字体大小
                                  color: Colors.black, // 普通文本的颜色
                                ),
                              ),
                            ],
                          ),
                        ),    
                      ],
                      ),
                    ),
                    AutoScrollHorizontalList(
                      itemCount: 5,
                      scrollSpeed: 100.0, // 每秒滚动100像素
                      scrollInterval: 100, // 每100毫秒滚动一次
                      height: 80.h,
                      itemWidth: 150.w,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                      backgroundColor: HexColor('#F8F8F8'),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,  
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.all(10.h), child: Text('汤臣一品陈女士发起',style: TextStyle(color: HexColor('#222222'),fontSize: 11.sp),)),
                              Padding(padding: EdgeInsets.only(top: 1 .h), child: Text('整装招标',style: TextStyle(color: HexColor('#999999'),fontSize: 11.sp),)),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      margin: EdgeInsets.all(12.h), 
                      height: 30.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,

                      ),
                      child: InfiniteMarquee(
                        frequency: const Duration(milliseconds: 40),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          String item = '${_items[index % _items.length]}  $index';
                          return GestureDetector(
                            onTap: () {
                              print('点击了$item');
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
                                      borderRadius: BorderRadius.circular(10)
                                  ),
      
                                  child: Row(
                                    children: [
                                      Image.asset('assets/images/icon_home_trumpet.png',width: 12.w,height: 12.h),
                                      SizedBox(width: 8.w), // 这里插入一个SizedBox，用于添加间距
                                      Text(item,style: TextStyle(fontSize: 12.sp,color: HexColor('#666666')),),
                                      Text('招标成功',style: TextStyle(fontSize: 12.sp,color: HexColor('#FFA555')),),
                                      const Spacer(),
                                      Icon(Icons.arrow_forward_ios,size: 12.sp,color: HexColor('#666666')),
                                    ],
                                  ),
                             ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            ),
            Padding(
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
                        Image(image: AssetImage('assets/images/icon_home_house.png')),
                        SizedBox(width: 16.w),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('在线工地', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4.h),
                              Text('已有34586个工地正在施工', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999'))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned.fill( // 使用 Positioned.fill 确保图片覆盖整个 Container
                    child: Image.asset(
                      'assets/images/icon_home_map.png',
                      fit: BoxFit.cover, // 设置图片覆盖方式
                    ),
                  ),
                ],
            ),
           ),
         Container(
            alignment: Alignment.centerLeft, // 左对齐
            padding: EdgeInsets.only(left:16.w,top: 16.h),
            child: Text(
              '推荐案例',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.h),
           //列表平铺
          Column(
            children: List.generate(10, (index)  {
              return Container(
                child: Column(
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
                              child: Text('案例', style: TextStyle(fontSize: 11.sp, color: Colors.white)),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text('另类美式风，打造独一无二的家', style: TextStyle(fontSize: 15.sp, color: HexColor('#222222'))),
                        ],
                      )
                     ),
                     Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                      child: Center(
                        child: Text('采用浅色为主、深色为辅的装修理念，灰色的墙壁、蓝色的墙柜和橡木色的地板，拒绝美式的沉闷就这么简单',style: TextStyle(fontSize: 13.sp,color: HexColor('#666666')),)
                      ),
                    ),
                    //一排可横向滚动的图片的,间距 8，然后 一屏显示3个，图片宽高比 16:9
                    SizedBox(height: 8.h),
                    Container(
                      height: 100.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(left: 16.w),
                            width: 120.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: const DecorationImage(
                                //显示网络图片
                                image: CachedNetworkImageProvider(
                                  "https://image.itimes.me/i/2024/07/26/66a30d068028b.jpg",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    //分割线
                    Container(
                      height: 1.h,
                      color: HexColor('#F8F8F8'),
                    ),
                  ],
                ),
              );
           }),
          )
          ],
        )
      )
    );
  }
}