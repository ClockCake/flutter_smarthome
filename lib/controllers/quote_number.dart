import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_package_list.dart';
import 'package:flutter_smarthome/controllers/quote_renovation_area.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/shopping_cart_count.dart';

enum RenovationType {
  fullRenovation("整装"), 
  renovation("翻新"),
  softFurnishing("软装");
  // partialChange("局改"),
  // maintenance("维修");

  final String label;
  const RenovationType(this.label);
}

// 房间类型枚举
enum RoomType {
  bedroom("卧室"),
  livingRoom("客厅"),
  kitchen("厨房"),
  bathroom("卫生间"),
  wallRefresh("墙面刷新"),
  restaurant ("餐厅");
  final String label;
  const RoomType(this.label);
}

// 房间模型类
class Room {
  final String imageName;
  final String roomName;
  final RoomType roomType;
  int count;

  Room({
    required this.imageName,
    required this.roomName,
    required this.roomType,
    this.count = 0,
  });
}

class QuoteNumberPage extends StatefulWidget {
  final RenovationType renovationType;
  const QuoteNumberPage({super.key, required this.renovationType});

  @override
  State<QuoteNumberPage> createState() => _QuoteNumberPageState();
}

class _QuoteNumberPageState extends State<QuoteNumberPage> {
  // 房间面积输入框
  final TextEditingController _areaController = TextEditingController();
    // 添加状态变量
  late RenovationType _currentType;
  late List<Room> _roomList;
  final maxLimit = 10;
    // 添加一个重置计数器
  int _resetCounter = 0;
// 在类外定义常量数据
final Map<RenovationType, List<Room>> roomTypeMap = {
  RenovationType.fullRenovation: [
    Room(
      imageName: 'assets/images/icon_room_bedroom.png',
      roomName: '卧室',
      roomType: RoomType.bedroom,
    ),
    Room(
      imageName: 'assets/images/icon_room_dinner.png',
      roomName: '客厅',
      roomType: RoomType.livingRoom,
    ),
    Room(
      imageName: 'assets/images/icon_room_kitchen.png',
      roomName: '厨房',
      roomType: RoomType.kitchen,
    ),
    Room(
      imageName: 'assets/images/icon_room_bath.png',
      roomName: '卫生间',
      roomType: RoomType.bathroom,
    ),
  ],
  RenovationType.renovation: [
    Room(
      imageName: 'assets/images/icon_room_bath.png',
      roomName: '卫生间',
      roomType: RoomType.bathroom,
    ),
    Room(
      imageName: 'assets/images/icon_room_kitchen.png',
      roomName: '厨房',
      roomType: RoomType.kitchen,
    ),
    Room(
      imageName: 'assets/images/icon_room_wall.png',
      roomName: '墙面刷新',
      roomType: RoomType.wallRefresh,
    ),
  ],
  RenovationType.softFurnishing: [
    Room(
      imageName: 'assets/images/icon_room_bedroom.png',
      roomName: '卧室',
      roomType: RoomType.bedroom,
    ),
    Room(
      imageName: 'assets/images/icon_room_dinner.png',
      roomName: '客厅',
      roomType: RoomType.livingRoom,
    ),
    Room(
      imageName: 'assets/images/icon_room_restaurant.png',
      roomName: '餐厅',
      roomType: RoomType.restaurant,
    ),
  ],
};


