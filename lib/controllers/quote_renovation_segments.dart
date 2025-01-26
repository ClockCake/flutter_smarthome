import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/controllers/quote_renovation_area.dart';
import 'package:flutter_smarthome/controllers/quote_renovation_package_list.dart';
import 'package:flutter_smarthome/controllers/quote_renovation_price_detail.dart';
import 'package:flutter_smarthome/dialog/quote_selected_package_dialog.dart';
import 'package:flutter_smarthome/utils/custom_tab_indicator.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class QuoteRenovationSegmentsWidget extends StatefulWidget {
  final List<ExpandedRoom> roomList;  //房间列表
  const QuoteRenovationSegmentsWidget({Key? key, required this.roomList}) : super(key: key);

  @override
  State<QuoteRenovationSegmentsWidget> createState() => _QuoteRenovationSegmentsWidgetState();
}

class _QuoteRenovationSegmentsWidgetState extends State<QuoteRenovationSegmentsWidget> {
  List<String> _segmentTitles = [];
  List<RoomType> _roomTypes = [];
  List<Map<String, dynamic>> savePackages = []; // 保存的方案
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    for (var room in widget.roomList) {
      _segmentTitles.add('${room.roomName} · ${room.controller.text}m²');
      _roomTypes.add(room.roomType);
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  void _handleUpdatePackage(Map<String, dynamic> package, int location) {
    setState(() {
       // 用 package 中的 index做匹配，如果存在则替换，不存在则添加
      int index = savePackages.indexWhere((element) => element['index'] == package['index']);
      package['roomName'] = widget.roomList[location].roomName;
      package['roomType'] = widget.roomList[location].roomType;
      package['area'] = widget.roomList[location].controller.text;
      if (index != -1) {
        savePackages[index] = package;
      } else {
        savePackages.add(package);
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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
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
  Widget _buildSegmentedControl() {
    return ContainedTabBarView(  
      tabs: _segmentTitles.map((e) => Text(e)).toList(),
      tabBarProperties: TabBarProperties(     
        isScrollable: true,
        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
        labelColor:  HexColor('#FFA555'),
        unselectedLabelColor: HexColor('#999999'),
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: CustomTabIndicator(
          indicatorWidth: 20.w,  // 自定义宽度
          indicatorColor: HexColor('#FFA555'),  // 指示器颜色
          indicatorHeight: 2.w,  // 指示器高度
        ),
      ),
      views: _roomTypes.asMap().entries.map((entry) => 
        QuoteRenovationPackageListWidget(
          roomType: entry.value,
          packages: savePackages,
          updatePackage: _handleUpdatePackage,
          index: entry.key,  // 使用 map 的索引
        )
      ).toList(),
      onChange: (index) => print(index),
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
                  if (savePackages.isEmpty) {
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
                              child: QuoteSelectedPackageDialog(packages: savePackages),
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
              if (savePackages.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuoteRenovationPriceDetailWidget(packages: savePackages),
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