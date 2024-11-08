import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/rank_designer_list.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class RankSegmentHomeWidget extends StatefulWidget {
 const RankSegmentHomeWidget({super.key});

 @override
 State<RankSegmentHomeWidget> createState() => _RankSegmentHomeWidgetState();
}

class _RankSegmentHomeWidgetState extends State<RankSegmentHomeWidget> {
 
 @override 
 void initState() {
   super.initState();
 }
 
 @override
 void dispose() {
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   final topPadding = MediaQuery.of(context).padding.top;  // 获取状态栏高度
   return Scaffold(
     body: SingleChildScrollView(
       child: SizedBox(
         // 设置一个最小高度,确保整个内容至少占满屏幕高度
         height: MediaQuery.of(context).size.height,
         child: Column(
           children: [
             // 顶部图片部分
             Container(
               width: double.infinity,
               height: 200.h + topPadding,
               decoration: const BoxDecoration(
                 image: DecorationImage(
                   image: AssetImage('assets/images/icon_rank_bg.png'),
                   fit: BoxFit.cover,
                 ),
               ),
               child: Stack(
                 children: [
                   Positioned(
                     left: 12.w,
                     top: topPadding,
                     child: IconButton(
                       icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                       onPressed: () {
                         Navigator.pop(context);
                       },
                     ),
                   ),
                 ],
               ),
             ),
             // 标签页部分
             Expanded(
               child: ContainedTabBarView(                 
                 tabs: const [
                   Text('设计师'),
                   Text('案例'),
                 ],
                 tabBarProperties: TabBarProperties(
                   indicatorColor: HexColor('#FFB26D'),
                   indicatorWeight: 3.h,
                   labelColor: Colors.black,
                   unselectedLabelColor: Colors.grey,
                   labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                   indicatorSize: TabBarIndicatorSize.label,
                   background: Container(
                      color: HexColor('#FBF7F2')
                   )
                   
                 ),
                 views: [
                    RankDesigherListWidget(),
                    RankDesigherListWidget(),
                 ],
                 onChange: (index) => print(index),
               ),
             ),
           ],
         ),
       ),
     )
   );
 }
}