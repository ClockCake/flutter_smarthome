import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_params.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class IndoorsPhotoWidget extends StatefulWidget {
  final String customerProjectId;
  const IndoorsPhotoWidget({super.key, required this.customerProjectId});

  @override
  State<IndoorsPhotoWidget> createState() => _IndoorsPhotoWidgetState();
}

class _IndoorsPhotoWidgetState extends State<IndoorsPhotoWidget> {
  List<Map<String, dynamic>> _indoorsPhotos = []; // 量房照片
  List<Map<String, dynamic>> _houseTypePhotos = [];   //户型图


  @override
  void initState() {
    super.initState();
    _getIndoorsPhoto();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h,),
            Row(
              children: [
                SizedBox(width: 16.w,),
                Text('量房照', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: Colors.black),),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    //跳转到量房照片页面
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DecorationLogsParamsWidget(customerProjectId: widget.customerProjectId)));
                  },
                  child: Text('确认量房参数', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                ),
                Icon(Icons.arrow_forward_ios, size: 12.sp, color: HexColor('#999999'),),
                SizedBox(width: 16.w,),
              ],  
            ),
            SizedBox(height: 16.h,),
            _indoorsPhotos.isNotEmpty ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _indoorsPhotos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    //跳转到量房照片详情页面
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: _indoorsPhotos[index]['url'],width: (screenWidth - 40.w) / 2.0, height: (screenWidth - 40.w) / 2.0, fit: BoxFit.cover),
                        ),  
                        SizedBox(height: 6.h,),
                        Text(_indoorsPhotos[index]['title'], style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      ],
                  ))
                );
              },
            ) :EmptyStateWidget(onRefresh: _getIndoorsPhoto,),
            SizedBox(height: 32.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('户型照', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: Colors.black),),
            ),
            SizedBox(height: 16.h,),
            _houseTypePhotos.isNotEmpty ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _houseTypePhotos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    //跳转到户型图详情页面
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: _houseTypePhotos[index]['url'],width: (screenWidth - 40.w) / 2.0, height: (screenWidth - 40.w) / 2.0, fit: BoxFit.cover),
                        ),  
                        SizedBox(height: 6.h,),
                        Text(_houseTypePhotos[index]['title'], style: TextStyle(fontSize: 14.sp, color: HexColor('#333333')),),
                      ],

                  ))
                );
              },
            ) : EmptyStateWidget(onRefresh: _getIndoorsPhoto,),
          ],
        ),
      ),
    );
  }

  Future<void> _getIndoorsPhoto() async {
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/estimate/photos',
      queryParameters: {
        'customerProjectId': widget.customerProjectId,
      },
    );
    
    if (result is List && result.isNotEmpty && mounted) {
      setState(() {
        for (var item in result) {
          if (item is Map<String, dynamic>) {
            if (item['type'] == '3' && item['row'] is List) {
              _indoorsPhotos = (item['row'] as List).map((e) => 
                Map<String, dynamic>.from(e as Map)
              ).toList();
            }
            if (item['type'] == '2' && item['row'] is List) {
              _houseTypePhotos = (item['row'] as List).map((e) => 
                Map<String, dynamic>.from(e as Map)
              ).toList();
            }
          }
        }
      });
    }
  }

}