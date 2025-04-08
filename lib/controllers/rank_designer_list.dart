import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/designer_home.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RankDesigherListWidget extends StatefulWidget {
  const RankDesigherListWidget({super.key});

  @override
  State<RankDesigherListWidget> createState() => _RankDesigherListWidgetState();
}

class _RankDesigherListWidgetState extends State<RankDesigherListWidget> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> _designerList = [];

  @override
  void initState() {
    super.initState();
    _getDesignerList();
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
    return _designerList.isEmpty ? 
      EmptyStateWidget(
        onRefresh: _onRefresh,
        emptyText: '暂无数据',
        buttonText: '点击刷新',
      ) 
    : ListView.builder(
      itemCount: _designerList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            //跳转到设计师详情页
            Map<String, dynamic> designer = _designerList[index];
            Navigator.push(context, MaterialPageRoute(builder: (context) => DesignerHomeWidget(userId: designer['userId'])));
          },
          child: _buildListCell(_designerList[index]),
        );
      },
    );
  }
 
  //单元格 cell
  Widget _buildListCell(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      // height: 220.h,
      color: HexColor('#FBF7F2'),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
               Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, left: 16.w),
                    child: ClipOval(
                      child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['avatar']?.toString() ?? "",width: 44.w,height: 44.w,fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, left: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['realName'] ?? "",style: TextStyle(color: Colors.black,fontSize: 16.sp, fontWeight: FontWeight.bold),),
                        SizedBox(height: 4.h,),
                        Text('从业${item['workingYears']}年 ｜ 案例${item['caseNumber']}套',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
                        SizedBox(height: 8.h,),
                        Wrap(
                          spacing: 4.w,
                          runSpacing: 4.h,
                          children: List.generate(
                          (item['excelStyle'] as List<dynamic>?)?.length ?? 0, 
                          (index) {
                            final styles = item['excelStyle'] as List<dynamic>? ?? [];
                            return Container(
                              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(  // 添加边框
                                  color: HexColor('#D0AF84'),  // 边框颜色
                                  width: 1.0,  // 边框宽度
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                styles[index],
                                style: TextStyle(
                                  color: HexColor('#D0AF84'),
                                  fontSize: 10.sp
                                ),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              if (item['caseMainPic'] != null && (item['caseMainPic'] as List).isNotEmpty) 
                Container(
                  margin: EdgeInsets.only(top: 12.h,bottom: 12.h),
                  height: 100.h,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 16.w,right: 12.w),
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
                )
              else
                SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
    
  }

  void _onRefresh() async {
    pageNum = 1;
   _designerList.clear();
    await _getDesignerList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await _getDesignerList();
    if (_designerList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //获取设计师列表
  Future<void> _getDesignerList() async {
    try{
      final apiManager = ApiManager();
      final response =  await apiManager.get(
        '/api/designer/list',
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
            _designerList.addAll(arr);
          });
        }

      }
    }
    catch(e) {
      print(e);
    }
  }
}