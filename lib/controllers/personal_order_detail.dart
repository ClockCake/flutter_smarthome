import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/view/cancel_order_dialog.dart';
import 'package:oktoast/oktoast.dart';

class PersonalOrderDetailWidget extends StatefulWidget {
  final String id;
  const PersonalOrderDetailWidget({super.key,required this.id});

  @override
  State<PersonalOrderDetailWidget> createState() => _PersonalOrderDetailWidgetState();
}

class _PersonalOrderDetailWidgetState extends State<PersonalOrderDetailWidget> {
  Map<String,dynamic> orderDetail = {};
  @override
  void initState() {
    super.initState();
    _getOrderDetail();
  }
  @override
  void dispose() {
      super.dispose();
  }

  String _getOrderStatusText(String status) {
  switch (status) {
    case '1':
      return '待付款';
    case '2':
      return '已支付';
    case '3':
      return '待发货';
    case '4':
      return '待收货';
    case '5':
      return '待评价';
    case '6':
      return '已取消';
    case '7':
      return '退款';
    default:
      return '';
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(_getOrderStatusText(orderDetail['orderStatus'] ?? ""), style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopAddress(),
              _buildOrderInfo(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context,orderDetail['orderStatus']),
    );
  }

   //构建收货地址
  Widget _buildTopAddress(){
    final address = orderDetail['commodityShopAddressRespVo'] ?? {};
    return Container(
      width: double.infinity,
      height: 76.h,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          address['firstName'] == null ?  Padding(padding: EdgeInsets.all(16.w), child:Text('请添加收货地址', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),)
          :
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3.h,),
              Text('${address['firstName']} ${address['phoneNumber']}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h,),
              Text('${address['detailedAddress']}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              SizedBox(height: 4.h,),
            ]
          ),
        ],
      ),
    );
  }

Widget _buildOrderInfo(){
  return Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 0.w, 0.h),
          child: Text(
            '订单信息',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16.h,),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          //设置间距

          itemBuilder: (context, index) {
            return _buildBusinessInfo(orderDetail['customerCommodityShopOrderInfoItemRespVos'][index]);
          },
          separatorBuilder: (context, index) => SizedBox(height: 8.0), // 设置间距

          itemCount: orderDetail['customerCommodityShopOrderInfoItemRespVos'].length,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            SizedBox(width: 16.w),
            Text('商品总价', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
            Spacer(),
            Text('¥ ${orderDetail['payAmount'] ?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            SizedBox(width: 16.w),
            Text('运费', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
            Spacer(),
            Text('¥ ${orderDetail['freightAmount']?? 0}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 16.h),
        //分割线
        Container(
          width: double.infinity,
          height: 1.h,
          color: HexColor('#F0F0F0'),
        ),
        SizedBox(height: 16.h),
        if(orderDetail['orderStatus'] == "5" || orderDetail['orderStatus'] == "6") ...[
          Row(
            children: [
              SizedBox(width: 16.w),
              Text('收货信息', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('${orderDetail['commodityShopAddressRespVo']['firstName']} ${orderDetail['commodityShopAddressRespVo']['phoneNumber']} ${orderDetail['commodityShopAddressRespVo']['detailedAddress']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 16.h),
        ],
        Row(
          children: [
            SizedBox(width: 16.w),
            Text('订单编号', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
            Spacer(),
            Text('${orderDetail['orderNumber']} |', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
            GestureDetector(
              onTap: () {
                //复制订单编号
                Clipboard.setData(ClipboardData(text: orderDetail['orderNumber'])).then((_) {
                  // 复制成功后，可以显示一个提示（比如使用 Snackbar）
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('订单编号已复制')));
                });
              },
              child: Text(
                '复制',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: HexColor('#CA9C72'),
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            SizedBox(width: 16.w),
            Text('创建时间', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
            Spacer(),
            Text('${orderDetail['createTime']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 16.h),
        if (orderDetail['orderStatus'] == "3" || orderDetail['orderStatus'] == "4" || orderDetail['orderStatus'] == "5")...[ //待发货
          Row(
            children: [
              SizedBox(width: 16.w),
              Text('付款时间', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('${orderDetail['payTime'] ?? ""}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 16.h),
        ],
        if (orderDetail['orderStatus'] == "4" || orderDetail['orderStatus'] == "5")...[ //待收货
          Row(
            children: [
              SizedBox(width: 16.w),
              Text('发货时间', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('${orderDetail['deliveryTime'] ?? ""}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 16.h),

        ],
        if (orderDetail['orderStatus'] == "5")...[ //已完成
          Row(
            children: [
              SizedBox(width: 16.w),
              Text('完成时间', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('${orderDetail['finishTime'] ?? ""}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 16.h),

        ],
        if (orderDetail['orderStatus'] == "6")...[ //已取消
          Row(
            children: [
              SizedBox(width: 16.w),
              Text('取消时间', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('${orderDetail['cancelTime'] ?? ""}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333'))),
              SizedBox(width: 16.w),
            ],
          ),
          SizedBox(height: 16.h),

        ],
      ],
    ),
  );
}

Widget _buildBusinessInfo(Map<String,dynamic> business){
  return Container(
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 12.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: business['mainPic'] ?? "",width: 80.w,height: 80.h),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              business['name'] ?? "",
              style: TextStyle(
                fontSize: 14.sp,
                color: HexColor('#333333'),
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 4.w,
              children: [
                for (var spec in business['commodityProperty'].split(','))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: HexColor('#F8F8F8'),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      '$spec',
                      style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  '¥ ${business['salesPrice'] ?? 0}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: HexColor('#333333'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '积分 ${business['pointPrice'] ?? 0}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HexColor('#CA9C72'),
                  ),
                ),
              ],
            )

          ],
        ),
        Spacer(),
        Text(
          'x${business['commodityNum']}',
          style: TextStyle(
            fontSize: 12.sp,
            color: HexColor('#999999'),
          ),
        ),
        // SizedBox(width: 16.w),
      ],
    ),
  );
}

 Widget _buildBottomBar(BuildContext context,String status) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      height: 44.h + bottomPadding,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 10.h,),
          if (orderDetail['orderStatus'] == "1") // 待付款
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _cancelOrderDialog(context)();
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '取消订单',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    // Handle cancellation
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '修改地址',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    // Handle payment
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '付款',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),
              ],
            ),
          if (orderDetail['orderStatus'] == "3") //待发货
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle cancellation
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '修改地址',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (orderDetail['orderStatus'] == "3") //待收货
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _confirmReceipt(widget.id);
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '确认收货',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (orderDetail['orderStatus'] == "5") //已完成
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle cancellation
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '去评价',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (orderDetail['orderStatus'] == "6") //已完成
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _deleteOrder(widget.id);
                  },
                  child: Container(
                    width: 74.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: HexColor('#D0D0D0')),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '删除订单',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: bottomPadding),
        ],

      ),
    );
 }
 //取消订单
 Function _cancelOrderDialog(BuildContext context) {
    return () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent, // 设置背景为透明
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: CancelOrderDialogWidget(
              orderId: widget.id,
              onCancel: () => Navigator.pop(context),
              onConfirm: () => _getOrderDetail(),
            ),
          );
        },
      );
    };
  }


