import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTabBarWidget extends StatefulWidget {
  const CustomTabBarWidget({Key? key}) : super(key: key);

  @override
  State<CustomTabBarWidget> createState() => _CustomTabBarWidgetState();
}

class _CustomTabBarWidgetState extends State<CustomTabBarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    '商品分类',
    '一级分类',
    '二级分类',
    '三级分类',
    '四级分类',
    '五级分类',
    '六级分类'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when the tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int tabCount = _tabs.length;
    bool isScrollable = tabCount > 4;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double totalWidth = constraints.maxWidth;
                double tabWidth = totalWidth / (isScrollable ? 4 : tabCount);

                return TabBar(
                  controller: _tabController,
                  isScrollable: isScrollable,
                  labelPadding: EdgeInsets.zero,
                  tabs: List.generate(_tabs.length, (index) {
                    String title = _tabs[index];
                    bool isSelected = _tabController.index == index;

                    return SizedBox(
                      width: tabWidth,
                      child: Tab(
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: isSelected ? 18.sp : 14.sp,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(
                      width: 3,
                      color: Colors.orange,
                    ),
                    insets: EdgeInsets.symmetric(
                      horizontal: (tabWidth - 24) / 2, // Set indicator width to 24
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              print('右侧按钮被点击');
            },
            icon: const Icon(Icons.menu, size: 24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}