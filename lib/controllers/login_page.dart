import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:oktoast/oktoast.dart';
import '../network/api_manager.dart';
import '../utils/user_manager.dart';
import '../models/user_model.dart';
import '../base_tabbar_controller.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isChecked = true;
  bool _isGettingCode = false;
  int _countdown = 60;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // UI Components
  Widget _buildHeader() {
    return Container(
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
      width: double.infinity,
      height: 150.h + MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          Positioned(
            left: 24.w,
            top: MediaQuery.of(context).padding.top + 20.h,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              
              child: Icon(
                //关闭按钮 
                Icons.close,
                color: HexColor('#222222'),
                size: 24.sp,
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            bottom: 20.h,
            child: Text(
              '手机验证码登录',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 40.h, right: 24.w),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 11,
        decoration: InputDecoration(
          hintText: '请输入手机号',
          counterText: '',
          hintStyle: TextStyle(
            color: HexColor('#999999'),
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: HexColor('#EEEEEE'),
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: HexColor('#FECC87'),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 20.h, right: 24.w),
      child: TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          hintText: '请输入验证码',
          counterText: '',
          hintStyle: TextStyle(
            color: HexColor('#999999'),
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: HexColor('#EEEEEE'),
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: HexColor('#FECC87'),
              width: 1,
            ),
          ),
          suffixIcon: GestureDetector(
            onTap: _getVerificationCode,
            child: Padding(
              padding: EdgeInsets.only(right: 8.w, top: 10.h),
              child: Text(
                _isGettingCode ? '$_countdown s' : '获取验证码',
                style: TextStyle(
                  color: _isGettingCode ? HexColor('#999999') : HexColor('#FECC87'),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 60.h, right: 24.w),
      child: ElevatedButton(
        onPressed: _handleLogin,
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
    );
  }

  Widget _buildAgreement() {
    return Row(
      children: [
        SizedBox(width: 24.w),
        Checkbox(
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.all(HexColor('#FFB26D')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 24.w, left: 2.w),
            child: Text(
              '登录即代表同意《中国移动认证服务条款》及极家《用户协议》和《个人信息隐私条款》',
              style: TextStyle(
                color: HexColor('#999999'),
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  // Logic Methods
  bool _validateParams() {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty) {
      showToast('请输入手机号');
      return false;
    }

    if (phone.length != 11) {
      showToast('请输入正确的手机号');
      return false;
    }

    if (code.isEmpty) {
      showToast('请输入验证码');
      return false;
    }

    if (code.length != 6) {
      showToast('请输入正确的验证码');
      return false;
    }

    if (!_isChecked) {
      showToast('请阅读并同意服务条款');
      return false;
    }

    return true;
  }

  Future<void> _getVerificationCode() async {
    if (_isGettingCode) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    if (phone.length != 11) {
      showToast('请输入正确的手机号');
      return;
    }

    try {
      setState(() {
        _isGettingCode = true;
        _countdown = 60;
      });

      // 发送验证码请求
      final response = await ApiManager().post('/api/login/verification/code', data: {'phone': phone});
      if (response != null) {
        showToast('验证码已发送');
        _startCountdown();
      } else {
        // 如果响应为空，表示请求失败
        setState(() {
          _isGettingCode = false;
          _countdown = 60;
        });
        showToast('获取验证码失败，请重试');
      }
    } catch (e) {
      setState(() {
        _isGettingCode = false;
        _countdown = 60;
      });
      showToast('获取验证码失败，请重试');
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) {
        return false;
      }
      
      if (_countdown <= 1) {
        setState(() {
          _countdown = 0;
          _isGettingCode = false;
        });
        return false;
      }
      
      setState(() {
        _countdown--;
      });
      
      return true;
    });
  }

  Future<void> _handleLogin() async {
    if (!_validateParams()) return;

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    try {
      //发起登录请求
      final response = await ApiManager().post(
        '/api/login/via-code',
        data: {
          'mobile': phone,
          'code': code,
        },
      );

      if (response != null) {
        // 处理登录成功
        UserModel user = UserModel.fromJson(response);
        await UserManager.instance.saveUser(user);
        // 在登录页面登录成功后
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => BaseTabBarController()),
        // );
        Navigator.pop(context);


      }
    } catch (e) {
      showToast('登录失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildPhoneInput(),
          _buildCodeInput(),
          _buildLoginButton(),
          const Spacer(),
          _buildAgreement(),
          SizedBox(height: 30.h + bottomPadding),
        ],
      ),
    );
  }
}