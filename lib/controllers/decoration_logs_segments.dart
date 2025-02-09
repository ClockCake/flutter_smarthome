import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_contract.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_design.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_indoors.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';

class DecorationLogsSegmentsWidget extends StatefulWidget {
  final String customerProjectId;
  const DecorationLogsSegmentsWidget({super.key, required this.customerProjectId});

  @override
  State<DecorationLogsSegmentsWidget> createState() => _DecorationLogsSegmentsWidgetState();
}

class _DecorationLogsSegmentsWidgetState extends State<DecorationLogsSegmentsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabsData = [
    {
      'icon': 'assets/images/icon_decoration_logs_first.png',
      'title': '量房信息'
    },
    {
      'icon': 'assets/images/icon_decoration_logs_second.png',
      'title': '设计信息'
    },
    {
      'icon': 'assets/images/icon_decoration_logs_third.png',
      'title': '合同信息'
    },
    {
      'icon': 'assets/images/icon_decoration_logs_fourth.png',
      'title': '装修服务'
    },
    {
      'icon': 'assets/images/icon_decoration_logs_fifth.png',
      'title': '售后保障'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabsData.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> _buildTabs() {
    return _tabsData.map((data) {
      return Tab(
        height: 65.h, // 设置固定高度
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            final isSelected = _tabsData.indexOf(data) == _tabController.index;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
              children: [
                Image.asset(
                  data['icon'] as String,
                  width: 24.w,  // 调整图标大小
                  height: 24.h,
                ),
                SizedBox(height: 4.h), // 添加间距
                Text(
                  data['title'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              ],
            );
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildTabViews() {
    return [
      IndoorsPhotoWidget(customerProjectId: '9b53665fab174ce0ae97f3c5cf70b653'),
      DesignerPhotosWidget(customerProjectId: '9b53665fab174ce0ae97f3c5cf70b653'),
      ContractListWidget(customerProjectId: '9b53665fab174ce0ae97f3c5cf70b653'),
      EmptyStateWidget(onRefresh: () {},),
      EmptyStateWidget(onRefresh: () {},),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('装修日志', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          )
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 65.h, // 设置固定高度
            child: TabBar(
              controller: _tabController,
              tabs: _buildTabs(),
              indicator: const BoxDecoration(),
              labelPadding: EdgeInsets.zero, // 移除默认内边距
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _buildTabViews(),
            ),
          ),
        ],
      ),
    );
  }
}


