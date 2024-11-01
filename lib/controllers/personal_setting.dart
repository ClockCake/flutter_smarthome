import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/models/user_model.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';
import 'package:oktoast/oktoast.dart';
import './personal_info.dart';
class PersonalSettingWidget extends StatefulWidget {
  const PersonalSettingWidget({super.key});

  @override
  State<PersonalSettingWidget> createState() => _PersonalSettingWidgetState();
}

class _PersonalSettingWidgetState extends State<PersonalSettingWidget> {
  //标题数组
  List<String> _titleList = ['个人信息', '收货地址管理', '隐私政策', '清除缓存', '版本'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('设置', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    switch (index) {
                      case 0:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfoWidget()));
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/address_manage');
                        break;
                      case 2:
                        Navigator.pushNamed(context, '/privacy_policy');
                        break;
                      case 3:
                        //清除缓存
                        break;
                      case 4:
                        //版本
                        break;
                      default:
                    }
                  },
                );
              },
            ),
            Spacer(),
            InkWell(
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

