import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter_smarthome/controllers/discover_infomation.dart';
import 'package:flutter_smarthome/controllers/furnish_form.dart';
import 'discover_recommend.dart';
class DiscoverHomeWidget extends StatefulWidget {
  const DiscoverHomeWidget({super.key});

  @override
  State<DiscoverHomeWidget> createState() => _DiscoverHomeWidget();
}

class _DiscoverHomeWidget extends State<DiscoverHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 顶部搜索框
            Container(
              padding:  EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search),
                          SizedBox(width: 10),
                          Text('搜索', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //segmentedControl
            Expanded(
              child: ContainedTabBarView(
                tabs: const [
                  Text('推荐'),
                  Text('装修'),
                  Text('资讯'),
                ],
                tabBarProperties: const TabBarProperties(
                  indicatorColor: Colors.black,
                  indicatorWeight: 2.0,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.label,
                  
                ),

                views: [
                  DiscoverRecommendWidget(),
                  FurnishFormWidget(),
                  DiscoverInformationWidget(),

                ],

                onChange: (index) => print(index),
                
              ),
            ),
            
          ],
        )
      ),
    );
  }
}