import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class DesignerHomeWidget extends StatefulWidget {
  final String userId;
  const DesignerHomeWidget({
    super.key,
    required this.userId
  });

  @override
  State<DesignerHomeWidget> createState() => _DesignerHomeWidgteState();
}

class _DesignerHomeWidgteState extends State<DesignerHomeWidget> {
  Map<String, dynamic> designerInfo = {};
  @override
  void initState() {
    super.initState();
    print('userId: ${widget.userId}');
    _getDesignerInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderBar(context),
            _buildDesignerInfo(),
          ],
        ),
      )
    );
  }

  // 顶部图片部分
  Widget _buildHeaderBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: 200.h + topPadding,
      child: Stack(
        children: [
          // 背景图片
          NetworkImageHelper().getCachedNetworkImage(
            imageUrl: designerInfo['personalBackground'] ?? "",
            fit: BoxFit.cover,
          ),
          // 返回按钮
          Positioned(
            left: 16.w,
            top: MediaQuery.of(context).padding.top + 10.h, // 适配状态栏高度
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildDesignerInfo(){
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Stack(
              clipBehavior: Clip.none, // 允许子组件超出边界
              children: [
                Positioned(
                  top: -20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 68.w,
                      height: 68.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34.w),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: NetworkImageHelper().getCachedNetworkImage(
                        imageUrl: designerInfo['avatar'] ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h,left: 16.w),
              child: Text(
                designerInfo['realName'] ?? '',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.h,left: 16.w,right: 16.w),
              child: Text(
                designerInfo['personalProfile'] ?? "暂无简介",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#CA9C72')
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 获取设计师信息
  Future<void> _getDesignerInfo() async {
    try{
      final ApiManager apiManager = ApiManager();
      final Map<String, dynamic> response = await apiManager.get('/api/designer/profile', queryParameters: {'userId': widget.userId});
      if (mounted){
        setState(() {
          designerInfo = response;
        });
      }
    }
    catch(e) {
      print(e);
    }
  }
}