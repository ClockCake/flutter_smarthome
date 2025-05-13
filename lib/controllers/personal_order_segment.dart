import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/personal_order_list.dart';
import 'package:flutter_smarthome/controllers/shopping_car_list.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class PersonalOrderSegmentWidget extends StatefulWidget {
  final int index;
  const PersonalOrderSegmentWidget({super.key,required this.index});

  @override
  State<PersonalOrderSegmentWidget> createState() => _PersonalOrderSegmentWidgetState();
}

class _PersonalOrderSegmentWidgetState extends State<PersonalOrderSegmentWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('我的订单', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
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
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: const TabBarThemeData(
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                  ),
                ),
                child: ContainedTabBarView(
                  initialIndex: widget.index,
                  tabs: const [
                    Text('全部'),
                    Text('待付款'),
                    Text('待发货'),
                    Text('待收货'),
                    Text('评价'),
                  ],
                  tabBarProperties: TabBarProperties(
                    indicatorWeight: 2.sp,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 2.w,
                        color: HexColor('#FFD700'),
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 6.w),
                    ),
                  ),
                  views: const [
                    PersonalOrderListWidget(orderStatus: "0"),
                    PersonalOrderListWidget(orderStatus: "1"),
                    PersonalOrderListWidget(orderStatus: "3"),
                    PersonalOrderListWidget(orderStatus: "4"),
                    Scaffold(body: Center(child: Text('评价'))),
                  ],
                  onChange: (index) => print(index),
                ),
              ),
            ),
                      ],
        )
      ),
    );
  }
}