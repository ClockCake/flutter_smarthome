import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/dialog/bottom_sheet_selector.dart';
import 'package:flutter_smarthome/dialog/nickname_dialog.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../utils/user_manager.dart';
import 'package:city_pickers/city_pickers.dart';

class PersonalInfoWidget extends StatefulWidget {
  const PersonalInfoWidget({super.key});

  @override
  State<PersonalInfoWidget> createState() => _PersonalInfoWidgetState();
}

class _PersonalInfoWidgetState extends State<PersonalInfoWidget> {
  UserModel? user; // 用户信息
  int? _selectedGenderIndex; // 选中的性别索引
  //用户字典
  Map<String, dynamic> userDict = {};

  @override
  void initState() {
    super.initState();
    user = UserManager.instance.user;
    userDict = {
      'nickname': user?.nickname,
      'avatar': user?.avatar,
      'sex':user?.sex,
      'city': user?.city,
      'profile': user?.profile,

    };
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
                showAvatarDialog(context);
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
              onTap: ()  {
                getResult().then((value) {
                  if (value == null) {
                    return;
                  }
                  String address = '${value?.provinceName}-${value?.cityName}-${value?.areaName}';
                  userDict['city'] = address;
                  _handleEditPersonalInfo().then((value) => {
                    UserManager.instance.updateUser((p0) => 
                      p0.city = address
                    ),
                  });
                });
              },
            ),
          ],
        ),
    );
  }

  //修改头像
  void showAvatarDialog(BuildContext context) async{
    final File? imageFile = await ImagePickerUtils.showImagePickerDialog(context);

    // 处理选择结果
    if (imageFile != null) {
      userDict['avatar'] = await uploadImage(imageFile);
      _handleEditPersonalInfo().then((value) {
        UserManager.instance.updateUser((p0) => 
          p0.avatar = userDict['avatar']
        );
      });
      // 可以在这里进行图片上传等操作
      print('选中的图片路径: ${imageFile.path}');
    }
  } 

   // 上传图片
  Future<String?> uploadImage(File imageFile) async {

    final response = await ApiManager().uploadImage('/api/personal/file/upload/oss', imageFile.path);
    return response.data['url'];
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
          userDict['nickname'] = controller.text;
          _handleEditPersonalInfo().then((value) {
            UserManager.instance.updateUser((p0) => 
              p0.nickname = controller.text
            );
            Navigator.pop(context);
          });
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
          userDict['profile'] = controller.text;
          _handleEditPersonalInfo().then((value) {
            UserManager.instance.updateUser((p0) => 
              p0.profile = controller.text
            );
            Navigator.pop(context);

          });

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
        userDict['sex'] = index == 0 ? '1' : '2';
        setState(() {
          _selectedGenderIndex = index;
        });

        _handleEditPersonalInfo().then((value) {
          UserManager.instance.updateUser((p0) => 
            p0.sex = index == 0 ? '1' : '2'
          );
        });

      },
    );
  }

  //修改城市
  Future<Result?> getResult () async {
    
    Result? cityPickerResult = await CityPickers.showCityPicker(
      context: context,
    );
    return cityPickerResult;
  }


  Future<void> _handleEditPersonalInfo() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.put(
        '/api/personal/edit/info',
        data: userDict,
      );

      if (response != null) {
        showToast('修改成功');
        setState(() {
           
        });

      }
    } catch (e) {
      showToast('修改失败，请重试');
    }
  }
}
