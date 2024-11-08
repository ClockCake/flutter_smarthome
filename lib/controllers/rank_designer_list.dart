import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
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
        return _buildListCell();
      },
    );
  }
 
  //单元格 cell
  Widget _buildListCell(){
    return Column(
       
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
        '/api/designer//list',
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
          _designerList.addAll(arr);
        });
      }
    }
    catch(e) {
      print(e);
    }
  }
}