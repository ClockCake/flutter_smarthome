// base_tabbar_controller.dart
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_segments.dart';
import 'package:flutter_smarthome/controllers/my_project_list.dart';
import 'package:flutter_smarthome/controllers/native_page.dart';
import 'package:flutter_smarthome/controllers/shopping_home.dart';
import 'controllers/discover_home.dart';
import 'controllers/login_page.dart';
import 'controllers/personal_home.dart';  
import 'package:permission_handler/permission_handler.dart';
class BaseTabBarController extends StatefulWidget {
  @override
  _BaseTabBarControllerState createState() => _BaseTabBarControllerState();
}

class _BaseTabBarControllerState extends State<BaseTabBarController> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    checkPermission(); // 检查权限
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabItems = [
      DiscoverHomeWidget(),
      NativePageWidget(),
      ShoppingHomeWidget(),
      PersonalHomeWidget(),

    ];
    return Scaffold(
      body:IndexedStack(
          index: _selectedIndex,
          children: _tabItems,
        ),
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: false, // 去除 AppBar 的阴影
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          FlashyTabBarItem(
            icon: Image.asset('assets/images/icon_tabbar_first.png'),
            title: Text('发现', style: TextStyle(color: Colors.black),),
          ), 
          FlashyTabBarItem(
              icon: Image.asset('assets/images/icon_tabbar_second.png'),
              title: Text('爱家',style: TextStyle(color: Colors.black),),
          ),
          FlashyTabBarItem(
            icon: Image.asset('assets/images/icon_tabbar_third.png'),
            title: Text('惊喜',style: TextStyle(color: Colors.black),),
          ),
          FlashyTabBarItem(
            icon: Image.asset('assets/images/icon_tabbar_four.png'),
            title: Text('我的',style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    );
  }
  void checkPermission() async {
    // 先申请“使用期间”权限
    PermissionStatus inUseStatus = await Permission.locationWhenInUse.status;
    if (!inUseStatus.isGranted) {
      inUseStatus = await Permission.locationWhenInUse.request();
    }
    // 如果“使用期间”权限已通过，再申请“始终”权限
    if (inUseStatus.isGranted) {
      PermissionStatus alwaysStatus = await Permission.locationAlways.status;
      if (!alwaysStatus.isGranted) {
        alwaysStatus = await Permission.locationAlways.request();
      }
      if (!alwaysStatus.isGranted) {
        // openAppSettings();
      }
    } else {
      // 若“使用期间”权限未通过，则直接跳转到设置
      // openAppSettings();
    }
  }

  //申请权限
void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    print('权限状态$status');
    if (!status.isGranted) {
       openAppSettings();
    }
  }
}

