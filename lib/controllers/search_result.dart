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
  const HomeResultPageWidget({
    super.key,
    required this.searchStr,
    
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
     _onRefresh();

  }

  @override
  void dispose() {
    _controller.dispose();
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
                        onSubmitted: (value) { // 添加 onSubmitted 回调
                          if (value.length > 1) {
                             _onRefresh();
                          }
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
          SearchGridPageWidget(dataList: dataSource), //全部
          SearchGridPageWidget(dataList: dataSource.where((item) => item['resourceType'] == '4').toList()), //产品
          SearchGridPageWidget(dataList: dataSource.where((item) => item['resourceType'] == '3').toList()), //商品
          SearchGridPageWidget(dataList: dataSource.where((item) => item['resourceType'] == '1').toList()), //设计师
          SearchGridPageWidget(dataList: dataSource.where((item) => item['resourceType'] == '2').toList()), //案例
        ],

        onChange: (index) => print(index),
        
      )
    );    
  }
  
  Future<void> _onRefresh() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/search',
         queryParameters: {
          'searchValue': _controller.text,}
      );
      if (mounted && response!= null) {
        setState(() {
           dataSource = List<Map<String,dynamic>>.from(response);
        });
      }
    } catch (e) {
      print(e);
    }
  }
 
}