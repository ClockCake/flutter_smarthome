import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200.h + topPadding,
              decoration: const BoxDecoration(
                image:  DecorationImage(
                  image: AssetImage('assets/images/icon_rank_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  //返回按钮白色
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
            Expanded(
              child: ContainedTabBarView(
                tabs: const [
                  Text('设计师'),
                  Text('案例'),
                ],
                tabBarProperties: TabBarProperties(
                  indicatorColor: HexColor('#FFB26D'),
                  indicatorWeight: 2.0,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.label,
                  
                ),

                views: const [
                    Text('2222'),
                    Text('3333'),
                ],

                onChange: (index) => print(index),
                
              ),
            ),
          ]
        ),
      )
    );
  }
}