import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/case_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DesignerMomentsListWidget extends StatefulWidget {
  final String userId;
  const DesignerMomentsListWidget({
    super.key,
    required this.userId,
  });
  @override
  State<DesignerMomentsListWidget> createState() => _DesignerMomentsListWidgetState();
}

class _DesignerMomentsListWidgetState extends State<DesignerMomentsListWidget> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> _designerMomentsList = [];

    @override
    void initState() {
      super.initState();
    _getMomentsList();
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
      return _designerMomentsList.isEmpty ? 
        EmptyStateWidget(
          onRefresh: _onRefresh,
          emptyText: '暂无数据',
          buttonText: '点击刷新',
        ) 
      : ListView.builder(
        itemCount: _designerMomentsList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CaseDetailWidget(
                      title: _designerMomentsList[index]['caseTitle'],
                      caseId: _designerMomentsList[index]['id'],
                    ),
                  ),
                );
            },
            child: _buildListCell(_designerMomentsList[index]),
          );
        },
      );
    }

    Widget _buildListCell(Map<String, dynamic> moment) {
      return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
              child: Text(
                moment['dynamicTitle'],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: HexColor('#222222'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
              child: Text(
                moment['dynamicInfo'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: HexColor('#666666'),
                ),
              ),
            ),
            if (moment['dynamicPic'] != null && (moment['dynamicPic'] as List).isNotEmpty) 
              Container(
                margin: EdgeInsets.only(top: 12.h,bottom: 12.h),
                height: 100.h,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 16.w,right: 12.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: (moment['dynamicPic'] as List).length,
                  itemBuilder: (context, index) {
                    final List<dynamic> images = moment['dynamicPic'];
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
              padding: EdgeInsets.only(left: 12.w, right: 12.w,top: 12.h),
              child:Text(
                moment['createTime'],
                style: TextStyle(
                  fontSize: 11.sp,
                  color: HexColor('#999999'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w,top: 12.h),
              child: Divider(
                height: 1.h,
                color: Colors.grey[300],
              ),
            ),
      
          ],
      );
    
    }

    void _onRefresh() async {
    pageNum = 1;
   _designerMomentsList.clear();
    await _getMomentsList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await _getMomentsList();
    if (_designerMomentsList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //获取设计师列表
  Future<void> _getMomentsList() async {
    try{
      final apiManager = ApiManager();
      final response =  await apiManager.get(
        '/api/designer/dynamic',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'userId': widget.userId,
        },
      );
      if (response['pageTotal'] == pageNum || response['pageTotal'] == 0) {
        _refreshController.loadNoData();
      }
      if (response['rows'].isNotEmpty) {
        final arr = List<Map<String, dynamic>>.from(response['rows']);
        if(mounted) {
          setState(() {
            _designerMomentsList.addAll(arr);
          });
        }

      }
    }
    catch(e) {
      print(e);
    }
  }
}