  @override
  void initState() {
    super.initState();
    _currentType = widget.renovationType;
    _updateRenovationType(_currentType);

  }
  //刷新数据
  void _updateRenovationType(RenovationType newType) {
    setState(() {
      _currentType = newType;
      // 增加重置计数器
      _resetCounter++;
      // 创建新的Room对象列表，确保计数值重置为0
      _roomList = roomTypeMap[newType]!.map((room) => Room(
        imageName: room.imageName,
        roomName: room.roomName,
        roomType: room.roomType,
        count: 0,
      )).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _areaController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '快速报价',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
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
            _buildChoiceWidget(),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildGrid(),
            ),
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

  _buildChoiceWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                //底部弹窗切换装修类型
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 200.h,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(RenovationType.fullRenovation.label),
                            onTap: () {
                              _updateRenovationType(RenovationType.fullRenovation);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(RenovationType.renovation.label),
                            onTap: () {
                              _updateRenovationType(RenovationType.renovation);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(RenovationType.softFurnishing.label),
                            onTap: () {
                              _updateRenovationType(RenovationType.softFurnishing);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
            },
            child: Row( //  *装修类型
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red), // 星号使用红色
                      ),
                      TextSpan(
                        text: '装修类型',  // 你的文本内容
                        style: TextStyle(color:  HexColor('#666666'),fontSize: 14.sp), // 正文使用黑色
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  _currentType.label,
                  style: TextStyle(
                    color: HexColor('#333333'),
                    fontSize: 14.sp,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.grey),  // 灰色箭头
                  onPressed: () {
    
                  },
                ),
              ],
            ),
          ),
          Divider(),
          if (_currentType != RenovationType.softFurnishing)  // 只有整装类型需要输入房屋面积
            Row( //  *房间面积
              children: [
                if (_currentType != RenovationType.softFurnishing)  // 只有整装类型需要输入房屋面积
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red), // 星号使用红色
                      ),
                      TextSpan(
                        text: '房屋面积',  // 你的文本内容
                        style: TextStyle(color:  HexColor('#666666'),fontSize: 14.sp), // 正文使用黑色
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: 150.w,
                  // height: 30.h,
                  child: TextField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                      border: InputBorder.none,
                      hintText: '请输入房屋面积',
                      hintStyle: TextStyle(
                        color: HexColor('#999999'),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                Text(
                  '㎡',
                  style: TextStyle(
                    color: HexColor('#333333'),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 16.w,)
              ],
            ),
          if (_currentType != RenovationType.softFurnishing)  // 只有整装类型需要输入房屋面积
          Divider(),
        ],
      ),
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
        final Room room = _roomList[index];
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
              ShoppingCartItem(
                maxQuantity: maxLimit,
                minQuantity: 0,
                key: ValueKey('${room.roomType}_${_resetCounter}'),

                onQuantityChanged: (value) {
                  setState(() {
                    room.count = value;
                  });
                },
                initialQuantity: room.count,
              ),
              
            ],
          ),
        );
      },
      itemCount: _roomList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }
  // 校验参数
  bool _validateParams() {
     //_roomList中的 count 都不能为 0 ，否则提示用户，并且面积也必须大于 0 
    if (_roomList.any((room) => room.count > 0) && _areaController.text != '' && _currentType != RenovationType.softFurnishing) {
      return true;
    }
    if (_roomList.any((room) => room.count > 0) &&  _currentType == RenovationType.softFurnishing) {
      return true;
    }
    return false;
  }
  //底部按钮
  _buildBottomButton() {
    return GestureDetector(
      onTap: () {
        if (!_validateParams()) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('提示'),
                  content: Text('请填写正确的房屋面积和房间数量'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('确定'),
                    ),
                  ],
                );
              },
            );
            return;
        }
        switch (_currentType) {
          case RenovationType.fullRenovation:
            // 整装报价≈
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuotePackageListWidget(
                  renovationType: _currentType,
                  area: double.parse(_areaController.text),
                  bedroomCount: _roomList.firstWhere((room) => room.roomType == RoomType.bedroom).count,
                  livingRoomCount: _roomList.firstWhere((room) => room.roomType == RoomType.livingRoom).count,
                  bathroomCount: _roomList.firstWhere((room) => room.roomType == RoomType.bathroom).count,
                  kitchenCount: _roomList.firstWhere((room) => room.roomType == RoomType.kitchen).count,
                  
                ),
              ),
            );
            break;
          case RenovationType.renovation:
            // 翻新报价
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuoteRenovationAreaPageWidget(
                  renovationType: _currentType,
                  area: double.parse(_areaController.text),
                  roomList: _roomList,
                ),
              ),
            );
            break;
          case RenovationType.softFurnishing:
            // 软装报价
             print(_roomList);
            break;
        }
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
                '立即免费获取报价',
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