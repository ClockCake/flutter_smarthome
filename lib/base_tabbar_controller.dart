// base_tabbar_controller.dart
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'controllers/discover_home.dart';
import 'controllers/login.dart';
class BaseTabBarController extends StatefulWidget {
  @override
  _BaseTabBarControllerState createState() => _BaseTabBarControllerState();
}

class _BaseTabBarControllerState extends State<BaseTabBarController> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabItems = [
      DiscoverHomeWidget(),
      Center(child: Text("Home Page222")),
      Center(child: Text("Search Page333")),
      login(),

    ];
    return Scaffold(
      body: _tabItems[_selectedIndex],
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
}