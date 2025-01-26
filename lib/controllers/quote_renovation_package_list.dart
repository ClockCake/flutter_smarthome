import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/quote_number.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class QuoteRenovationPackageListWidget extends StatefulWidget {
  final RoomType roomType;  //房间类型
  final List<Map<String, dynamic>> packages;
  final Function(Map<String, dynamic>, int) updatePackage;
  final int index;
  const QuoteRenovationPackageListWidget({
    Key? key, 
    required this.roomType,
    required this.packages,
    required this.updatePackage,
    required this.index
  }) : super(key: key);
  @override
  State<QuoteRenovationPackageListWidget> createState() => _QuoteRenovationPackageListWidgetState();
}

class _QuoteRenovationPackageListWidgetState extends State<QuoteRenovationPackageListWidget> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _packageList = []; //方案列表
  int? _selectedIndex; // 新增：跟踪选中的索引
  bool _isDataLoaded = false;  // 添加标志位追踪数据是否已加载
  @override
  bool get wantKeepAlive => true;  // 保持页面状态

  @override
  void initState() {
    super.initState();
    if (!_isDataLoaded) {  // 只在数据未加载时获取数据
      _getPackageList();
    }
  }


  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);  // 必须调用 super.build
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '选择方案',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: _buildPackageList(),
            )
          ],
        ),
      ),
    );
  }

    Widget _buildPackageList() {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _packageList.length,
        itemBuilder: (context, index) {
          final item = _packageList[index];
          final bool isSelected = _selectedIndex == index;
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: NetworkImageHelper().getCachedNetworkImage(
                      imageUrl: item['packagePic'] ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150.h,
                    ),
                  ),
                  SizedBox(height: 12.h,),
                  Row(
                    children: [
                      Expanded(  // Wrap Column with Expanded to prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
                          children: [
                            SizedBox(height: 8.h,),
                            Text(
                              item['packageName'] ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 4.h,),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '100m²仅需',
                                    style: TextStyle(
                                      color: HexColor('#999999'),
                                      fontSize: 12.sp
                                    )
                                  ),
                                  TextSpan(
                                    text: '${item['basePrice'] ?? 0}',
                                    style: TextStyle(
                                      color: HexColor('#FFA555'),
                                      fontSize: 16.sp
                                    )
                                  ),
                                  TextSpan(
                                    text: '元',
                                    style: TextStyle(
                                      color: HexColor('#999999'),
                                      fontSize: 12.sp
                                    )
                                  )
                                ]
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // 如果当前项已经被选中，则取消选中
                            if (_selectedIndex == index) {

                            } else {
                              _selectedIndex = index;
                              if (widget.updatePackage != null) {
                                widget.updatePackage(item,widget.index);
                              }
                            }
                          });

                        },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected ? HexColor('#FFB26D') : HexColor('#000000')
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) 
                            Icon(Icons.check, color: HexColor('#FFB26D'), size: 14.sp,),
                            Text(
                              '选择方案',
                              style: TextStyle(
                                color: isSelected ? HexColor('#FFB26D') : HexColor('#333333'),
                                fontSize: 13.sp
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
  }

  Future<void> _getPackageList() async {
     final apiManager = ApiManager();
     int param = 0;
     switch (widget.roomType) {
       case RoomType.kitchen:
         param = 1;
         break;
       case RoomType.bathroom:
         param = 9;
         break;
       case RoomType.wallRefresh:
         param = 28;
         break;
       default:
         break;
     }
    final result = await apiManager.get(
      '/api/valuation/packages/micro',
      queryParameters: {
        'roomType': param,
      },
    );
    List<Map<String, dynamic>> response = [];
    //遍历获取到的数据
    for (var item in result) {
       item['index'] = widget.index;
       response.add(item);
    }
    if (result != null && mounted) {
      setState(() {
        _packageList = response;
      });
    }

  }
}