//获取订单详情
 Future<void> _getOrderDetail() async {
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/personal/order/detail',
        queryParameters: {"id":widget.id}
      );
      if(response != null){
        setState(() {
          orderDetail = Map<String,dynamic>.from(response);
        });
      }
    }
    catch(e){
      print(e);
    }
 }

  Future<void> _handleAddressSelected(Map<String, dynamic> address, String orderId) async {
    try {
      bool? confirm = await _showConfirmDialog(address);
      
      if (confirm == true) {
        await _updateOrderAddress(orderId, address);
      }
    } catch (e) {
      print('发生错误: $e');
      showToast('操作失败：$e');
    }
  }

  Future<bool?> _showConfirmDialog(Map<String, dynamic> address) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('提示'),
        content: Text('确定选择该地址吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              print('选中的地址信息: $address');
              setState(() {
                orderDetail['commodityShopAddressRespVo'] = address;  
              });
              Navigator.pop(context, true);
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
  //更新订单地址
  Future<void> _updateOrderAddress(String orderId, Map<String, dynamic> address) async {
    final apiManager = ApiManager();
    print('开始调用API');
    final response = await apiManager.put(
      '/api/personal/order/edit/address',
      data: {
        'id': orderId,
        'commodityShopAddressId': address['id'],
      },
    );
    
    if(response != null) {
      showToast('修改地址成功');

    } else {
      showToast('修改地址失败');
    }
  }

    //删除订单
  Future<void> _deleteOrder(String orderId) async {
    final apiManager = ApiManager();
    final response = await apiManager.deleteWithList(
      '/api/personal/order/delete',
      data: [orderId],
    );
    if(response != null) {
      showToast('删除订单成功');
      _getOrderDetail();
    } else {
      showToast('删除订单失败');
    }
  }

  //确认收货
  Future<void> _confirmReceipt(String orderId) async {
    final apiManager = ApiManager();
    final response = await apiManager.put(
      '/api/personal/order/confirm/receipt',
      data: {
        'id': orderId,
      },
    );
    if(response != null) {
      showToast('确认收货成功');
      _getOrderDetail();
    } else {
      showToast('确认收货失败');
    }
  }
  
}


