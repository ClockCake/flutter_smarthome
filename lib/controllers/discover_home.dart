
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter_smarthome/controllers/discover_infomation.dart';
import 'package:flutter_smarthome/controllers/furnish_form.dart';
import 'package:flutter_smarthome/controllers/home_search.dart';
import 'package:flutter_smarthome/utils/set_proxy_page.dart'; 
import 'discover_recommend.dart';

class DiscoverHomeWidget extends StatefulWidget {
  const DiscoverHomeWidget({super.key});

  @override
  State<DiscoverHomeWidget> createState() => _DiscoverHomeWidget();
}

class _DiscoverHomeWidget extends State<DiscoverHomeWidget> {
  void _navigateToSetProxy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SetProxyPage()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector( // 添加 GestureDetector
        onLongPress: _navigateToSetProxy, // 长按事件
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeSearchPage(type: 1,),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
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
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    tabBarTheme: const TabBarThemeData(
                      dividerColor: Colors.transparent, // 隐藏那条分割线
                      // 如果你的包里还用到了 dividerHeight，可以一起设 0
                      dividerHeight: 0,
                    ),
                  ),
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
                    onChange: (index) => FocusScope.of(context).unfocus(),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }


}