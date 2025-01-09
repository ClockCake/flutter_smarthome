import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/case_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/string_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DesignerCaseGridWidget extends StatefulWidget {
  final String userId;
  const DesignerCaseGridWidget({
    super.key,
    required this.userId,
  });

  @override
  State<DesignerCaseGridWidget> createState() => _DesignerCaseGridWidgetState();
}

class _DesignerCaseGridWidgetState extends State<DesignerCaseGridWidget> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;
  List<Map<String, dynamic>> _designerCaseList = [];

  @override
  void initState() {
    super.initState();
    _getDesignerCaseList();
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
          child: _buildGridView(),

        ),
    );
  }


  Widget _buildGridView(){
    return _designerCaseList.isEmpty ? 
      EmptyStateWidget(
        onRefresh: _onRefresh,
        emptyText: '暂无数据',
        buttonText: '点击刷新',
      ) 
    : GridView.builder(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h), // 添加边距
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CaseDetailWidget(
                  title: _designerCaseList[index]['caseTitle'],
                  caseId: _designerCaseList[index]['id'],
                ),
              ),
            );
          },
          child: _buildGridCell(_designerCaseList[index]),
        );
      },
      itemCount: _designerCaseList.length,
    );
  }
  Widget _buildGridCell(Map<String, dynamic> item) {
    final imageUrls = item['caseMainPic'] as List<dynamic>? ?? ['https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png'];
    final result = '${item['excelStyle'] == null || (item['excelStyle'] as List).isEmpty ? "" : StringUtils.joinList(item['excelStyle'], separator: ' ')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            width: double.infinity, // 确保图片填充整个容器宽度
            color: Colors.white,
            child: NetworkImageHelper().getCachedNetworkImage(
              imageUrl: imageUrls.first,
              fit: BoxFit.cover, // 确保图片合适地填充容器
            )
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          result.length == 0 ? '${item['householdType'] ?? ""}' :'${item['householdType'] ?? ""} · ${result}',
          style: TextStyle(
            fontSize: 11.sp,
            color: HexColor('#CA9C72')
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${item['caseTitle'] ?? ""}',
          style: TextStyle(
            fontSize: 13.sp,
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold
          ),
          maxLines: 1,
        ),

      ],
    );
  }
  void _onRefresh() async {
    pageNum = 1;
   _designerCaseList.clear();
    await _getDesignerCaseList();
    _refreshController.refreshCompleted();

  }

  void _onLoading() async {
    pageNum++;
    await _getDesignerCaseList();
    if (_designerCaseList.isNotEmpty) {
      _refreshController.loadFailed();
    }
    else {
      _refreshController.loadComplete();
    }
  }

  //获取设计师列表
  Future<void> _getDesignerCaseList() async {
    try{
      final apiManager = ApiManager();
      final response =  await apiManager.get(
        '/api/designer/cases',
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
            _designerCaseList.addAll(arr);
          });
        }

      }
    }
    catch(e) {
      print(e);
    }
  }
}