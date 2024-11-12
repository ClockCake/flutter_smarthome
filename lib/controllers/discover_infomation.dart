import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/article_detail.dart';
import 'package:flutter_smarthome/controllers/rank_segement_home.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DiscoverInformationWidget extends StatefulWidget {
  const DiscoverInformationWidget({super.key});

  @override
  State<DiscoverInformationWidget> createState() => _DiscoverInformationWidgetState();
}

class _DiscoverInformationWidgetState extends State<DiscoverInformationWidget> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> _hotInformationList = [];

  @override
  void initState() {
    super.initState();
    _getHotInformationList();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                _buildRankWidget(),
                SizedBox(height: 32.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    '热门资讯',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _hotInformationList.isNotEmpty
                  ? Column(
                      children: List.generate(_hotInformationList.length, (index) {
                        final item = _hotInformationList[index];
                        return GestureDetector(
                          onTap: () {
                              Map<String, dynamic> item = _hotInformationList[index];
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailWidget(title: item['resourceTitle'],articleId: item['id'],)));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 16.w,),
                                Container(
                                  width: 120.w,
                                  height: 90.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: NetworkImageHelper().getNetworkImage(
                                    imageUrl: item['mainPic'] ?? '',
                                    width: 120.w,
                                    height: 90.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 12.w),
                                    child: Text(
                                      item['resourceTitle'] ?? '暂无标题',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )
                  :EmptyStateWidget(
                    onRefresh: _onRefresh,
                    emptyText: '暂无数据',
                    buttonText: '点击刷新',
                  ) 
              ],
            ),
          ),
        ),
      ),
    );
  }

  //顶部图片
  Widget _buildRankWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RankSegmentHomeWidget()));
      },
      child: Container(
      margin: EdgeInsets.all(16.w),
      width: double.infinity,
      height: 80.h,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/icon_rank_header.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w),
            child: Text(
              '装修排行榜',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 16.w),
            child: Text(
              '真实案例 · 全案设计 · 1对1服务',
              style: TextStyle(
                fontSize: 12.sp,
                color: HexColor('#999999')
              ),
            ),
          ),
        ],
       )
      ),
    );
  }

  void _onRefresh() async {
    pageNum = 1;
    _hotInformationList.clear();
    await _getHotInformationList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await _getHotInformationList();
    if (_hotInformationList.isEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  // 获取热门资讯列表
  Future<void> _getHotInformationList() async {
    try{
      final apiManager = ApiManager();
      final response =  await apiManager.get(
        '/api/article/hot/list',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      if (response['rows'].isNotEmpty) {
        final arr = List<Map<String, dynamic>>.from(response['rows']);
        setState(() {
          _hotInformationList.addAll(arr);
        });
      }
    }
    catch(e) {
      print(e);
    }
  }
}