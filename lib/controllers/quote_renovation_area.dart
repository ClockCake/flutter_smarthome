import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter/services.dart';

class ExpandedRoom {
  final String imageName;
  final String roomName;
  final RoomType roomType;
  final TextEditingController controller;
  final int index; // 用于标识是第几个同类房间

  ExpandedRoom({
    required this.imageName,
    required this.roomName,
    required this.roomType,
    required this.controller,
    required this.index,
  });
}

class QuoteRenovationAreaPageWidget extends StatefulWidget {
  final RenovationType renovationType;   //装修类型
  final List<Room> roomList;  //房间列表
  final double area;  //面积

  const QuoteRenovationAreaPageWidget({Key? key, required this.renovationType, required this.roomList, required this.area}) : super(key: key);
  @override
  State<QuoteRenovationAreaPageWidget> createState() => _QuoteRenovationAreaPageWidgetState();
}

class _QuoteRenovationAreaPageWidgetState extends State<QuoteRenovationAreaPageWidget> {
  late List<ExpandedRoom> _expandedRooms;
  
  @override
  void initState() {
    super.initState();
    _expandedRooms = _expandRoomList(widget.roomList);
  }

  // 展开房间列表
  List<ExpandedRoom> _expandRoomList(List<Room> rooms) {
    List<ExpandedRoom> expanded = [];
    
    for (var room in rooms) {
      // 根据count创建多个相同类型的房间
      for (int i = 0; i < room.count; i++) {
        expanded.add(
          ExpandedRoom(
            imageName: room.imageName,
            roomName: room.roomName,
            roomType: room.roomType,
            controller: TextEditingController(),
            index: i + 1,  // 从1开始计数
          ),
        );
      }
    }
    
    return expanded;
  }

  @override
  void dispose() {
    // 释放所有controller
    for (var room in _expandedRooms) {
      room.controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '快速报价',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             _buildTips(),
             SizedBox(height: 16.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  _buildTips(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 12.h),
           Text(
              '请您选择新居结构',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            '您可以通过增加或减少按钮来选择您相应房间的数量为您的新家搭配理想方案',
            style: TextStyle(
              color: HexColor('#999999'),
              fontSize: 12.sp,
            ),
          ),
        ]
      )
    );
  }

  _buildGrid(){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemBuilder: (context, index) {
        final ExpandedRoom room = _expandedRooms[index];
        return Container(
          decoration: BoxDecoration(
            color: HexColor('#F8F8F8'),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                room.imageName,
                width: 40.w,
                height: 40.h,
              ),
              SizedBox(height: 8.h),
              Text(
                room.roomName,
                style: TextStyle(
                  color: HexColor('#333333'),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  height: 32.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    children: [
                      //输入框
                      Expanded(
                        child: TextField(
                          controller: room.controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                            border: InputBorder.none,
                            hintText: '请输入',
                          ),
                        ),
                      ),
                      Text('m²', style: TextStyle(color: HexColor('#222222'), fontSize: 14.sp)),
                      SizedBox(width: 4.w),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
      itemCount: 12,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }
    //底部按钮
  _buildBottomButton() {
    return GestureDetector(
      onTap: () {

      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                '查看报价',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}