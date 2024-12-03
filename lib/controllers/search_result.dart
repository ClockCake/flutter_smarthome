import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class HomeResultPageWidget extends StatefulWidget {
  final String searchStr;
  const HomeResultPageWidget({
    super.key,
    required this.searchStr,
    
  });

  @override
  State<HomeResultPageWidget> createState() => _HomeResultPageWidgetState();
}

class _HomeResultPageWidgetState extends State<HomeResultPageWidget> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 36.h, // 搜索框高度
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: '搜索',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
              ),
            ),
            _buildSegmentedControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Expanded(
      child: ContainedTabBarView(
        tabs: const [
          Text('全部'),
          Text('产品'),
          Text('商品'),
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

        views: [
          Placeholder(),
          Placeholder(),
          Placeholder(),
          Placeholder(),
          Placeholder(),
          Placeholder(),
        ],

        onChange: (index) => print(index),
        
      )
    );    
  }
}