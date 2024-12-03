import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
           final item = widget.dataList[index];
           switch (item['type']) {
             case 'packages':
               return _buildPackages(item);
             case 'business':
               return _buildBusinessItem(item);
             case 'designer':
               return _buildDesigner(item);
             case 'case':
               return _buildCaseCell(item);
             default:
               return Placeholder();
           }
        },
        itemCount: 10,
      ),
    );
  }

  //构建产品
  Widget _buildPackages(Map<String, dynamic> item) {
    return Column(
      children: [
         ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['pic'], width: 100, height: 100),
         ),
         SizedBox(height: 5.h),
         Text(item['name'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '100㎡仅需 ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: '59900',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' 元起',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
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
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['pic'], width: 100, height: 100),
         ),
         SizedBox(height: 5.h),
         Text(item['name'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
          Row(
            children: [
              // if (product.shopIcon != null && product.shopIcon!.isNotEmpty) // 检查不仅不为 null 而且不为空字符串
              Container(
                width: 16,
                height: 16,
                child: NetworkImageHelper().getNetworkImage(imageUrl:""),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "1211",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // '¥${product.price.toStringAsFixed(2)}',
                '222',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: HexColor('#222222'),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                // '积分 ${product.points}',
                '2222',
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
       children: [
         ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['pic'], width: 100, height: 100),
         ),
         SizedBox(height: 5.h),
         Text(item['name'], style: TextStyle(fontSize: 13.sp, color: Colors.black)),
         SizedBox(height: 5.h),
         Text('xxxx',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
         SizedBox(height: 5.h,)
       ],
    );
  }

  //构建案例
  Widget _buildCaseCell(Map<String,dynamic> item) {
    return Column(
       children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['pic'], width: 100, height: 100),
        ),
        SizedBox(height: 5.h,),
        Text('2室1厅 · 现代简约',style:TextStyle(color: HexColor('#CA9C72'),fontSize: 12.sp),),
        SizedBox(height: 3.h,),
        Text('繁华都市中温馨质感新家',style:TextStyle(color: Colors.black,fontSize: 13.sp),),
        SizedBox(height: 3.h,),
         Row(
           children: [
             ClipOval(
               child: NetworkImageHelper().getCachedNetworkImage(imageUrl: item['pic'], width: 16.w, height: 16.w),
             ),
             SizedBox(width: 5.w,),
             Text('xxxx',style: TextStyle(color: HexColor('#999999'),fontSize: 12.sp),),
           ],
         )

       ],
    );
  }
}