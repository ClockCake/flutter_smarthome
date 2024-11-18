import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/components/scrollable_productList.dart';
import 'package:flutter_smarthome/components/product-grid.dart';
import 'package:flutter_smarthome/models/product_item.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShoppingHomeListWidget extends StatefulWidget {
  final String categoryId;
  const ShoppingHomeListWidget({
    super.key,
    required this.categoryId
  });

  @override
  State<ShoppingHomeListWidget> createState() => _ShoppingHomeListWidgetState();
}

class _ShoppingHomeListWidgetState extends State<ShoppingHomeListWidget> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final List<ProductItem> recommendProducts = [];
  final List<ProductItem> products = [];
  int pageNum = 1;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    getHomeData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          child: ListView(
            children: [
              SizedBox(height: 16.h,),
              _buildBanner(),
              SizedBox(height: 16.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '推荐',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: ScrollableProductList(
                  products: products,
                  itemWidth: 140,
                  itemHeight: 220,
                  spacing: 12,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              SizedBox(height: 16.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  height: 80.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: NetworkImageHelper().getCachedNetworkImage(
                    imageUrl: 'https://image.iweekly.top/i/2024/07/26/66a30d068028b.jpg',
                      fit: BoxFit.fill
                    ),
                  )
                  
                )
              ),
              SizedBox(height: 16.h,),
              ProductGrid(
                products: products,
                crossAxisCount: 2,
                childAspectRatio: 0.72,
              ), // 底部添加一些间距
            ],
          ),
        )
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 250,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              'assets/images/banner.png',
              fit: BoxFit.fill,
            ),
          );
        },
        autoplay: true,
        itemCount: 10,
        viewportFraction: 0.8,
        scale: 0.9,
      ),
    );
  }


  void _onRefresh() async {
    pageNum = 1;
    products.clear();
    recommendProducts.clear();
    await getHomeData();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await getHomeData();
    if (products.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //网络请求
  Future<void>getHomeData() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/shopping/home',
        queryParameters: {
          'categoryId': widget.categoryId,
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      if (response != null) {
        final recommendProductsData = response['recommendProducations'];
        final productsData = response['producations'];

      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      setState(() {
        for (var item in recommendProductsData) {
          ProductItem productItem = ProductItem(
              id: item['id'],
              imageUrl: item['mainPic'].isNotEmpty ? item['mainPic'][0] : '',  // 添加默认空字符串
              title: item['name'],
              shop: item['businessName'],
              price: double.parse(item['minPrice'].toString()),  // 确保转换为 double
              points: item['minPointPrice'].toString(),  // 转换为字符串
              shopIcon: item['businessLogo'],
          );
          recommendProducts.add(productItem);  // 将创建的商品添加到列表中
        }
        for (var item in productsData) {
          ProductItem productItem = ProductItem(
              id: item['id'],
              imageUrl: item['mainPic'] ?? "",  // 添加默认空字符串
              title: item['name'],
              shop: item['businessName'],
              price: double.parse(item['minPrice'].toString()),  // 确保转换为 double
              points: item['minPointPrice'].toString(),  // 转换为字符串
              shopIcon: item['businessLogo'],
          );
          products.add(productItem);  // 将创建的商品添加到列表中
        }
      });
     }
    }catch(e){
      print(e);
    }
  }
}

