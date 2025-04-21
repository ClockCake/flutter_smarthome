import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/personal_order_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class ShoppingPayPageWidget extends StatefulWidget {
  final String orderNumber;
  final String paymentAmount;
  final String orderId;
  final VoidCallback? onPaymentComplete; // 添加可选回调


  const ShoppingPayPageWidget({super.key,required this.orderNumber,required this.paymentAmount, required this.orderId,this.onPaymentComplete, });

  @override
  State<ShoppingPayPageWidget> createState() => _ShoppingPayPageWidgetState();
}
enum PaymentMethod { alipay, wechat }

class _ShoppingPayPageWidgetState extends State<ShoppingPayPageWidget> with WidgetsBindingObserver{
  PaymentMethod? _selectedMethod;
  bool _goPay = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 添加观察者

  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    super.dispose();
  }
    // 添加生命周期监听
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _goPay == true) {
      // 重新进入应用
      _goPay = false;
      if(widget.onPaymentComplete != null){
        Navigator.pop(context);
        widget.onPaymentComplete!();
      }
      
    }
  }
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
              Text('${widget.paymentAmount}', style: TextStyle(color: Colors.black, fontSize: 34.sp, fontWeight: FontWeight.bold)),
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
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.black,
                  size: 20.sp,
                ),
               SizedBox(width: 16.w),

              ],
            ),
          ),
          SizedBox(height: 20.h),
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
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.black,
                  size: 20.sp,
                ),
                SizedBox(width: 16.w),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: ElevatedButton(
          onPressed: () {
            payAmountData();
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
              '确认支付',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
      )
    );
  }


  Future<void> payAmountData() async {
    final apiManager = ApiManager();
    final response = await apiManager.post(
      '/api/shopping/pay/unionpay',
      data: {"paymentAmount":widget.paymentAmount,"orderNumber":widget.orderNumber,"orderId":widget.orderId}
    );
    if(response != null){
      if (_selectedMethod == PaymentMethod.alipay) {
        // Handle Alipay payment
      } else if (_selectedMethod == PaymentMethod.wechat) {
        // Handle WeChat payment
        _shareToWeChat(response['qrcode']);
      }
    }
  }

  void _shareToWeChat(String payUrl) {
    _goPay = true;
    final fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION; // 可以选择 SESSION（会话）或 TIMELINE（朋友圈）

    final fluwx.WeChatShareWebPageModel shareModel = fluwx.WeChatShareWebPageModel(
      payUrl,
      title: "支付",
      description: "打开支付链接",
      thumbnail: fluwx.WeChatImage.network("https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png"),
      scene: scene,
    );
 
    fluwx.shareToWeChat(shareModel).then((success) {
      if (success) {
        print("分享成功");
      } else {
        print("分享失败");
      }
    });
  }
}