import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class DesignerPhotosWidget extends StatefulWidget {
  final String customerProjectId;
  const DesignerPhotosWidget({super.key, required this.customerProjectId});

  @override
  State<DesignerPhotosWidget> createState() => _DesignerPhotosWidgetState();
}

class _DesignerPhotosWidgetState extends State<DesignerPhotosWidget> {
  List<Map<String, dynamic>> plans = []; // 设计方案
  
  @override
  void initState() {
    super.initState();
    _getDesignerPhotos();
  }
  @override 
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
        //获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child:  plans.length > 0 ? ListView.builder(
        itemCount: plans.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('${plan['typeDisplay']}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
              ),
              SizedBox(height: 16.h,),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: plan['row'].length,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = plan['row'][index];
                  return GestureDetector(
                    onTap: () {
                      //跳转到设计方案详情页面
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['url'], width: (screenWidth - 40.w) / 2.0,height: (screenWidth - 40.w) / 2.0),
                        ),
                        SizedBox(height: 8.h,),
                        Text('${item['title']}', style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      ],
                    )
                  );
                },
              )
            ],
          );
        },
      ) : Column(
        children: [
          SizedBox(height: 1/4 * MediaQuery.of(context).size.height,),
          EmptyStateWidget(onRefresh: _getDesignerPhotos,),
        ],  
      ))
    );
  }


  //获取设计方案
  void _getDesignerPhotos() async {
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/design/photos',
      queryParameters: {
        'customerProjectId': widget.customerProjectId,
      },
    );
    if(result.length > 0 && mounted){
      setState(() {
        plans = List<Map<String, dynamic>>.from(result);
      });
    }
  }
}