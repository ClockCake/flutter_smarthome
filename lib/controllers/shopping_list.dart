import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_smarthome/components/product-grid.dart';
import 'package:flutter_smarthome/models/product_item.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShoppingListWidget extends StatefulWidget {
  final String firstCategoryId;
  final String secondCategoryId;
  final String categoryName;
  const ShoppingListWidget({
    super.key,
    required this.firstCategoryId,
    required this.secondCategoryId,
    required this.categoryName
  });

  @override
  State<ShoppingListWidget> createState() => _ShoppingListWidgetState();
}

class _ShoppingListWidgetState extends State<ShoppingListWidget> {

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  final List<ProductItem> products = [];

  @override
  void initState() {
    super.initState();
    getBusinessList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.categoryName, 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SmartRefresher(
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
        child: products.isEmpty ? 
          EmptyStateWidget(
            onRefresh: _onRefresh,
            emptyText: '暂无数据',
            buttonText: '点击刷新',
          ) : 
          ProductGrid(
          products: products,
          crossAxisCount: 2,
          childAspectRatio: 0.72,
        ), 

      ),
    );
  }

  
  void _onRefresh() async {
    pageNum = 1;
    products.clear();
    await getBusinessList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await getBusinessList();
    if (products.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  Future<void>getBusinessList() async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/shopping/commodity/list',
        queryParameters: {
          'searchFirstCategoryId': widget.firstCategoryId,
          'searchSecondCategoryId': widget.secondCategoryId,
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      if (response['rows'] !=null && response['rows'].isNotEmpty) {
        final List<dynamic> productsData = response['rows'] as List<dynamic>;

      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      setState(() {

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