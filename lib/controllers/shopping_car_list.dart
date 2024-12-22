import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/shopping_order.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/shopping_cart_count.dart';

class ShoppingCarListWidget extends StatefulWidget {
  const ShoppingCarListWidget({super.key});

  @override
  State<ShoppingCarListWidget> createState() => _ShoppingCarListWidgetState();
}

class _ShoppingCarListWidgetState extends State<ShoppingCarListWidget> {
  int status= 0 ; // 0:正常状态 1:编辑状态
  //有效商品列表
  List<Map<String, dynamic>> _shoppingCartList = [];
  //失效商品列表
  List<Map<String, dynamic>> _invalidShoppingCartList = [];
  String _point = '0';
  @override
  void initState() {
    super.initState();
    _loadData();
    _getPoint();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              '购物车',
              style: TextStyle(color: Colors.black,fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.w),
            Text(
              '我的积分:${_point}',
              style: TextStyle(color: HexColor('#CA9072'),fontSize: 11.sp),
            ),
          ]
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print('点击了编辑');
            },
            child: Container(
              padding: EdgeInsets.only(right: 10.w),
              alignment: Alignment.center,
              child: Text(
                '管理',
                style: TextStyle(color: HexColor('#999999'),fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _shoppingCartList.length,
              itemBuilder: (context, index) {
                return _buildListCell(_shoppingCartList[index]);
              },
            ),
            SizedBox(height: 10.h),
            Padding(padding: EdgeInsets.only(left: 16.w),child: Text('失效商品 (${_invalidShoppingCartList.length})',style: TextStyle(color: Colors.black,fontSize: 15.sp,fontWeight: FontWeight.bold))),
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _invalidShoppingCartList.length,
              itemBuilder: (context, index) {
                return _buildListCell(_invalidShoppingCartList[index]);
              },
            ),
          ],
          
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(context),
    );
  }
 
 Widget _buildListCell(Map<String, dynamic> item) {
   return Container(
     height: 96.h,
     width: double.infinity,
     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
     color: Colors.white,
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        Container(
          width: 80.w,
          height: 80.h,
          clipBehavior: Clip.hardEdge, // 添加此行
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item['mainPic'] ?? "",
            width: 80.w,
            height: 80.h,
          ),
        ),
         SizedBox(width: 10.w),
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               item['name'] ?? "",
               style: TextStyle(color: Colors.black,fontSize: 14.sp),
             ),
             SizedBox(height: 4.h),
             //商品规格
            Wrap(
              spacing: 4.w,
              children: (item['commodityProperty']?.split(',') ?? []).map<Widget>((text) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: HexColor('#F8F8F8'),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 11.sp, color: HexColor('#999999')),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h,),
            Row( 
              children: [
                Text(
                  '￥${item['salesPrice']}',
                  style: TextStyle(color: Colors.black,fontSize: 12.sp,fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10.w),
                Text(
                  '积分 ${item['pointPrice']}',
                  style: TextStyle(color: HexColor('#CA9C72'),fontSize: 12.sp),
                ),
              ],
            )
           ],
         ),
        Spacer(),
        Column(
          children: [
            SizedBox(height: 50.h),
            ShoppingCartItem(
              initialQuantity: item['count'],
              onQuantityChanged: (value) {
                 _updateShoppingCartCount(value, item['id']);
                setState(() {
                  item['count'] = value;
                  
                });
              },
            ),
          ],
        )
      ],

     ),
   );
 }
  /// 构建底部导航栏
  Widget _buildNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 50.h + bottomPadding,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              SizedBox(width: 40.w,),
              Text(
                '合计:￥${_calculateTotalPrice()}',
                style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.w,),
              GestureDetector(
                onTap: () {
                  print('点击了立即下单');
                  List<Map<String, dynamic>> params = [];
                  for (var item in _shoppingCartList) {
                      Map<String, dynamic> business = {
                          'commodityId': item['commodityId'],
                          'commodityPropertyId': item['commodityPropertyId'],
                          'mainPic':item['mainPic'],
                          'salesPrice':item['salesPrice'],
                          'pointPrice':item['pointPrice'],
                          'name':item['name'],
                          'quantity': item['count'],
                          'skuName':item['commodityProperty']?.split(','),
                          "cartId":item['id'].join(','),
                        };
                      params.add(business);
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingOrderWidget(businessList: params)));

                },
                child: Container(
                  width: 135.w,
                  height: 42.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6.r),
                  ),  
                  child: Text('立即下单',style: TextStyle(color: Colors.white,fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 16.w),  
            ],
          ),
          SizedBox(height: 10.h),
        ],
      )
    );
  }

 //计算价格的方法
double _calculateTotalPrice() {
    double totalPrice = 0;
    for (var item in _shoppingCartList) {
      var price = item['salesPrice'];
      if (price != null) {
        // 处理不同类型的情况
        double priceValue = price is int ? price.toDouble() : 
                          price is String ? double.tryParse(price) ?? 0 : 0;
        totalPrice += priceValue * item['count'];
      }
    }
    return totalPrice;
  }
 //获取购物车列表
  Future<void> _loadData() async {
     try{
       final apiManager = ApiManager();
       final response = await apiManager.get(
         '/api/shopping/commodity/cart/list',
         queryParameters: null,
       );

       if(response != null){
          setState(() {
            for (var item in response) {
              if (item['commoditySkuStatus'] == "0") {
                _invalidShoppingCartList.add(item);
              } else if (item['commoditySkuStatus'] == "1") {
                _shoppingCartList.add(item);
              }
            }
          });
       }
     }catch(e){
       print(e);
     }
  }

  //购物车数量加减
  void _updateShoppingCartCount(int count, String cartId) async {
    try{
      final apiManager = ApiManager();
      final response = await apiManager.put(
        '/api/shopping/commodity/cart/update',
        data: {
          'id': cartId,
          'count': count,
        },
      );
      if(response != null){
        print('更新购物车数量成功');
      }
    }catch(e){
      print(e);
    }
  }

  //获取积分
  void _getPoint() async {
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/personal/integral',
        queryParameters: null,
      );
      if(response != null){
        setState(() {
          _point = response['point'] ?? '0';
        });
      }
    }catch(e){
      print(e);
    }
  }
}