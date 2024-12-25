import 'dart:ffi';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:flutter_smarthome/controllers/shopping_car_list.dart';
import 'package:flutter_smarthome/controllers/shopping_cart_sku.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';
import 'package:oktoast/oktoast.dart';

class ShoppingDetailPageWidget extends StatefulWidget {
  final String commodityId;

  ShoppingDetailPageWidget({Key? key, required this.commodityId}) : super(key: key);


  @override
  State<ShoppingDetailPageWidget> createState() => _ShoppingDetailPageWidgetState();
}

class _ShoppingDetailPageWidgetState extends State<ShoppingDetailPageWidget> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;
  Map<String, dynamic> _shoppingDetail = {};
  List<String> imageList = []; //Banner数组
  late bool isLogin; // 是否登录


  @override
  void initState() {
    super.initState();
    isLogin = UserManager.instance.isLoggedIn;

    _getShoppingDetail();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    setState(() {
      _opacity = opacity;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(_opacity),
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white,
        ),
        title: Text(
          '',
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 250.h + MediaQuery.of(context).padding.top,
              child: _buildBanner(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h,),
                  Row(
                    children: [
                        SizedBox(width: 16.w,),
                        Text('¥ ${_shoppingDetail['minPrice']}',style: TextStyle(color: HexColor('#222222'),fontSize: 16.sp,fontWeight: FontWeight.bold),),
                        SizedBox(width: 8.w,),
                        Text('积分 ${_shoppingDetail['minPointPrice']}',style: TextStyle(color: HexColor('#CA9C72'),fontSize: 12.sp),),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
                    child: Text(_shoppingDetail['name'] ?? "",style: TextStyle(color: HexColor('#222222'),fontSize: 16.sp),),
                  ),
                  
                  SizedBox(height: 12.h,),
                  Row(
                    children: [
                      SizedBox(width: 16.w,),
                      NetworkImageHelper().getCachedNetworkImage(imageUrl: _shoppingDetail['businessLogo'] ?? "",width: 18.w,height: 18.h),
                      SizedBox(width: 4.w,),
                      Text(_shoppingDetail['businessName'] ?? "",style: TextStyle(color: HexColor('#222222'),fontSize: 12.sp),),
                    ],
                  ),
                  SizedBox(height: 12.h,),
                  Container(
                    width: double.infinity,
                    height: 8.h,
                    color: HexColor('#F8F8F8'),
                  ),
                  Container( //选择参数
                    width: double.infinity,
                    height: 52.h,
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {

                      },
                      child: Row(
                        children: [
                          SizedBox(width: 16.w,),
                          Text('参数', style: TextStyle(color: Colors.black, fontSize: 14.sp),),
                          Spacer(),
                          Text('选择参数 ', style: TextStyle(color: HexColor('#222222'), fontSize: 14.sp),),
                          Icon(Icons.arrow_forward_ios, size: 16.sp, color: HexColor('#999999')),
                          SizedBox(width: 16.w,),
                        ],
                      ),
                    )
                  ),
                  Container(
                    width: double.infinity,
                    height: 8.h,
                    color: HexColor('#F8F8F8'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
                    child: Text('商品详情',style: TextStyle(color: HexColor('#222222'),fontSize: 16.sp,fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                    child: Html(
                      data: _shoppingDetail['commodityInfo'] ?? "",
                    )
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

    // 构建轮播图
  Widget _buildBanner() {
    if (imageList.isEmpty) {
      //显示正在加载中
      return Container();
    }
    return SizedBox(
      height: 250.h,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final item  = imageList[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // 设置圆角
            child: NetworkImageHelper().getCachedNetworkImage(
              imageUrl: item,
              fit: BoxFit.cover,
            ),
          );
        },
        autoplay: true,
        itemCount: imageList.length,
        viewportFraction: 0.8,
        scale: 0.9,
        onIndexChanged: (index) {
        
        },
      

      ),
    );
  }
  
  //跳转方法
  void _jumpToPage(int index,BuildContext contexts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), 
      ),
      builder: (context) {
        if (!isLogin) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(contexts).padding.top, 
              bottom: MediaQuery.of(contexts).viewInsets.bottom,
            ),
            child: LoginPage(onLoginSuccess: () {
              setState(() {
                isLogin = true;
              });
            },),
          );
        } else {
          return ShoppingCartSkuPopupWidget(commodityId: widget.commodityId, type: index,name: _shoppingDetail['name'],  onCartSuccess: () {
            _getShoppingDetail();
          },);
        }
      },
    );
  }

  //底部按钮
  Widget _buildBottomNavigationBar(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 60.h + bottomPadding,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          GestureDetector( // 收藏
            onTap: () {
               if(isLogin == false){
                  showToast('请先登录');
                  return;
               }
                (_shoppingDetail['isCollection'] ?? "").isNotEmpty ? _cancelCollection() : _addCollection();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  (_shoppingDetail['isCollection'] ?? "").isNotEmpty 
                    ? 'assets/images/icon_shopping_star_selected.png'
                    : 'assets/images/icon_shopping_star.png',
                  width: 20.w, 
                  height: 20.h,
                ),                
                SizedBox(height: 4.h,),
                Text('${_shoppingDetail['userCollectionCount'] ?? 0}', style: TextStyle(color: HexColor('#222222'), fontSize: 11.sp),),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector( // 购物车
            onTap: () {
              if(isLogin == false){
                  showToast('请先登录');
                  return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCarListWidget()));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon_shopping_cart.png', width: 20.w, height: 20.h,),
                SizedBox(height: 4.h,),
                Text('${_shoppingDetail['userCartCount'] ?? 0}', style: TextStyle(color: HexColor('#222222'), fontSize: 11.sp),),
              ],
            ),
          ),
          Spacer(),
          GestureDetector( // 加入购物车
            onTap: () {
              _jumpToPage(1,context);
            },
            child: Container(
              height: 42.h,
              width: 120.w, // 根据需要调整宽度
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: HexColor('#222222'), width: 1),
              ),
              child: Center(
                child: Text('加入购物车', style: TextStyle(color: Colors.black, fontSize: 14.sp),),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector( // 立即购买
            onTap: () {
              _jumpToPage(2,context);
            },
            child: Container(
              height: 42.h,
              width: 120.w, // 根据需要调整宽度
              decoration: BoxDecoration(
                color: HexColor('#222222'),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('立即购买', style: TextStyle(color: Colors.white, fontSize: 14.sp),),
              ),
            ),
          ),
          SizedBox(width: 0.w),
        ],
      ),
    );
  }

  //获取网络请求
  Future<void> _getShoppingDetail() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/shopping/commodity/detail',
        queryParameters: {'id':widget.commodityId}
      );
      if(mounted && response != null) {
        // if(_shoppingDetail['id'] != null){
        //   _shoppingDetail['isCollection'] = response['isCollection'];
        //   return;
        // }
        setState(() {
          _shoppingDetail = Map.from(response);
          imageList = List<String>.from(_shoppingDetail['picUrls']);
        });
      }
    }
    catch(e){
      print(e);
    }
  }

  //添加收藏
  Future<void> _addCollection() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home//collection/add',
        data: {'businessId':_shoppingDetail['id'],"businessType":7}
      );
      if(mounted && response != null) {
        showToast('收藏成功');
         _getShoppingDetail();
      }
    }
    catch(e){
      print(e);
    }
  }

  //取消收藏
  Future<void> _cancelCollection() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.deleteWithParameters(
        '/api/home/collection/remove',
        data: {'id':_shoppingDetail['isCollection']}
      );
      if(mounted && response != null) {
        showToast('取消收藏成功');
        _getShoppingDetail();

      }
    }
    catch(e){
      print(e);
    }
  }
}