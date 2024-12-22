import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/address_list.dart';
import 'package:flutter_smarthome/controllers/shopping_pay.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class ShoppingOrderWidget extends StatefulWidget {
  final List<Map<String, dynamic>> businessList;
  const ShoppingOrderWidget({super.key,required this.businessList});

  @override
  State<ShoppingOrderWidget> createState() => _ShoppingOrderWidgetState();
}
enum PaymentMethod { alipay, wechat }

class _ShoppingOrderWidgetState extends State<ShoppingOrderWidget> {
  PaymentMethod? _selectedMethod;

  Map<String, dynamic> address = {};
  Map<String, dynamic> points = {};
  bool isUseCash = true;

  @override
  void initState() {
    super.initState();
    _getAddressListData();
    _getPoints();
  }
  @override 
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      // 应用从 #FFB26D 到 #F8F8F8 的线性渐变
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFB26D), // 起始颜色
            Color(0xFFF8F8F8), // 结束颜色
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 使 Scaffold 背景透明
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent, // 使 AppBar 背景透明
          title:  Text(
            '确认订单',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddressListWidget(onAddressSelected: _handleAddressSelected,)));
                },
                child: _buildTopAddress(),
              ),
            
              _buildBusinessList(),
              _buildPayInfo(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  void _handleAddressSelected(Map<String, dynamic> address) {
    setState(() {
      this.address = address;
    });
  }
 Widget _buildBottomBar(BuildContext context) {
    final item = widget.businessList[0];
      return Container(
        color: Colors.white, // 设置整个背景为白色
        child: SafeArea(
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: Colors.white,
            
            ),
            child: Row(
              children: [
                Text('合计:', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999'))),
                SizedBox(width: 2.w,),
                Text('￥${_calculateTotalPrice()}', style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    _submitOrder();
                  },
                  child: Container(
                    width: 120.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Center(
                      child: Text('立即下单', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }
 //构建收货地址
  Widget _buildTopAddress(){
    return Container(
      width: double.infinity,
      height: 76.h,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
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
          Spacer(),
          Icon(Icons.arrow_forward_ios, color: Colors.grey,size: 14.sp,),
        ],
      ),
    );
  }

  //计算总价
  double _calculateTotalPrice(){
    double totalPrice = 0;
    for (var item in widget.businessList) {
      var price = item['salesPrice'];
      if (price != null) {
        totalPrice += price * item['quantity'];
      }
    }
    return totalPrice;
  }
 
  //构建商品信息
  Widget _buildBusinessList(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.businessList.length,
            itemBuilder: (context, index){
              return _buildBusinessCell(widget.businessList[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 10.h), // 设置间距
          ),
          //分割线
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            height: 1.h,
            color: HexColor('#F8F8F8'),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('商品总价', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('￥${_calculateTotalPrice()}', style: TextStyle(fontSize: 14.sp, color: Colors.black,fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4.h,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('运费', style: TextStyle(fontSize: 14.sp, color: HexColor('#999999'))),
              Spacer(),
              Text('￥0', style: TextStyle(fontSize: 14.sp, color: Colors.black,fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  //商品信息cell
  Widget _buildBusinessCell(Map<String, dynamic> business){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: business['mainPic'],
            width: 80.w,
            height: 80.h,
          ),
        ),
        SizedBox(width: 16.w,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(business['name'], style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 4.h,),
            //商品规格
            Wrap(
              spacing: 4.w,
              children: [
                for (var spec in business['skuName'])
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
            SizedBox(height: 4.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${business['salesPrice']}', style: TextStyle(fontSize: 12.sp, color: Colors.black)),
                SizedBox(width: 8.w,),
                Text('积分 ${business['pointPrice']}', style: TextStyle(fontSize: 12.sp, color: HexColor('#CA9C72'))),
              ],
            )
          ],
        ),
        Spacer(),
        Padding(padding: EdgeInsets.all(0.w), child:Text('x${business['quantity']}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')))),
        // SizedBox(width: 16.w,),
      ],
    );
  }

  //支付方式
  Widget _buildPayInfo(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // SizedBox(width: 16.w,),
              Text('支付方式', style: TextStyle(fontSize: 15.sp, color: Colors.black,fontWeight: FontWeight.bold)),
              Spacer(),
              Text('我的积分: ${points['point'] ?? 0}', style: TextStyle(fontSize: 12.sp, color: HexColor('#CA9C72'))),
            ],
          ),
          SizedBox(height: 8.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isUseCash = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isUseCash == true ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    '¥ ${_calculateTotalPrice()}',
                    style: TextStyle(
                      color: isUseCash == true ? Colors.white : HexColor('#999999'),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w), // 间距
              GestureDetector(
                onTap: () {
                  setState(() {
                    isUseCash = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isUseCash == true ? Colors.white : Colors.black,  
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    '积分${points['usedPoint']}+¥${points['payAmount']}',
                    style: TextStyle(
                      height: 1.0, // 统一行高
                      color: isUseCash == true ? HexColor('#999999') : Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 16.h,),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = PaymentMethod.alipay;
              });
            },
            child: Row(
              children: [
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
                  size: 18.sp,
                ),

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
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 //获取数据
  Future <void> _getAddressListData() async {
     try{
       final apiManager = ApiManager();
       final response = await apiManager.get(
        '/api/shopping/address/list',
        queryParameters: null,
        );
        if (mounted && response != null)
        {
          setState(() {
            final addrssList = List<Map<String, dynamic>>.from(response);
            if (addrssList.isNotEmpty) {
              address = addrssList[0];
            }

          });
        }
       
     }catch(e){
       print(e);
     }
  }

  Future<void>_getPoints() async {
    try{
      final apiManager = ApiManager();
      List<Map<String, dynamic>> params = [];
      for (var item in widget.businessList) {
        params.add({'commodityPropertyId': item['commodityPropertyId'], "commodityNum":item['quantity'],"commodityId":item['commodityId']});
      }
      final response = await apiManager.postWithList(
        '/api/shopping/commodity/points',
        data: params,
      );
      if (mounted && response != null) {
        setState(() {
          points = Map<String,dynamic>.from(response);
        });
      }
    }catch(e){
      print(e);
    }
  }

  Future<void> _submitOrder() async {
    try{
      final apiManager = ApiManager();
      List<Map<String, dynamic>> arr = [];
      for (var item in widget.businessList) {
        Map<String, dynamic> map = {
          "commodityPropertyId": item['commodityPropertyId'],
          "commodityNum": item['quantity'],
          "commodityId": item['commodityId'],
          
        };
        arr.add(map);
      }
      //是否使用积分（0：不使用，1：使用）
      Map<String, dynamic> param = {"commodityShopAddressId":address['id'],
                                    "isUsePoints":isUseCash == true ? "0" : "1",
                                    "customerCommodityShopOrderToBuyReqVos":arr,
                                    "payType":_selectedMethod == PaymentMethod.alipay ? 2 : 1,
                                    "cartId": widget.businessList[0]['cartId'],
                                    };
      final response = await apiManager.post(
        '/api/shopping/commodity/commit/order',
        data: param,
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) =>ShopingPayPageWidget(orderNumber: response['orderNumber'],)));

    }catch(e){
      print(e);
    }
  }
}