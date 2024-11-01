import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/dialog/bottom_sheet_selector.dart';
import 'package:flutter_smarthome/dialog/nickname_dialog.dart';
import '../models/user_model.dart';
import '../utils/user_manager.dart';
class PersonalInfoWidget extends StatefulWidget {
  const PersonalInfoWidget({super.key});

  @override
  State<PersonalInfoWidget> createState() => _PersonalInfoWidgetState();
}

class _PersonalInfoWidgetState extends State<PersonalInfoWidget> {
  UserModel? user; // 用户信息
  int? _selectedGenderIndex; // 选中的性别索引

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.white,
         title: Text('个人信息', style: TextStyle(color: Colors.black)),
         leading: IconButton(
           icon: Icon(Icons.arrow_back, color: Colors.black),
           onPressed: () {
             Navigator.pop(context);
           },
         ),
       ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 10.h),
            ListTile(
              title: const Text('头像'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // 可选：使头像呈圆形
                  color: Colors.grey[200], // 可选：添加背景色
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25), // 如果要圆形头像
                  child: Image.network(
                  user?.avatar ?? '',
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.cover,
                  ),
                ),
                ),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
              ),
              onTap: () {
                print('点击了头像');
              },
            ),
            //分割线
            Divider(
              indent: 20.w,
              endIndent: 20.w,
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: const Text('昵称'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.nickname ?? ''),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
              ),
              onTap: () {
                showNickNameDialog(context);
              },
            ),
            //分割线
            Divider(
              indent: 20.w,
              endIndent: 20.w,
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: const Text('简介'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.profile ?? ''),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
              ),
              onTap: () {
                showProfileDialog(context);
              },
            ),
            Divider(
              indent: 20.w,
              endIndent: 20.w,
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: const Text('性别'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.sex == '1' ? '男' : '女'),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
              ),
              onTap: () {
                showGenderSelector(context);
              },
            ),
            Divider(
              indent: 20.w,
              endIndent: 20.w,
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: const Text('城市'),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.city ?? ''),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
              ),
              onTap: () {
                print('点击了城市');
              },
            ),
          ],
        ),
    );
  }

  //修改昵称
  void showNickNameDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => NickNameDialog(
        controller: controller,
        title: '修改昵称',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          // 处理确认逻辑
          print(controller.text);
          Navigator.pop(context);
        },
      ),
    );
  }

  //更改简介
  void showProfileDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => NickNameDialog(
        controller: controller,
        title: '更改简介',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          // 处理确认逻辑
          print(controller.text);
          Navigator.pop(context);
        },
      ),
    );
  }

  //修改性别
void showGenderSelector(BuildContext context) {
    BottomSheetSelector.show(
      context: context,
      options: const ['男', '女'],
      initialSelectedIndex: _selectedGenderIndex,
      title: '选择性别',  // 可选
      onSelected: (index) {
        setState(() {
          _selectedGenderIndex = index;
        });
        // 处理选中逻辑
        print('选中了: ${index == 0 ? '男' : '女'}');
      },
    );
  }
}
