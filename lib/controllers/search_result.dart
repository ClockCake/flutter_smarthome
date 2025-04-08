import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/search_grid.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class HomeResultPageWidget extends StatefulWidget {
  final String searchStr;
  final int type; // 1 是App 首页搜索， 2 是商城首页搜索
  const HomeResultPageWidget({
    super.key,
    required this.searchStr,
    required this.type,
    
  });

  @override
  State<HomeResultPageWidget> createState() => _HomeResultPageWidgetState();
}

class _HomeResultPageWidgetState extends State<HomeResultPageWidget> {
  final TextEditingController _controller = TextEditingController(); 
  List<Map<String,dynamic>> dataSource = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchStr;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String searchText) {
    setState(() {
      // 每次文本变化时刷新界面，SearchGridPageWidget 会根据新的搜索值重新加载
    });
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
                        controller: _controller,
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
                        onChanged: _onSearchChanged,  // 监听输入变化
                        onSubmitted: (value) {
                          // 处理键盘完成时的逻辑
                          setState(() {
                            // 更新搜索值时触发重新加载
                          });
                        },
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
        tabs: [
          if (widget.type == 1) ...[
            Text('产品'),
            Text('店铺'),
            Text('商品'),
            Text('设计师'),
            Text('案例'),
          ] else if (widget.type == 2) ...[
            Text('商品'),
            Text('店铺'),
          ]
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
          if (widget.type == 1) ...[
            SearchGridPageWidget(searchTypes: [4],searchValue: _controller.text,), //产品
            SearchGridPageWidget(searchTypes: [6],searchValue: _controller.text,), //商店铺
            SearchGridPageWidget(searchTypes: [3], searchValue: _controller.text), //商品
            SearchGridPageWidget(searchTypes: [1],searchValue: _controller.text,), //设计师
            SearchGridPageWidget(searchTypes: [2],searchValue: _controller.text,), //案例
          ] else if (widget.type == 2) ...[
            SearchGridPageWidget(searchTypes: [3],searchValue: _controller.text,), //商品
            SearchGridPageWidget(searchTypes: [6], searchValue: _controller.text), //店铺
          ],
        ],
        onChange: (index) => print(index),
      ),
    );
  }
}