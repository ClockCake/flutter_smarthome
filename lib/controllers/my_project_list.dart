import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_segments.dart';
import 'package:flutter_smarthome/models/user_model.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/navigation_controller.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';

class MyProjectListPage extends StatefulWidget {
  const MyProjectListPage({super.key});

  static const platform = MethodChannel('com.smartlife.navigation');

  // 添加一个静态方法来显示页面
  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyProjectListPage()),
    );
  }
  @override
  State<MyProjectListPage> createState() => _MyProjectListPageState();
}

class _MyProjectListPageState extends State<MyProjectListPage> {
  List<Map<String, dynamic>> projectList = [];

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('我的家', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18.sp,),
          onPressed: () async {
          await NavigationController.popToFlutter();
          Navigator.pop(context);

          },
        ),
      ),
      body: projectList.isNotEmpty ? ListView.separated(
        itemCount: projectList.length,
        separatorBuilder: (context, index) => Divider(height: 1.h, color: Colors.black12,),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              //跳转到项目详情页面
               Navigator.push(context, MaterialPageRoute(builder: (context) => DecorationLogsSegmentsWidget(customerProjectId: projectList[index]['projectId'])));
            },
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(projectList[index]['address'], style: TextStyle(fontSize: 14.sp, color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,),
                      ),
                      SizedBox(height: 4.h,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text('${projectList[index]['address'] ?? ""} · ${projectList[index]['bedroomNumber'] ?? 0}室 · ${projectList[index]['livingRoomNumber'] ?? 0}厅 · ${projectList[index]['area'] ?? 0}㎡' , style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),maxLines: 2,),
                      ),
                      SizedBox(height: 8.h,),
                  ],
                 ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16.sp, color: HexColor('#999999')),
                  SizedBox(width: 16.w,),
                ],
              )
            ),
          );
        },
      ) : EmptyStateWidget(onRefresh: _getProjectList),
    );
  }

  Future<void> _getProjectList() async {
    // 获取项目列表
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/project/list',
      queryParameters: {'phone': UserManager.instance.user?.mobile ?? ""}
    );
    if(result != null && mounted) {
      setState(() {
        projectList = List<Map<String, dynamic>>.from(result);
      });
    }
  }
}