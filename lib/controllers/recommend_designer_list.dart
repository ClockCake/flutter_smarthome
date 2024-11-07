import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/furnish_record_list.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class RecommendDesignerListWidget extends StatefulWidget {
  const RecommendDesignerListWidget({super.key});

  @override
  State<RecommendDesignerListWidget> createState() => _RecommendDesignerListWidgetState();
}

class _RecommendDesignerListWidgetState extends State<RecommendDesignerListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 顶部导航栏白色黑字
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
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(height: 16.h),
            Row(
              children: [
                //设计师头像
                SizedBox(width: 16.w),
                Container(
                  width: 40.w, // 设置宽度
                  height: 40.w, // 设置高度
                  child: CircleAvatar(
                    radius: 20.w,
                    backgroundImage: NetworkImage(
                      'https://image.itimes.me/i/2024/07/26/66a30d068028b.jpg',
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(width: 8.w),
                //设计师信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '王安',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '轻奢| 案例作品 200套',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: HexColor('#999999'),
                        ),
                      ),
                      
                    ],
                  ),
                ),
                Spacer(),
                //预约按钮
                GestureDetector(
                  onTap: () {
                    print('预约');
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
            SizedBox(height: 12.h),
            Container(
              height: 100.h,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 52.w,right: 12.w),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: 8.w),
                    width: 120.w,
                    height: 90.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImageHelper().getCachedNetworkImage(
                        imageUrl: 'https://image.itimes.me/i/2024/07/26/66a30d068028b.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            //分割线左右两边 12.w的间距
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w),
              child: Divider(
                height: 1.h,
                color: Colors.grey[300],
              ),
            ),
          ],
        );
      },
    );
 }

  


  //换一批按钮
  Widget _buildChangeButton() {
    return GestureDetector(
      onTap: () {
        print('换一批');
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
}