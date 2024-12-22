import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class ShopingPayPageWidget extends StatefulWidget {
  final String orderNumber;
  const ShopingPayPageWidget({super.key,required this.orderNumber});

  @override
  State<ShopingPayPageWidget> createState() => _ShopingPayPageWidgetState();
}
enum PaymentMethod { alipay, wechat }

class _ShopingPayPageWidgetState extends State<ShopingPayPageWidget> {
  PaymentMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         elevation: 0,
         backgroundColor: Colors.white,
         title: Text('支付订单', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
         leading: IconButton(
           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
           onPressed: () {
             Navigator.pop(context);
           },
         ),
      ),
      body: Column(
        children: [
          SizedBox(height: 28),
          Text('总计金额', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¥', style: TextStyle(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Text('199.00', style: TextStyle(color: Colors.black, fontSize: 34.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 30.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '选择支付方式', 
                style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)
              ),
            ),
          ), 
          SizedBox(height: 16.h),        
           GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = PaymentMethod.alipay;
              });
            },
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Image.asset(
                  'assets/images/icon_alipay.png',
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: 4), // Adjust spacing as needed
                Text(
                  '支付宝',
                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                ),
                Spacer(),
                Icon(
                  _selectedMethod == PaymentMethod.alipay
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.black,
                  size: 14.sp,
                ),
               SizedBox(width: 16.w),

              ],
            ),
          ),
          SizedBox(height: 16.h),
        // WeChat Pay Option
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = PaymentMethod.wechat;
              });
            },
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Image.asset(
                  'assets/images/icon_wechat_pay.png',
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: 4.w), // Adjust spacing as needed
                Text(
                  '微信支付',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Spacer(),
                Icon(
                  _selectedMethod == PaymentMethod.wechat
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.black,
                  size: 14.sp,
                ),
                SizedBox(width: 16.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}