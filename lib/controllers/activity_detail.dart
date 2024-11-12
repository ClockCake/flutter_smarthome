import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class ActivityDetailWiget extends StatefulWidget {

  final String title;
  final String activityId;
  const ActivityDetailWiget({
    super.key,
    required this.title,
    required this.activityId,
  });

  @override
  State<ActivityDetailWiget> createState() => _ActivityDetailWigetState();
}

class _ActivityDetailWigetState extends State<ActivityDetailWiget> {
  Map<String, dynamic> _activityDetail = {};
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getActivityDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double opacity = (_scrollController.offset / 100).clamp(0.0, 1.0);
    setState(() {
      _opacity = opacity;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(_opacity),
        iconTheme: IconThemeData(
          color: _opacity >= 0.5 ? Colors.black : Colors.white,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black.withOpacity(_opacity),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 150.h + MediaQuery.of(context).padding.top,
              child: _buildTopBackgroundImage(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 20.w),
                    child: Text(
                      _activityDetail['resourceTitle'] ?? '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: HexColor('#333333'),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: HexColor('#FFB26D'),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${_activityDetail['effectiveTimeBegin'] - _activityDetail['effectiveTimeEnd']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: HexColor('#999999'),
                          ),
                        ),
                      ],
                    )
                  ),
                  
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    child: Html(
                      data: _activityDetail['resourceInfo'] ?? '',
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTopBackgroundImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h + MediaQuery.of(context).padding.top,
      child: NetworkImageHelper().getCachedNetworkImage(
        imageUrl: _activityDetail['mainPic'],
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _getActivityDetail() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/activity/detail',
        queryParameters: {
          'id': widget.activityId,
        },
      );
      if (response != null && mounted) {
        setState(() {
          _activityDetail = response;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}