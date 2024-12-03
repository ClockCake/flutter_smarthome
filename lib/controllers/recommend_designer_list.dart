import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/designer_home.dart';
import 'package:flutter_smarthome/controllers/furnish_record_list.dart';
import 'package:flutter_smarthome/dialog/appointment-dialog.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/string_utils.dart';
import 'package:oktoast/oktoast.dart';

class RecommendDesignerListWidget extends StatefulWidget {
  const RecommendDesignerListWidget({super.key});

  @override
  State<RecommendDesignerListWidget> createState() => _RecommendDesignerListWidgetState();
}

class _RecommendDesignerListWidgetState extends State<RecommendDesignerListWidget> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 顶部导航栏白色黑字
        elevation: 0,
        title: const Text('推荐设计师'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                  '根据您的需求，为您推荐以下设计师',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
            Expanded(
              child: _buildDesignerList(),
            ),
            _buildChangeButton(),
            _buildSkipButton(),
          ],
        )
      ),
    );
  }

//推荐设计师列表
  Widget _buildDesignerList() {
    return ListView.builder(
      itemCount: _designerList.length,
      itemBuilder: (context, index) {
        final item = _designerList[index];

        return GestureDetector(
          onTap: (){
            Map<String, dynamic> designer = _designerList[index];
            Navigator.push(context, MaterialPageRoute(builder: (context) => DesignerHomeWidget(userId: designer['userId'])));
          },
          child: _buildListCell(item),
        );
      },
    );
 }

  Widget _buildListCell(Map<String,dynamic> item){
    final result = '${item['excelStyle'] == null || (item['excelStyle'] as List).isEmpty ? "" : StringUtils.joinList(item['excelStyle'])}${item['excelStyle'] == null || (item['excelStyle'] as List).isEmpty ? "" : " | "}${StringUtils.formatDisplay(
        item['caseNumber'],
        prefix: '案例作品',
        suffix: '套',
    )}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //设计师头像
            SizedBox(width: 16.w),
            Container(
              width: 40.w, // 设置宽度
              height: 40.w, // 设置高度
              child: ClipOval(
                  child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['avatar']?.toString() ?? "",width: 44.w,height: 44.w,fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 8.w),
            //设计师信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['realName'] ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HexColor('#999999'),
                    ),
                  ),
                  
                ],
              ),
            ),
            // Spacer(),
            //预约按钮
            GestureDetector(
              onTap: () {
                 _showDialog();
              },
              child: Container(
                width: 56.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: HexColor('#111111'),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Center(
                  child: Text(
                    '预约',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                )
              ),
            ),
            SizedBox(width: 16.w,)

          ],
        ),
        if (item['caseMainPic'] != null && (item['caseMainPic'] as List).isNotEmpty) 
          Container(
            margin: EdgeInsets.only(top: 12.h),
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
          ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: Divider(
            height: 1.h,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }


  //换一批按钮
  Widget _buildChangeButton() {
    return GestureDetector(
      onTap: () {
        _getDesignerList();
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 12.sp,),
            SizedBox(width: 8.w),
            Text('换一批', style: TextStyle(fontSize: 12.sp),),
          ],
        )
      ));
  }

  // 跳过
  // ignore: unused_element
  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FurnishRecordListWidget()));
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          height: 44.h,
          decoration: BoxDecoration(
            color: HexColor('#F4F5F7'),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Center(
            child: Text('跳过', style: TextStyle(color: HexColor('#666666'), fontSize: 15.sp),),
          ),
        ),
    );
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
      if (response['rows'].isNotEmpty) {
        final arr = List<Map<String, dynamic>>.from(response['rows']);
        if(mounted) {
          setState(() {
            _designerList = arr;
          });
        }
        pageNum++;

      }
    }
    catch(e) {
      print(e);
    }
  }

    //展示弹框
  void _showDialog() {
     AppointmentBottomSheet.show(
      context,
      onSubmit: (name, contact) {
        print('姓名: $name');
        print('联系方式: $contact');
        _handleSubmit(name, contact);
      },
    );
  }

    //全局预约提交
  void _handleSubmit(String name, String contact) async{
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home/overall/quick/appointment',
        data: {
          'userName': name,
          'userPhone': contact,
        },
      );
      if (response != null) {
         showToast('预约成功');
      }
    }catch(e){
      print(e);
    }
  }
}