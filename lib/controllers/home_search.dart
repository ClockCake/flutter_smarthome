import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/search_result.dart';

class HomeSearchPage extends StatefulWidget { 
  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  final TextEditingController _controller = TextEditingController(); 

  final List<String> historyTags = [
    '奶油风案例',
    '简约风案例',
    '设计师张凌林',
    '沙发',
    '床头柜',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36.h, // 搜索框高度
                      child: TextField(
                        controller: _controller, // 设置 controller
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomeResultPageWidget(searchStr: value)), // 跳转到下一个页面
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text('取消', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 16.w),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '历史搜索',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: historyTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(color: Colors.black),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

