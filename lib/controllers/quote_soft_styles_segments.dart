import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_soft_price_detail.dart';
import 'package:flutter_smarthome/controllers/quote_soft_styles_grid.dart';
import 'package:flutter_smarthome/dialog/quote_selected_style_dialog.dart';
import 'package:flutter_smarthome/utils/custom_tab_indicator.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class QuoteSoftStylesSegmentsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> segementList;
  final String packageId;
  const QuoteSoftStylesSegmentsWidget({super.key,required this.segementList,required this.packageId});

  @override
  State<QuoteSoftStylesSegmentsWidget> createState() => _QuoteSoftStylesSegmentsWidgetState();
}

class _QuoteSoftStylesSegmentsWidgetState extends State<QuoteSoftStylesSegmentsWidget> {
  PersistentBottomSheetController? _bottomSheetController;
  List<Map<String, dynamic>> saveStyles = []; // 保存的方案
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  void _handleUpdatePackage(Map<String, dynamic> style, int location) {
    setState(() {
       // 用 package 中的 index做匹配，如果存在则替换，不存在则添加
      int index = saveStyles.indexWhere((element) => element['index'] == style['index']);
      style['roomName'] = widget.segementList[location]['roomName'];
      if (index != -1) {
        saveStyles[index] = style;
      } else {
        saveStyles.add(style);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '套餐选择',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(  // 添加 Column 作为容器
        children: [
          Expanded(  // 将 Expanded 移到这里
            child: _buildSegmentedControl(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }


  Widget _buildSegmentedControl(){
    return Theme(
      data: Theme.of(context).copyWith(
        tabBarTheme: const TabBarThemeData(
          dividerColor: Colors.transparent, // 隐藏分割线
          dividerHeight: 0,
        ),
      ),
      child: ContainedTabBarView(
        tabs: widget.segementList.map((e) => Tab(text: e['roomName'])).toList(),
        tabBarProperties: TabBarProperties(
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
          labelColor: HexColor('#FFA555'),
          unselectedLabelColor: HexColor('#999999'),
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: CustomTabIndicator(
            indicatorWidth: 20.w,
            indicatorColor: HexColor('#FFA555'),
            indicatorHeight: 2.w,
          ),
        ),
        views: widget.segementList.asMap().entries.map((entry) =>
          QuoteSoftStylesGridWidget(
            roomType: entry.value['roomType'],
            packageId: widget.packageId,
            updatePackage: _handleUpdatePackage,
            index: entry.key,
          )
        ).toList(),
        onChange: (index) => print(index),
      ),
    );
  }



  Widget _buildBottomNavBar(){
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Container(
          height: 48.h,
          child: Row(
            children: [
              Image.asset('assets/images/icon_quote_folder.png', width: 32.w, height: 32.h,),
              SizedBox(width: 8.w,),
              GestureDetector(
                onTap: () {
                  if (saveStyles.isEmpty) {
                    // 无数据时弹 AlertDialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('提示'),
                        content: Text('请先选择方案'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('确定'),
                          )
                        ],
                      ),
                    );
                  } else {
                    if (_bottomSheetController == null) {
                      _bottomSheetController = _scaffoldKey.currentState?.showBottomSheet(
                        (context) => Stack(
                          children: [
                            // 遮罩层使用 Positioned 控制高度到屏幕顶部
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              // 使用 MediaQuery 获取屏幕高度
                              height: MediaQuery.of(context).size.height,
                              child: Container(
                                  color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            // 实际内容
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: QuoteSelectedStylesDialog(
                                styles: saveStyles,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.transparent, // 确保 BottomSheet 背景透明
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                        ),
                      );

                      _bottomSheetController?.closed.then((_) {
                        _bottomSheetController = null;
                      });
                    } else {
                      _bottomSheetController?.close();
                      _bottomSheetController = null;
                    }
                  }
                },
                child:Text(
                  '已选方案',
                  style: TextStyle(
                    color: HexColor('#222222'),
                    fontSize: 14.sp,
                  ),
                ),
              ),

              Icon(Icons.keyboard_arrow_up, color: HexColor('#222222'), size: 14.sp,),
              Spacer(),
              if (saveStyles.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuoteSoftPriceDetailWidget(packageId: widget.packageId, roomList: saveStyles)
                      ),
                    );
                  },
                  child: Container(
                    width: 136.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: HexColor('#111111'),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        '下一步',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                )
              ] else ...[
                Container(
                  width: 136.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: HexColor('#999999'),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      '下一步',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}