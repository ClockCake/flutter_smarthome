import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/custom_tab_indicator.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/number_formatter.dart';

class DecorationLogsProjectListWidget extends StatefulWidget {
  final String contractId;
  const DecorationLogsProjectListWidget({super.key,required this.contractId});

  @override
  State<DecorationLogsProjectListWidget> createState() => _DecorationLogsProjectListWidgetState();
}

class _DecorationLogsProjectListWidgetState extends State<DecorationLogsProjectListWidget> {
  List<Map<String, dynamic>> _projectList = []; // 项目清单
  @override
  void initState() {
    super.initState();
    _getProjectList();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_projectList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            '项目清单', 
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            )
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('项目清单', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Theme(
                    data: Theme.of(context).copyWith(
                      tabBarTheme: const TabBarThemeData(
                        dividerColor: Colors.transparent,
                        dividerHeight: 0,
                      ),
                    ),
                    child: ContainedTabBarView(
                      tabs: _projectList
                          .map((e) => Text('${e['roomName']}${e['landArea'] ?? 0}㎡'))
                          .toList(),
                      tabBarProperties: TabBarProperties(
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle:
                            TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: CustomTabIndicator(
                          indicatorWidth: 20.w,
                          indicatorColor: HexColor('#FFB26D'),
                          indicatorHeight: 4.w,
                        ),
                      ),
                      views: _projectList
                          .map((e) => DecorationLogsSimpleListPage(
                                projectList:
                                    List<Map<String, dynamic>>.from(e['rows']),
                              ))
                          .toList(),
                    ),
                  ),
                ),
          ],
        )
      ),
    );
  }
  Future<void> _getProjectList() async {
    // 获取项目清单
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/project/checklist',
      queryParameters: {'contractId':widget.contractId}
    );
    if(result.length > 0 && mounted){
      // 更新数据
      setState(() {
        _projectList = List<Map<String, dynamic>>.from(result);
      });
    }
  }

}

class DecorationLogsSimpleListPage extends StatefulWidget {
  final List<Map<String, dynamic>> projectList;
  const DecorationLogsSimpleListPage({super.key,required this.projectList});

  @override
  State<DecorationLogsSimpleListPage> createState() => _DecorationLogsSimpleListPageState();
}

class _DecorationLogsSimpleListPageState extends State<DecorationLogsSimpleListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: widget.projectList.length,        
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h,top: 8.h), // 添加底部间距
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(width: 16.w,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: NetworkImageHelper().getCachedNetworkImage(imageUrl: widget.projectList[index]['materialPic'] ?? "", width: 64.w, height: 64.w),
                ),
                SizedBox(width: 16.w,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.projectList[index]['materialName'] ?? "", style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),maxLines: 1,),
                    SizedBox(height: 4.h,),
                    Text('${widget.projectList[index]['sku']}  单位: ${widget.projectList[index]['unit']}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),maxLines: 1,),
                    SizedBox(height: 4.h,),
                    Text('${widget.projectList[index]['brandName'] ?? ""}',style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),maxLines: 1,),
                  ],
                ),
                Spacer(),
                Text('x${NumberFormatter.removeTrailingZeros(widget.projectList[index]['number'] ?? 0)}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                SizedBox(width: 16.w,),
              ],
            ),
          );
        },
      ),
    );
  }
}