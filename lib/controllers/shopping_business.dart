import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/search_grid.dart';
import 'package:flutter_smarthome/controllers/shopping_list.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

class ShoppingBusinessWidget extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String businessLogo;
  const ShoppingBusinessWidget({super.key,required this.businessId,required this.businessName,required this.businessLogo});

  @override
  State<ShoppingBusinessWidget> createState() => _ShoppingBusinessWidgetState();
}

class _ShoppingBusinessWidgetState extends State<ShoppingBusinessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String,dynamic>> dataSource = [];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 16.w,),
                 NetworkImageHelper().getCachedNetworkImage(imageUrl: widget.businessLogo,width: 40.w,height: 40.h),
                 SizedBox(width: 10,),
                 Text(widget.businessName,style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold,color: HexColor('#2A2A2A')),),
              ],
            ),
            SizedBox(height: 10.h,),
            _buildSegmentedControl(),
          ],
        ),
      ), 
    );
  }

  Widget _buildSegmentedControl() {
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          tabBarTheme: const TabBarThemeData(
            dividerColor: Colors.transparent, // 隐藏分割线
            dividerHeight: 0,
          ),
        ),
        child: ContainedTabBarView(
          tabs: const [
            Text('精选'),
            Text('商品'),
            Text('活动'),
            Text('新品'),
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
            ShoppingListWidget(businessId: widget.businessId, type: "1"),
            ShoppingListWidget(businessId: widget.businessId, type: "0"),
            ShoppingListWidget(businessId: widget.businessId, type: "2"),
            ShoppingListWidget(businessId: widget.businessId, type: "3"),
          ],
          onChange: (index) => print(index),
        ),
      ),
    );   
 }
}