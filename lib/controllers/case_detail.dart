import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/dialog/appointment-dialog.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import 'package:flutter_smarthome/utils/string_utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oktoast/oktoast.dart';

class CaseDetailWidget extends StatefulWidget {
  final String title;
  final String caseId;
  const CaseDetailWidget({
    super.key,
    required this.title,
    required this.caseId,
  });

  @override
  State<CaseDetailWidget> createState() => _CaseDetailWidgetState();
}

class _CaseDetailWidgetState extends State<CaseDetailWidget> {
  Map<String, dynamic> _caseDetail = {};
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getCaseDetail();
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
                      _caseDetail['caseTitle'] ?? '',
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
                    child: _buildPersonalInfo(),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildCaseInfo(),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '设计简介',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: HexColor('#333333'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                    child: Html(
                      data: _caseDetail['caseInfo'] ?? '',
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
    String defaultImage = 'https://image.iweekly.top/i/2025/01/08/677e186e73d4a.png';
    
    List<String> pics;
    try {
      pics = List<String>.from(_caseDetail['caseMainPic'] ?? []);
    } catch (e) {
      pics = [];
    }
    
    final String imageUrl = pics.isEmpty ? defaultImage : pics.first;

    return Container(
      width: double.infinity,
      height: 150.h + MediaQuery.of(context).padding.top,
      child: NetworkImageHelper().getCachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final result = '${_caseDetail['excelStyle'] == null || (_caseDetail['excelStyle'] as List).isEmpty ? "" : StringUtils.joinList(_caseDetail['excelStyle'])}${_caseDetail['excelStyle'] == null || (_caseDetail['excelStyle'] as List).isEmpty ? "" : " | "}${StringUtils.formatDisplay(
      _caseDetail['caseNumber'],
      prefix: '案例作品',
      suffix: '套',
    )}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: NetworkImageHelper().getCachedNetworkImage(
            imageUrl: _caseDetail['avatar'] ?? '',
            width: 40.w,
            height: 40.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _caseDetail['realName'] ?? '',
              style: TextStyle(
                fontSize: 15.sp,
                color: HexColor('#222222'),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              result,
              style: TextStyle(
                fontSize: 12.sp,
                color: HexColor('#999999'),
              ),
            ),
          ],
        ),
        Spacer(),
        InkWell(
          onTap: () {
            _showDialog();
          },
          child: Container(
            width: 56.w,
            height: 28.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14.w),
            ),
            child: Text(
              '预约',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseInfo() {
    final result =
    '${_caseDetail['designStyle'] == null || (_caseDetail['designStyle'] as List).isEmpty ? "" : StringUtils.joinList(_caseDetail['designStyle'], separator: '、')}';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: HexColor('#F8F8F8'),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 户型信息
          Column(
            children: [
              Text(
                '户型',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#999999'),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                _caseDetail['householdType'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: HexColor('#333333'),
                ),
              ),
            ],
          ),
          
          // 分隔线
          Container(
            height: 24.w,
            width: 1,
            color: HexColor('#EEEEEE'),
          ),
          
          // 建筑面积
          Column(
            children: [
              Text(
                '建筑面积',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#999999'),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                StringUtils.formatDisplay(
                  _caseDetail['area'],
                  suffix: '㎡',
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: HexColor('#333333'),
                ),
              ),
            ],
          ),
          
          // 分隔线
          Container(
            height: 24.w,
            width: 1,
            color: HexColor('#EEEEEE'),
          ),
          
          // 设计风格
          Column(
            children: [
              Text(
                '设计风格',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: HexColor('#999999'),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                result,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: HexColor('#333333'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //展示弹框
  void _showDialog() {
     AppointmentBottomSheet.show(
      context,
      onSubmit: (name, contact) {
        print('姓名: $name');
        print('联系方式: $contact');
        _handleSubmit(name, contact);
      },
    );
  }
  
  Future<void> _getCaseDetail() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/cases/detail',
        queryParameters: {
          'id': widget.caseId,
        },
      );
      if (response != null && mounted) {
        setState(() {
          _caseDetail = response;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //全局预约提交
  void _handleSubmit(String name, String contact) async{
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home/overall/quick/appointment',
        data: {
          'userName': name,
          'userPhone': contact,
        },
      );
      if (response != null) {
         showToast('预约成功');
      }
    }catch(e){
      print(e);
    }
  }
}