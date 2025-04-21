import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:oktoast/oktoast.dart';

class CancelOrderDialogWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String orderId;
  const CancelOrderDialogWidget({
    Key? key,
    required this.orderId,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _CancelOrderDialogWidgetState createState() => _CancelOrderDialogWidgetState();
}

class _CancelOrderDialogWidgetState extends State<CancelOrderDialogWidget> {
  final List<String> list = ['规格/款式/数量 错拍', '收货地址填错', '不想要了', '其它'];
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final double ScreenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 350.h + bottomPadding, // 控制弹窗高度
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: ScreenWidth * 0.4),
              Text(
                '取消订单',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 12.w),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              '请选择取消订单的原因：',
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(list.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: InkWell(
                onTap: () => setState(() => selectedIndex = index),
                child: Row(
                  children: [
                    Text(
                      list[index],
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    ),
                    Spacer(),
                    Checkbox(
                      shape: CircleBorder(),
                      checkColor: Colors.white,
                      activeColor: Colors.black,
                      value: selectedIndex == index,
                      onChanged: (value) {
                        if (value == true) {
                          setState(() => selectedIndex = index);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: widget.onCancel,
                child: Container(
                  width: 163.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: Text('暂不取消', style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (selectedIndex != null) {
                    await putCancelOrderData();
                  } else {
                    showToast('请选择取消订单的原因');
                  }
                },
                child: Container(
                  width: 163.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: Text('确认取消', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> putCancelOrderData() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.put(
        '/api/personal/order/cancel',
        data: {
          'id':widget.orderId,
          'cancelReason': list[selectedIndex!],
        },
      );
      if (response != null) {
        Navigator.pop(context);
        showToast('取消订单成功');
      } else {
        showToast('取消订单失败');
      }
      if(widget.onConfirm != null) {
        widget.onConfirm!();
      }
    } catch (e) {
      showToast('取消订单失败');
    }
  }
}