import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/address_list.dart';
import 'package:flutter_smarthome/controllers/personal_order_detail.dart';
import 'package:flutter_smarthome/controllers/shopping_pay.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/view/cancel_order_dialog.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PersonalOrderListWidget extends StatefulWidget {
  final String orderStatus;
  const PersonalOrderListWidget({super.key,required this.orderStatus});

  @override
  State<PersonalOrderListWidget> createState() => _PersonalOrderListWidgetState();
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
class _PersonalOrderListWidgetState extends State<PersonalOrderListWidget> {
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> orderList = []; // 订单列表
  @override
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  void initState() {
    super.initState();
    _getOrderList();
  }
  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("上拉加载");
              } else if (mode == LoadStatus.loading) {
                body = CircularProgressIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("加载失败！点击重试！");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("松手加载更多");
              } else {
                body = Text("");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: orderList.isEmpty
            ? EmptyStateWidget(onRefresh: _onRefresh)
            : ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: _buildListCell(orderList[index]),
                    onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalOrderDetailWidget(id: orderList[index]['id'],)));
                    },
                  );
                },
              ),
       ),
      )
    );
  }
 

  Widget _buildListCell(Map<String, dynamic> item) {
    final business = item['customerCommodityShopOrderInfoItemRespVo'][0];
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Add alignment
        children: [
          SizedBox(height: 14.h),
          Row(
            children: [
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '订单编号: ${item['orderNumber']}',
                  style: TextStyle(
                    color: HexColor('#999999'),
                    fontSize: 13.sp,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Ensure proper alignment
            children: [
              SizedBox(width: 12.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: NetworkImageHelper().getCachedNetworkImage(
                  imageUrl: business['mainPic'],
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover, // Ensure the image fits within bounds
                ),
              ),
              SizedBox(width: 10.w),
              Expanded( // Use Expanded to ensure the Column takes up remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // 添加这一行
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business['name'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                        ),
                        Text(
                          _getOrderStatusText(item['orderStatus']),
                          style: TextStyle(color: HexColor('#CA9C72'), fontSize: 13.sp),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children:[
                        Wrap(
                          spacing: 4.w,
                          children: [
                            for (final tag in business['commodityProperty'].split(',')) // Add for loop
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: HexColor('#F8F8F8'),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: HexColor('#999999'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          'x${business['commodityNum']}',
                          style: TextStyle(
                            color: HexColor('#999999'),
                            fontSize: 14.sp,
                          ),
                        ),
                       SizedBox(width: 12.w),

                      ]
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                        '¥ ${item['payAmount']}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          ),

                        ),
                       SizedBox(width: 12.w),

                      ],
                    ),
                    SizedBox(height: 16.h),

                  ]
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (item['orderStatus'] == "1") // 待付款
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _cancelOrderDialog(context, item['id'])();
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
                    _modifyAddress(item['id']);
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingPayPageWidget(paymentAmount: '${item['payAmount'] ?? 0}',orderId: item['id'],orderNumber: item['orderNumber'],onPaymentComplete: () {
                      _onRefresh();
                    },)));
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
          if (item['orderStatus'] == "3") //待发货
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _modifyAddress(item['id']);
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
          if (item['orderStatus'] == "4") //待收货
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _confirmReceipt(item['id']);
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
          if (item['orderStatus'] == "5") //已完成
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
          if (item['orderStatus'] == "6") //已取消
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _deleteOrder(item['id']);
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
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  //取消订单弹窗
  Function _cancelOrderDialog(BuildContext context, String orderId) {
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
                orderId: orderId,
                onCancel: () => Navigator.pop(context),
                onConfirm: () => _onRefresh(),
              ),
            );
          },
        );
      };
  }

  //修改地址 事件
  void _modifyAddress(String orderId) {
    // 创建一个闭包来捕获 orderId
    void handleAddressSelected(Map<String, dynamic> address) {
      _handleAddressSelected(address, orderId);
    }
    
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AddressListWidget(
          onAddressSelected: handleAddressSelected,
        )
      )
    );
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
              Navigator.pop(context, true);
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }





  void _onRefresh() async {
    pageNum = 1;
    orderList.clear();
    try {
      // 执行数据刷新操作
      await _getOrderList(); // 或其他数据加载方法
      _refreshController.refreshCompleted(); // 完成刷新
    } catch (e) {
      _refreshController.refreshFailed(); // 刷新失败
    }

  }

  void _onLoading() async {
    pageNum++;
    await _getOrderList();
    if (orderList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //获取订单数据
  Future<void> _getOrderList() async {
    // 请求订单列表数据
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/personal/order/list',
        queryParameters: {
          'orderStatus':widget.orderStatus, //订单状态(1:待支付，2:已支付，3:待发货，4:待收货，5:待评价，6:已取消,7:退款）
      });
      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      if (response['rows'].isNotEmpty) {
        final arr = List<Map<String, dynamic>>.from(response['rows']);
        if(mounted) {
          setState(() {
             orderList.addAll(arr);
          });
        }

      }

    }
    catch(e) {
      print(e);
    }
  }

  //修改地址
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
    print('API响应: $response');
    
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
      _onRefresh();
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
      _onRefresh();
    } else {
      showToast('确认收货失败');
    }
  }
}