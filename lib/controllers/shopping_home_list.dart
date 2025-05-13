import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/components/scrollable_productList.dart';
import 'package:flutter_smarthome/components/product-grid.dart';
import 'package:flutter_smarthome/controllers/activity_detail.dart';
import 'package:flutter_smarthome/controllers/article_detail.dart';
import 'package:flutter_smarthome/controllers/shopping_detail.dart';
import 'package:flutter_smarthome/models/product_item.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/network_state_helper.dart';
import 'package:flutter_smarthome/utils/video_page.dart';
import 'package:oktoast/oktoast.dart';
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
  List<Map<String,dynamic>> _bannerList = []; // Banner 图片地址
    // 添加标志位
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _getBanner();
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
                  products: recommendProducts,
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
                  child: Image.asset('assets/images/icon_shopping_placeholder.png',fit: BoxFit.cover,),
                  
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

  // 构建轮播图
  Widget _buildBanner() {
    if (_bannerList.isEmpty) {
      //显示正在加载中
      return Container();
    }
    return SizedBox(
      height: 250.h,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final item  = _bannerList[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // 设置圆角
            child: NetworkImageHelper().getCachedNetworkImage(
              imageUrl: item['imgUrl'] ?? "",
              fit: BoxFit.cover,
            ),
          );
        },
        autoplay: true,
        itemCount: _bannerList.length,
        viewportFraction: 0.8,
        scale: 0.9,
        onIndexChanged: (index) {
        
        },
        onTap: (index){
          final item = _bannerList[index];
          switch (item['resourceType'].toString()) {
            case '1': //视频
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPage(videoId: item['resourceId'] ?? "")));
              break;
            case '2': //资讯
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailWidget(title: "", articleId: item['resourceId'] ?? "")));
              break;
            case '3': //活动
               Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetailWidget(title: "", activityId: item['resourceId'] ?? "")));
              break;
            default:
          }
        },

      ),
    );
  }

  // 1. _onRefresh 改成 Future<void>
  Future<void> _onRefresh() async {
    pageNum = 1;
    products.clear();
    recommendProducts.clear();
    await Future.wait([ _getBanner(), getHomeData() ]);
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
   //获取首页Banner
  Future<void>_getBanner() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get('/api/shopping/banner',queryParameters: {'firstCategoryId':widget.categoryId});
      if(response != null){
        if(response.isNotEmpty){
          setState(() {
            _bannerList = List<Map<String,dynamic>>.from(response);
          });
        }
      }
    }catch(e){
      print('获取Banner数据错误: $e');
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取Banner数据失败，请稍后重试')),
        );
      }
    }
  }

  //商城首页
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
              imageUrl: item['mainPic'] ?? '',  // 添加默认空字符串
              title: item['name'] ?? '',
              shop: item['businessName'] ?? "",
              price: double.tryParse(item['minPrice']?.toString() ?? '0') ?? 0.0,  // 确保转换为 double，如果 null 返回 0.0
              points: item['minPointPrice']?.toString() ?? '0', 
              shopIcon: item['businessLogo'] ?? "",
          );
          recommendProducts.add(productItem);  // 将创建的商品添加到列表中
        }
        for (var item in productsData) {
          ProductItem productItem = ProductItem(
              id: item['id'],
              imageUrl: item['mainPic'] ?? "",  // 添加默认空字符串
              title: item['name'] ?? "",
              shop: item['businessName'] ?? "",
              price: double.tryParse(item['minPrice']?.toString() ?? '0') ?? 0.0,  // 确保转换为 double，如果 null 返回 0.0
              points: item['minPointPrice']?.toString() ?? '0',  
              shopIcon: item['businessLogo'] ?? "",
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

