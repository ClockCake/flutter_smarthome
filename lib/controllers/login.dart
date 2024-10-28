import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  HexColor('#E8D6BE').withOpacity(0.15),
                  HexColor('#FECC87').withOpacity(0.15),
                ],
              ),
            ),
            // 你可以指定容器的大小
            width: double.infinity,  // 宽度占满父组件
            //200 + 设备导航栏高度
            height: 150.h + MediaQuery.of(context).padding.top,
            child: Stack(
              children: [
                Positioned(
                  left: 24.w,
                  bottom: 20.h,  // 距离底部20
                  child: Text(
                  '手机验证码登录',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                 ),
                )
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.w, top: 40.h,right: 24.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: '请输入手机号',
                hintStyle: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(  // 添加底部分割线
                  borderSide: BorderSide(
                    color: HexColor('#EEEEEE'),  // 分割线颜色
                    width: 1,  // 分割线粗细
                  ),
                ),
                    // 可选：当输入框获得焦点时的边框样式
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: HexColor('#FECC87'),  // 获得焦点时的分割线颜色
                    width: 1,
                  ),
                ),
              ),
              
            )

          ),
          Padding(
            padding: EdgeInsets.only(left: 24.w, top: 20.h,right: 24.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: '请输入验证码',
                hintStyle: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(  // 添加底部分割线
                  borderSide: BorderSide(
                    color: HexColor('#EEEEEE'),  // 分割线颜色
                    width: 1,  // 分割线粗细
                  ),
                ),
                    // 可选：当输入框获得焦点时的边框样式
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: HexColor('#FECC87'),  // 获得焦点时的分割线颜色
                    width: 1,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    // 这里添加获取验证码的点击事件
                    print('获取验证码');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w,top: 10.h),  // 可选：调整右侧内边距
                    child: Text(
                      '获取验证码',
                      style: TextStyle(
                        color: HexColor('#FECC87'),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                // 可选：调整右侧内边距
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              
            )
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.w, top: 40.h,right: 24.w),
            child: ElevatedButton(
              onPressed: () {
                // 这里添加登录按钮的点击事件
                print('登录');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(HexColor('#222222')),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                )),
              ),
              child: Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                child: Text(
                  '登录',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              //勾选框
              
            ],
          )

        ],
      ),
    );
  }
}