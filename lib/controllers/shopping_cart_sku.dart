import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/shopping_car_list.dart';
import 'package:flutter_smarthome/controllers/shopping_order.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/shopping_cart_count.dart';
import 'package:oktoast/oktoast.dart';

class ShoppingCartSkuPopupWidget extends StatefulWidget {
  final int type; // 1: 加入购物车, 2: 立即购买
  final String commodityId; // 商品ID
  final String name; // 商品名称
  final Function()? onCartSuccess; // 添加回调参数

  const ShoppingCartSkuPopupWidget({
    required this.type,
    required this.commodityId,
    required this.name,
    this.onCartSuccess, // 新增参数
    super.key,
  });

  @override
  State<ShoppingCartSkuPopupWidget> createState() => _ShoppingCartSkuPopupWidgetState();
}

class _ShoppingCartSkuPopupWidgetState extends State<ShoppingCartSkuPopupWidget> {
  List<Map<String, dynamic>> skuList = []; // 返回属性数据
  int quantity = 1; // 购买数量

  Map<String, String> selectedOptions = {}; // 选中的属性，key: 属性名, value: 属性值
  Map<String, dynamic> selectedSkuInfo = {}; // 选中的 Sku
  List<String> selectedPropertyIds = []; // 选中的属性 ID
  List<String> selectedPropertyNames = []; // 选中的属性名称
  int maxQuantity = 99; // 最大购买数量

  @override
  void initState() {
    super.initState();
    _getSkuInfo();
    _getSkuStock();
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 获取 Sku 信息
  Future<void> _getSkuInfo() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/shopping/commodity/property',
        queryParameters: {
          'commodityId': widget.commodityId,
        },
      );
      if (mounted && response != null) {
        setState(() {
          skuList = List<Map<String, dynamic>>.from(response);
        });
        // 从 skuList 中获取默认选中的属性(第一个)
        Map<String, String> initialSelectedOptions = {};
        List<String> initialSelectedPropertyIds = [];
        for (var sku in skuList) {
          if (sku['childCommodityPropertyList'] != null &&
              (sku['childCommodityPropertyList'] as List).isNotEmpty) {
            initialSelectedOptions[sku['name']] =
                sku['childCommodityPropertyList'][0]['name'];
            initialSelectedPropertyIds.add(sku['childCommodityPropertyList'][0]['id']);
          }
        }
        setState(() {
          selectedOptions = initialSelectedOptions;
          selectedPropertyIds = initialSelectedPropertyIds;
        });
        _getSkuStock(); // Fetch stock after setting default selections
      }
    } catch (e) {
      print('Error fetching SKU info: $e');
    }
  }

  // 动态查询商品 Sku 库存
  Future<void> _getSkuStock() async {
    try {
      final apiManager = ApiManager();
      final selectedPropertyStr = selectedPropertyIds.join(',');
      final response = await apiManager.get(
        '/api/shopping/commodity/skuGroup',
        queryParameters: {
          'commodityId': widget.commodityId,
          "commodityPropertyId": selectedPropertyStr,
        },
      );
      if (mounted && response != null) {
        setState(() {
          selectedSkuInfo = Map<String, dynamic>.from(response);
          if (selectedSkuInfo['isShelves'] == false) {
            maxQuantity = 0;
            showToast('商品已下架');
          }else{
            maxQuantity = selectedSkuInfo['inventory'] ?? 0;
            if (maxQuantity == 0) {
              showToast('商品库存不足');
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching SKU stock: $e');
    }
  }

  // 更新选中的 Sku 信息
  void _updateSelectedSkuInfo(int index, String propertyId, String skuName, String propertyValue) {
    setState(() {
      selectedPropertyIds[index] = propertyId;
      selectedOptions[skuName] = propertyValue;
    });
    // 更新完后重新请求 SKU 接口
    _getSkuStock();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      // 背景为灰色 + 透明度
      backgroundColor: Colors.black.withOpacity(0.3),
      // 使用 Align 将 Container 放在底部
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating to the background
            child: Container(
              // 使用安全区域和圆角
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部关闭按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    // 商品图片+价格+积分
                    Row(
                      children: [
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: NetworkImageHelper().getCachedNetworkImage(
                              imageUrl: selectedSkuInfo['mainPic'] ?? ""),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¥ ${selectedSkuInfo['salesPrice'] ?? '0.00'}',
                                style: TextStyle(
                                    fontSize: 20.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: HexColor('#CA9C72')),
                                ),
                                child: Text(
                                  '积分 ${selectedSkuInfo['pointPrice'] ?? '0'}',
                                  style: TextStyle(
                                      color: HexColor('#CA9C72'),
                                      fontSize: 12.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(skuList.length, (index) {
                        var sku = skuList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sku['name'],
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: List.generate(
                                (sku['childCommodityPropertyList'] as List<dynamic>).length,
                                (childIndex) {
                                  var child = sku['childCommodityPropertyList'][childIndex];
                                  String value = child['name'];
                                  bool selected =
                                      selectedOptions[sku['name']] == value;
                                  return InkWell(
                                    onTap: () {
                                      _updateSelectedSkuInfo(index, child['id'], sku['name'], child['name']);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: selected
                                                ? Colors.black
                                                : Colors.grey),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            color: selected
                                                ? Colors.black
                                                : Colors.grey),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }),
                    ),
                    // 购买数量
                    Text('购买数量',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    ShoppingCartItem(
                      maxQuantity: maxQuantity,
                      onQuantityChanged: (value) {
                        setState(() {
                          quantity = value;
                        });
                      },
                      initialQuantity: quantity,
                    ),
                    SizedBox(height: 16.h),
                    // 加入购物车按钮
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (selectedSkuInfo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('请选择有效的商品属性'),
                              ),
                            );
                            return;
                          }
                          if (maxQuantity == 0) {
                            showToast('商品已下架 或库存不足');
                            return;
                          }
                          if (widget.type == 1) { // 加入购物车
                            _joinShoppingCart();
                          }else{ // 立即购买
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              Map<String, dynamic> business = {
                                'commodityId': widget.commodityId,
                                'commodityPropertyId': selectedPropertyIds.join(','),
                                'mainPic':selectedSkuInfo['mainPic'],
                                'salesPrice':selectedSkuInfo['salesPrice'],
                                'pointPrice':selectedSkuInfo['pointPrice'],
                                'name':widget.name,
                                'quantity': quantity,
                                'skuName':selectedOptions.values,
                              };
                              return ShoppingOrderWidget(businessList: [business]);
                            }));
                          }

                        },
                        child: Text(widget.type == 1 ? '加入购物车' : '立即购买',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp)),
                      ),
                    ),
                    SizedBox(height:  20.h ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

 // 加入购物车
  Future<void>_joinShoppingCart() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/shopping/commodity/join/cart',
        data: {
          'commodityId': widget.commodityId,
          'commodityPropertyId': selectedPropertyIds.join(','),
          'count': quantity,
        },
      );
      if (response != null) {
         showToast('加入购物车成功');
        if (widget.onCartSuccess != null) {
          widget.onCartSuccess!();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('Error joining shopping cart: $e');
    }
  }
}
