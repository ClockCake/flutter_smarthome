import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/address_list.dart';
import 'package:flutter_smarthome/models/user_model.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/cache_util.dart';
import 'package:flutter_smarthome/utils/custom_webview.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; 
import 'package:package_info_plus/package_info_plus.dart';
import './personal_info.dart';
import 'package:flutter/services.dart'; 

class PersonalSettingWidget extends StatefulWidget {
  const PersonalSettingWidget({super.key});

  @override
  State<PersonalSettingWidget> createState() => _PersonalSettingWidgetState();
}

class _PersonalSettingWidgetState extends State<PersonalSettingWidget> {
  //标题数组
  List<String> _titleList = ['个人信息', '收货地址管理', '隐私政策', '清除缓存', '版本'];

  String? _cacheSize; // 新增状态变量来存储缓存大小
  static const platform = MethodChannel('com.your.app/login');

  @override
  void initState() {
    super.initState();
    _updateCacheSize(); // 初始化时获取缓存大小
  }

  // 新增更新缓存大小的方法
  Future<void> _updateCacheSize() async {
    final size = await CacheUtil.getCacheSize();
    setState(() {
      _cacheSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('设置', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _titleList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_titleList[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // 重要：让 Row 收缩到内容大小
                    children: [
                      if (index == 3)
                        Text(_cacheSize ?? '')
                      else if (index == 4)
                        FutureBuilder<String>(
                          future: PackageInfo.fromPlatform().then((info) => info.version),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            return Text(snapshot.data ?? '');
                          },
                        ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),

                  onTap: () async{
                    switch (index) {
                      case 0:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfoWidget()));
                        break;
                      case 1:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddressListWidget()));
                        break;
                      case 2:
                        //隐私政策
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomWebView(
                              url: 'https://www.baidu.com',
                              title: '网页标题',
                            ),
                          ),
                        );

                        break;
                      case 3:
                        //清除缓存
                        await CacheUtil.clearCacheAndUpdate();
                        setState(() {
                          _cacheSize = ''; // 清除缓存后将缓存大小设置为空字符串
                        });
                        showToast('清除缓存成功');
                        break;
                      case 4:
                        //版本
                        showToast('当前已是最新版本');
                        break;
                      default:
                    }
                  },
                );
              },
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                //退出登录
               _logout();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.black,

                ),
                margin: EdgeInsets.fromLTRB(20.w, 0, 20.w,20.h),
                height: 44.h,
                alignment: Alignment.center,
                child: Text('退出登录', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }

  //退出登录
  Future<void> _logout() async {
    // 显示确认对话框
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('确定要退出登录吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    final user = UserManager.instance.user;
    print(user);
    try {
      final apiManager = ApiManager();
      final response = await apiManager.delete(
        '/api/login/logout',
        data: null,
      );

       if (response != null) {
        await UserManager.instance.clearUser();
        
        // 调用原生涂鸦退出登录
        try {
          await platform.invokeMethod('tuyaLogout');
          print('涂鸦退出登录成功');
        } catch (e) {
          print('涂鸦退出登录失败: $e');
        }

        showToast('退出登录成功');
        
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      showToast('退出登录失败: ${e.toString()}');
    }
  }
  
}

