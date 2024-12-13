import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/case_detail.dart';
import 'package:flutter_smarthome/controllers/designer_home.dart';
import 'package:flutter_smarthome/controllers/quick_quote.dart';
import 'package:flutter_smarthome/controllers/shopping_detail.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class SearchGridPageWidget extends StatefulWidget {
  final List<Map<String, dynamic>> dataList; //数据源
  const SearchGridPageWidget({
    super.key,
    required this.dataList,

  });

  @override
  State<SearchGridPageWidget> createState() => _SearchGridPageWidgetState();
}

class _SearchGridPageWidgetState extends State<SearchGridPageWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.dataList.isEmpty ? EmptyStateWidget(onRefresh: (){},)
      :Padding(
        padding: EdgeInsets.all(10.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final item = widget.dataList[index];
            switch (item['resourceType']) {
              case '1': //设计师
                return GestureDetector(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => DesignerHomeWidget(userId: item['data']['userId'],)));
                  },
                  child: _buildDesigner(item['data']),
                );
              case '2': //案例
                return GestureDetector(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailWidget(title: item['data']['caseTitle'], caseId: item['data']['id'],)));
                  },
                  child: _buildCaseCell(item['data']),
                );
              case '3': //商品
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingDetailPageWidget(commodityId: item['data']['id"'])));
                  },
                  child: _buildBusinessItem(item['data']),
                );
              case '4': //产品
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => QuickQuoteWidget(index: 0,)));
                  },
                  child: _buildPackages(item['data']),
                );
              default:
                return Placeholder();
            }
          },
          itemCount: widget.dataList.length,
        ),
      )
    );
  }

  //构建产品
  Widget _buildPackages(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['packagePic'] ?? ""),
         ),
         SizedBox(height: 5.h),
         Text(item['packageName'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '100㎡仅需 ',
                style: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: item['basePrice'].toString(),
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' 元起',
                style: TextStyle(
                  color: HexColor('#999999'),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
         ),
         SizedBox(height: 5.h,)
      ],
    );
  }
//构建商品
Widget _buildBusinessItem(Map<String,dynamic> item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: NetworkImageHelper().getCachedNetworkImage(
          imageUrl: item['mainPic'],
          width: double.infinity,
          height: 100.h, // 确保图片高度适中
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 5.h),
      Text(
        item['name'],
        style: TextStyle(fontSize: 13.sp, color: Colors.black),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 5.h),
      Row(
        children: [
          Container(
            width: 16,
            height: 16,
            child: NetworkImageHelper().getNetworkImage(
              imageUrl: item['businessLogo'] ?? "https://image.iweekly.top/i/2024/12/05/675120e7c5411.png",
              width: 14.w,
              height: 14.w,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "${item['businessName'] ?? ""}",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Text(
            '¥${item['salesPrice'] ?? ""}',
            style: TextStyle(
              fontSize: 16.sp,
              color: HexColor('#222222'),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            '积分 ${item['pointPrice'] ?? "0"}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ],
  );
}

  //构建设计师
  Widget _buildDesigner(Map<String,dynamic> item){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item['designerAvatar'] ?? "",
            width: double.infinity,
            height: 100.h, // 确保图片高度适中
            fit: BoxFit.cover,
          ),
        ),
         SizedBox(height: 5.h),
         Text(item['realName'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         Text('${item['excelStyle']} | 案例作品 ${item['caseCount']}套',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
         SizedBox(height: 5.h,)
         
       ],
    );
  }

  //构建案例
  Widget _buildCaseCell(Map<String,dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: item['caseMainPic'] ?? "https://image.iweekly.top/i/2024/12/05/675120e7c5411.png",
            width: double.infinity,
            height: 100.h, // 确保图片高度适中
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 5.h,),
        Text('${item['householdType']} · ${item['designStyle']}',style:TextStyle(color: HexColor('#CA9C72'),fontSize: 12.sp),maxLines: 1,overflow: TextOverflow.ellipsis,),
        SizedBox(height: 3.h,),
        Text('${item['caseTitle']}',style:TextStyle(color: Colors.black,fontSize: 13.sp),maxLines: 1,overflow: TextOverflow.ellipsis,),
        SizedBox(height: 3.h,),
         Row(
           children: [
             ClipOval(
               child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['avatar'] ?? "https://image.iweekly.top/i/2024/12/05/675120e7c5411.png", width: 16.w, height: 16.w),
             ),
             SizedBox(width: 5.w,),
             Text('${item['realName'] ?? ""}',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
           ],
         )

       ],
    );
  }
}