import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

// 登录跳转Widget
class LoginRedirectWidget extends StatelessWidget {
  final VoidCallback? onLoginSuccess;
  final Widget child;

  const LoginRedirectWidget({
    Key? key,
    this.onLoginSuccess,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  Future<void> _handleLogin(BuildContext context) async {
     final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    
    if (result == true && onLoginSuccess != null) {
      onLoginSuccess!();
    }
  }
}

// 示例按钮组件
class GoLoginButton extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const GoLoginButton({
    Key? key,
    this.onLoginSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginRedirectWidget(
      onLoginSuccess: onLoginSuccess,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              height: 400.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //图片
                  Image.asset(
                    'assets/images/icon_redirect.png',
                    width: 200.w,
                    height: 115.h,
                  ),
                  Text(
                    '登录后可查看',
                    style: TextStyle(
                      color: HexColor('#999999'),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    //背景色
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      
                    ),

                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                       if (result == true && onLoginSuccess != null) {
                        print("即将执行登录成功回调");
                        onLoginSuccess!();
                      }
                    },
                    child: Text(
                      '去登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}