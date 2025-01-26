import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/case_detail.dart';
import 'package:flutter_smarthome/controllers/designer_home.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/controllers/shopping_business.dart';
import 'package:flutter_smarthome/controllers/shopping_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchGridPageWidget extends StatefulWidget {
  final List<dynamic> searchTypes; // 搜索类型
  final String searchValue; // 搜索关键字
  const SearchGridPageWidget({
    super.key,
    required this.searchTypes,
    required this.searchValue,
  });

  @override
  State<SearchGridPageWidget> createState() => _SearchGridPageWidgetState();
}

class _SearchGridPageWidgetState extends State<SearchGridPageWidget> {
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> dataList = []; //数据源
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }
  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
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
          child: dataList.isEmpty
            ? EmptyStateWidget(onRefresh: _onRefresh)
            : _buildAllTypes(),
       ),
      )
      
    );
  }

  //构建整体结构
  Widget _buildAllTypes() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: widget.searchTypes.first == 6 ? 
      ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final item = dataList[index];
          return GestureDetector(
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBusinessWidget(businessId: item['businessId'],businessLogo: item['businessLogo'],businessName: item['businessName'],)));
               },
               child: _buildBusinessInfo(item),
             );
        },
        itemCount: dataList.length,
      )
      :GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          final item = dataList[index];
          switch (widget.searchTypes.first) {
            case 1: //设计师
              return GestureDetector(
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DesignerHomeWidget(userId: item['userId'],)));
                },
                child: _buildDesigner(item),
              );
            case 2: //案例
              return GestureDetector(
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailWidget(title: item['caseTitle'], caseId: item['id'],)));
                },
                child: _buildCaseCell(item),
              );
            case 3: //商品
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingDetailPageWidget(commodityId: item['id"'])));
                },
                child: _buildBusinessItem(item),
              );
            case 4: //产品
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const QuoteNumberPage(renovationType: RenovationType.fullRenovation,)));
                },
                child: _buildPackages(item),
              );
             
            default:
              return Placeholder();
          }
        },
        itemCount: dataList.length,
      ),
    );
  }
 
  //构建店铺
  Widget _buildBusinessInfo(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: HexColor('#FFF7F0'),

        ),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Row(
              children: [
                SizedBox(width: 16.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['businessLogo'] ?? "",width: 20.w,height: 20.w),
                ),
                SizedBox(width: 10.w),
                Text(item['businessName'] ?? "",style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold, color: HexColor('#2A2A2A')),),
                Spacer(),
                Container(
                  padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // 设置透明背景色
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(color: HexColor('#999999'), width: 0.5),
                  ),
                  child: Text('进店',style: TextStyle(fontSize: 13.sp,color: HexColor('#2A2A2A')),),
                ),
                SizedBox(width: 16.w),
              ],
            ),
            // Padding(
            //   padding: EdgeInsets.all(16.w),
            //   child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['bgUrl'] ?? ""),
            // )
          ],
        ),
      ),
    );
  }

  //构建产品
  Widget _buildPackages(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['packagePic'] ?? ""),
         ),
         SizedBox(height: 5.h),
         Text(item['packageName'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '100㎡仅需 ',
                style: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: item['basePrice'].toString(),
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' 元起',
                style: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
         ),
         SizedBox(height: 5.h,)
      ],
    );
  }
//构建商品
Widget _buildBusinessItem(Map<String,dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: NetworkImageHelper().getCachedNetworkImage(
          imageUrl: item['picUrls'],
          width: double.infinity,
          height: 100.h, // 确保图片高度适中
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 5.h),
      Text(
        item['name'],
        style: TextStyle(fontSize: 13.sp, color: Colors.black),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 5.h),
      Row(
        children: [
          Container(
            width: 16,
            height: 16,
            child: NetworkImageHelper().getNetworkImage(
              imageUrl: item['businessLogo'] ?? "https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png",
              width: 14.w,
              height: 14.w,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "${item['businessName'] ?? ""}",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Text(
            '¥${item['salesPrice'] ?? "0"}',
            style: TextStyle(
              fontSize: 16.sp,
              color: HexColor('#222222'),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            '积分 ${item['pointPrice'] ?? "0"}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ],
  );
}

  //构建设计师
  Widget _buildDesigner(Map<String,dynamic> item){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item['designerAvatar'] ?? "",
            width: double.infinity,
            height: 100.h, // 确保图片高度适中
            fit: BoxFit.cover,
          ),
        ),
         SizedBox(height: 5.h),
         Text(item['realName'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         Text('${item['excelStyle']} | 案例作品 ${item['caseCount']}套',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
         SizedBox(height: 5.h,)
         
       ],
    );
  }

  //构建案例
  Widget _buildCaseCell(Map<String,dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item['caseMainPic'] ?? "https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png",
            width: double.infinity,
            height: 100.h, // 确保图片高度适中
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 5.h,),
        Text('${item['householdType']} · ${item['designStyle']}',style:TextStyle(color: HexColor('#CA9C72'),fontSize: 12.sp),maxLines: 1,overflow: TextOverflow.ellipsis,),
        SizedBox(height: 3.h,),
        Text('${item['caseTitle']}',style:TextStyle(color: Colors.black,fontSize: 13.sp),maxLines: 1,overflow: TextOverflow.ellipsis,),
        SizedBox(height: 3.h,),
         Row(
           children: [
             ClipOval(
               child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['avatar'] ?? "https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png", width: 16.w, height: 16.w),
             ),
             SizedBox(width: 5.w,),
             Text('${item['realName'] ?? ""}',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
           ],
         )

       ],
    );
  }
  Future<void> _getSearchResults() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/search',
         queryParameters: {
          'searchValue': widget.searchValue,
          'searchTypes': widget.searchTypes,
          'pageNum': pageNum,
          'pageSize': pageSize,
         }
      );
      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      if (response.isNotEmpty) {
        final arr = List<Map<String, dynamic>>.from(response['rows']);
        if(mounted) {
          setState(() {
             dataList.addAll(arr);
          });
        }

      }
    } catch (e) {
      print(e);
    }
  }

  void _onRefresh() async {
    pageNum = 1;
    dataList.clear();
    try {
      // 执行数据刷新操作
      await _getSearchResults(); // 或其他数据加载方法
      _refreshController.refreshCompleted(); // 完成刷新
    } catch (e) {
      _refreshController.refreshFailed(); // 刷新失败
    }

  }

  void _onLoading() async {
    pageNum++;
    await _getSearchResults();
    if (dataList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

 
  
}