import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RankCaseListWidget extends StatefulWidget {
  const RankCaseListWidget({super.key});

  @override
  State<RankCaseListWidget> createState() => _RankCaseListWidgetState();
}

class _RankCaseListWidgetState extends State<RankCaseListWidget> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> _caseList = [];
  
  @override
  void initState() {
    super.initState();
    _getCaseList();
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
        child: _buildListView(),

      ),
    );
  }


   Widget _buildListView(){
    return _caseList.isEmpty ? 
      EmptyStateWidget(
        onRefresh: _onRefresh,
        emptyText: '暂无数据',
        buttonText: '点击刷新',
      ) 
    : ListView.builder(
      itemCount: _caseList.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListCell(_caseList[index]);
      },
    );
  }

  
  Widget _buildListCell(Map<String, dynamic> item) {
    return Container(
      color: HexColor('#FBF7F2'),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                 padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                 child: Text(
                   item['caseTitle'],
                   style: TextStyle(
                     fontSize: 15.sp,
                     color: Colors.black,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
               Padding(
                 padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                 child: Text(
                   item['caseIntro'],
                   style: TextStyle(
                     fontSize: 13.sp,
                     color: HexColor('#666666'),
                   ),
                 ),
               ),
              if (item['caseMainPic'] != null && (item['caseMainPic'] as List).isNotEmpty) 
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  height: 100.h,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 12.w,right: 12.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: (item['caseMainPic'] as List).length,
                    itemBuilder: (context, index) {
                      final List<dynamic> images = item['caseMainPic'];
                      return Container(
                        margin: EdgeInsets.only(left: 8.w),
                        width: 120.w,
                        height: 90.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: NetworkImageHelper().getCachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
               ),
              Padding(
                padding: EdgeInsets.only(left:16.w,top: 12.h,bottom: 12.h),
                child: Text(
                  item['createTime'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HexColor('#999999'),
                  ),
                ),
              )
            ],
          ),
        ),

      ),

    );

  }


  void _onRefresh() async {
    pageNum = 1;
   _caseList.clear();
    await _getCaseList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await _getCaseList();
    if (_caseList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //获取设计师列表
  Future<void> _getCaseList() async {
    try{
      final apiManager = ApiManager();
      final response =  await apiManager.get(
        '/api/cases/list',
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
        if(mounted) {
          setState(() {
            _caseList.addAll(arr);
          });
        }

      }
    }
    catch(e) {
      print(e);
    }
  }
}