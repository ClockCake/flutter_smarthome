import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShoppingCategoryListWidget extends StatefulWidget {
  const ShoppingCategoryListWidget({super.key});

  @override
  State<ShoppingCategoryListWidget> createState() => _ShoppingCategoryListWidgetState();
}

class _ShoppingCategoryListWidgetState extends State<ShoppingCategoryListWidget> {
  int selectedIndex = 0;
  final ScrollController _gridController = ScrollController();
  final ScrollController _listController = ScrollController();
  final List<String> categories = List.generate(10, (index) => '一级分类 ${index + 1}');
  
  // 模拟每个分类下的子项数据
  final List<List<String>> subCategories = List.generate(
    10,
    (index) => List.generate(15, (subIndex) => '二级分类'),
  );

  List<double> categoryOffsets = [];
  bool isProgrammaticScroll = false;

  // 为左侧列表的每个项创建 GlobalKey
  List<GlobalKey> categoryItemKeys = [];

  @override
  void initState() {
    super.initState();
    _gridController.addListener(_onGridScroll);
    categoryItemKeys = List.generate(categories.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _gridController.removeListener(_onGridScroll);
    _gridController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // 计算每个分类的偏移量
  void _calculateCategoryOffsets(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftSideWidth = 100.0; // 左侧列表宽度
    final availableWidth = screenWidth - leftSideWidth - 24.0; // 右侧可用宽度，减去左右内边距

    final crossAxisCount = 3;
    final childAspectRatio = 0.8;
    final mainAxisSpacing = 10.0;
    final crossAxisSpacing = 10.0;

    final gridItemWidth = (availableWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final gridItemHeight = gridItemWidth / childAspectRatio;

    final headerHeight = 16.0 + 16.0; // 标题高度（字体大小 + 上下内边距）

    categoryOffsets = [];

    double cumulativeOffset = 0.0;

    for (int i = 0; i < categories.length; i++) {
      final subCategoryCount = subCategories[i].length;
      final numRows = (subCategoryCount / crossAxisCount).ceil();
      final gridHeight = numRows * gridItemHeight + (numRows - 1) * mainAxisSpacing;

      final sectionHeight = headerHeight + gridHeight;

      categoryOffsets.add(cumulativeOffset);

      cumulativeOffset += sectionHeight;
    }
  }

  // 处理网格视图滚动
  void _onGridScroll() {
    if (isProgrammaticScroll) {
      // 忽略程序触发的滚动
      return;
    }

    final double offset = _gridController.offset;

    // 根据偏移量找到当前应该选中的分类索引
    int index = selectedIndex;
    for (int i = 0; i < categoryOffsets.length; i++) {
      if (offset >= categoryOffsets[i]) {
        index = i;
      } else {
        break;
      }
    }

    if (index != selectedIndex && index >= 0 && index < categories.length) {
      setState(() {
        selectedIndex = index;
      });

      // 确保左侧列表选中的项在可视区域内
      if (categoryItemKeys[index].currentContext != null) {
        Scrollable.ensureVisible(
          categoryItemKeys[index].currentContext!,
          duration: const Duration(milliseconds: 200),
          alignment: 0.5,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // 点击左侧列表项
  void _onCategoryTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    
    // 计算需要滚动到的位置
    final double offset = categoryOffsets[index];
    isProgrammaticScroll = true;
    _gridController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      isProgrammaticScroll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categoryOffsets.isEmpty) {
      _calculateCategoryOffsets(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('全部分类', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Row(
        children: [
          // 左侧分类列表
          SizedBox(
            width: 100,
            child: ListView.builder(
              controller: _listController,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCategoryTap(index),
                  child: Container(
                    key: categoryItemKeys[index], // 添加 GlobalKey
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: selectedIndex == index
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.orange
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 右侧网格视图
          Expanded(
            child: ListView.builder(
              controller: _gridController,
              itemCount: categories.length,
              itemBuilder: (context, categoryIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类标题
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
                      child: Text(
                        categories[categoryIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 网格视图
                    GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: subCategories[categoryIndex].length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.image, color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subCategories[categoryIndex][index],
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}