import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/designer_case_grid.dart';
import 'package:flutter_smarthome/controllers/designer_moments.dart';
import 'package:flutter_smarthome/controllers/designer_service.dart';
import 'package:flutter_smarthome/controllers/discover_infomation.dart';
import 'package:flutter_smarthome/controllers/discover_recommend.dart';
import 'package:flutter_smarthome/controllers/furnish_form.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/string_utils.dart';

class DesignerHomeWidget extends StatefulWidget {
  final String userId;
  const DesignerHomeWidget({
    super.key,
    required this.userId,
  });

  @override
  State<DesignerHomeWidget> createState() => _DesignerHomeWidgteState();
}

class _DesignerHomeWidgteState extends State<DesignerHomeWidget>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> designerInfo = {};
  late TabController _tabController;
  // 添加滚动控制器用于监听滚动
  final ScrollController _scrollController = ScrollController();
  // 添加状态变量用于控制透明度
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getDesignerInfo();

    // 添加滚动监听
    _scrollController.addListener(() {
      final double offset = _scrollController.offset;
      setState(() {
        // 计算透明度：0-200范围内线性变化
        _opacity = (offset / 200).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose(); // 记得释放滚动控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController, // 添加滚动控制器
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 使用 SliverAppBar
            SliverAppBar(
              pinned: true,
              expandedHeight: 200.h,
              backgroundColor: Colors.white.withOpacity(_opacity),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _opacity > 0.5 ? Colors.black : Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                designerInfo['realName'] ?? '',
                style: TextStyle(
                  color: _opacity > 0.5 ? Colors.black : Colors.transparent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderBar(context),
              ),
            ),
            // 设计师信息区域
            SliverToBoxAdapter(
              child: _buildDesignerInfo(),
            ),
            // Tab导航栏
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: HexColor('#FFB26D'),
                  indicatorWeight: 2.0,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: '装修案例'),
                    Tab(text: '动态'),
                    Tab(text: '服务'),
                  ],
                ),
              ),
            ),

          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            DesignerCaseGridWidget(userId: widget.userId),
            DesignerMomentsListWidget(userId: widget.userId),
            DesignerServiceWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h, // 移除顶部padding
      child: NetworkImageHelper().getCachedNetworkImage(
        imageUrl: designerInfo['personalBackground'] ?? "",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDesignerInfo() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.h, left: 16.w),
            height: 60.w, // 设定合适的高度
            width: 60.w,
            child: ClipOval(
              child: NetworkImageHelper().getCachedNetworkImage(
                imageUrl: designerInfo['avatar']?.toString() ?? "",
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(top: 10.h, left: 16.w),
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
            padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
            child: Text(
              designerInfo['personalProfile'] ?? "暂无简介",
              style: TextStyle(fontSize: 12.sp, color: HexColor('#CA9C72')),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 8.h,
            color: HexColor('#F8F8F8'),
          ),
          _buildServiceInfo(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  //服务信息
  Widget _buildServiceInfo() {
    final result =
        '${designerInfo['excelStyle'] == null || (designerInfo['excelStyle'] as List).isEmpty ? "" : StringUtils.joinList(designerInfo['excelStyle'], separator: '、')}';
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.h),
            child: Text(
              '服务信息',
              style: TextStyle(
                color: HexColor('#222222'),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: HexColor('#F8F8F8'),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, top: 12.h),
                      child: Text(
                        '从业年限:',
                        style: TextStyle(
                          color: HexColor('#999999'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.w, top: 12.h),
                      child: Text(
                        '${designerInfo['workingYears'] ?? 0}年',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        '案例作品:',
                        style: TextStyle(
                          color: HexColor('#999999'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Text(
                        '${designerInfo['caseNumber'] ?? 0}套',
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Text(
                        '擅长风格:',
                        style: TextStyle(
                          color: HexColor('#999999'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Text(
                        result,
                        style: TextStyle(
                          color: HexColor('#222222'),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 获取设计师信息
  Future<void> _getDesignerInfo() async {
    try {
      final ApiManager apiManager = ApiManager();
      final Map<String, dynamic> response = await apiManager
          .get('/api/designer/profile', queryParameters: {'userId': widget.userId});
      if (mounted) {
        setState(() {
          designerInfo = response;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

// 创建一个 SliverPersistentHeaderDelegate 来处理 Tab 栏的布局
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Tab栏背景色
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}