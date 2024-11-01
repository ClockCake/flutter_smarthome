import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
}