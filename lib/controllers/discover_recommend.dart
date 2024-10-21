import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:gif_view/gif_view.dart';

class DiscoverRecommendWidget extends StatefulWidget {
  @override
  _DiscoverRecommendWidgetState createState() => _DiscoverRecommendWidgetState();
}

class _DiscoverRecommendWidgetState extends State<DiscoverRecommendWidget> {

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
                        Container(
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
                        Container(
                          color: Colors.white,
                          height: 88.h,

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
            // Expanded(child: Container(color: Colors.green)),
          ],
        )
      )
    );
  }
}