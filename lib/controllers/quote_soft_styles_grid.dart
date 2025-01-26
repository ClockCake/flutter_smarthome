import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class QuoteSoftStylesGridWidget extends StatefulWidget {
  final RoomType roomType;  //房间类型
  final String packageId;
  final Function(Map<String, dynamic>, int) updatePackage;
  final int index;

  const QuoteSoftStylesGridWidget({super.key,required this.roomType,required this.packageId,required this.updatePackage,required this.index});

  @override
  State<QuoteSoftStylesGridWidget> createState() => _QuoteSoftStylesGridWidgetState();
}

class _QuoteSoftStylesGridWidgetState extends State<QuoteSoftStylesGridWidget> with AutomaticKeepAliveClientMixin {
  int selectedIndex = -1;  // 添加选中索引状态
  List<Map<String, dynamic>> styles = [];  // 添加风格列表
   
  @override 
  bool get wantKeepAlive => true; 

  @override
  void initState() {
    super.initState();
    _getSoftStyles();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '选择风格 · 套餐包名称',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,  // 调整比例以适应底部文字
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 10.h,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = styles[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedIndex == index) {

                        } else {
                          selectedIndex = index;
                          if (widget.updatePackage != null) {
                            widget.updatePackage(item,widget.index);
                          }
                        }
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 160.h,  // 固定图片高度
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.r),
                                child: NetworkImageHelper().getCachedNetworkImage(
                                  imageUrl: styles[index % styles.length]["pic"] ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8.w,
                              right: 8.h,
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: selectedIndex == index ? Colors.orange : Colors.grey.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: selectedIndex == index 
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16.sp,
                                    )
                                  : const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            styles[index % styles.length]["dictLabel"]!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,  
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: styles.length,
              ),
            )
          ],
        ),
      )
    );
  }

  Future<void> _getSoftStyles() async {
    // 获取软装风格
    int type = 0;
    switch (widget.roomType) {
      case RoomType.livingRoom:
        type = 7;
        break;
      case RoomType.bedroom:
        type = 6;
        break;
      case RoomType.restaurant:
        type = 5;
        break;
      default:
    }
    final apiManager = ApiManager();
    final result = await apiManager.get('/api/valuation/packages/soft',queryParameters: {'packageId':widget.packageId ,'roomType':type});  // 传入接口地址

    List<Map<String, dynamic>> response = [];
    //遍历获取到的数据
    for (var item in result) {
       item['index'] = widget.index;
       response.add(item);
    }
    if (result != null && mounted) {
      setState(() {
        styles = response;
      });
    }

  }
}