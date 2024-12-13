import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入 shared_preferences

class HomeSearchPage extends StatefulWidget {
  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  final TextEditingController _controller = TextEditingController(); 

  final List<String> historyTags = [
    // 历史记录将存储在这里
  ];
  @override
  void initState() {
    super.initState();
    _loadHistoryTags(); // 初始化加载历史记录
  }
  @override
  void dispose() {
    _controller.dispose(); // 释放 TextEditingController
    super.dispose();
  }
  // 加载历史记录的方法
  Future<void> _loadHistoryTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tags = prefs.getStringList('historyTags');
    if (tags != null) {
      setState(() {
        historyTags.addAll(tags);
      });
    }
  }

  // 保存历史记录的方法
  Future<void> _saveHistoryTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('historyTags', historyTags);
  }

  // 添加历史记录的方法
  void _addHistoryTag(String tag) {
    setState(() {
      if (!historyTags.contains(tag)) {
        historyTags.add(tag);
        _saveHistoryTags(); // 保存到 SharedPreferences
      }
    });
  }

  // 清空历史记录的方法
  void _clearHistoryTags() {
    setState(() {
      historyTags.clear();
      _saveHistoryTags(); // 同步清空 SharedPreferences 中的数据
    });
  }

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
                            _addHistoryTag(value); // 记录搜索关键字
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
            historyTags.isNotEmpty ? Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '热门搜索',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                             // 确定弹框
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('提示'),
                                  content: Text('是否清空历史搜索记录？'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          historyTags.clear();
                                        });
                                      },
                                      child: Text('确定'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          // 本地图片
                          child: Image.asset('assets/images/icon_search_delete.png',width: 13.w,height: 13.w,),
                        ),
                        SizedBox(width: 8.0),
                      ],
                    ),
               
                    SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: historyTags.map((tag) {
                        return ActionChip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(color: Colors.black),
                          onPressed: () {
                            setState(() {
                              _controller.text = tag; // 填充搜索框
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ):Container(
              child: Center(
                child: Text(''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

