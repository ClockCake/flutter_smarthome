import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/shopping_list.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class ShoppingCategoryListWidget extends StatefulWidget {
  const ShoppingCategoryListWidget({super.key});

  @override
  State<ShoppingCategoryListWidget> createState() => _ShoppingCategoryListWidgetState();
}

class _ShoppingCategoryListWidgetState extends State<ShoppingCategoryListWidget> {
  int selectedIndex = 0;
  final ScrollController _gridController = ScrollController();
  final ScrollController _listController = ScrollController();
  List<Map<String, dynamic>> categories = [];

  List<double> categoryOffsets = [];
  bool isProgrammaticScroll = false;
  List<GlobalKey> categoryItemKeys = [];

  @override
  void initState() {
    super.initState();
    _getCategory();
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

  void _calculateCategoryOffsets(BuildContext context) {
    if (categories.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final leftSideWidth = 100.0;
    final availableWidth = screenWidth - leftSideWidth - 24.0;

    final crossAxisCount = 3;
    final childAspectRatio = 0.8;
    final mainAxisSpacing = 10.0;
    final crossAxisSpacing = 10.0;

    final gridItemWidth = (availableWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final gridItemHeight = gridItemWidth / childAspectRatio;

    final headerHeight = 32.0; // 16.0 + 16.0

    categoryOffsets = [];
    double cumulativeOffset = 0.0;

    for (var category in categories) {
      final List<dynamic> subCategories = category['childCommodityCategoryList'] ?? [];
      if (subCategories.isNotEmpty) {
        final subCategoryCount = subCategories.length;
        final numRows = (subCategoryCount / crossAxisCount).ceil();
        final gridHeight = numRows * gridItemHeight + (numRows - 1) * mainAxisSpacing;
        final sectionHeight = headerHeight + gridHeight;

        categoryOffsets.add(cumulativeOffset);
        cumulativeOffset += sectionHeight;
      }
    }
  }

  void _onGridScroll() {
    if (isProgrammaticScroll) return;

    final double offset = _gridController.offset;
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

      if (categoryItemKeys.length > index && categoryItemKeys[index].currentContext != null) {
        Scrollable.ensureVisible(
          categoryItemKeys[index].currentContext!,
          duration: const Duration(milliseconds: 200),
          alignment: 0.5,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onCategoryTap(int index) {
    if (index >= categoryOffsets.length) return;
    
    setState(() {
      selectedIndex = index;
    });
    
    isProgrammaticScroll = true;
    _gridController.animateTo(
      categoryOffsets[index],
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      isProgrammaticScroll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateCategoryOffsets(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('全部分类', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categories.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Row(
          children: [
            SizedBox(
              width: 100,
              child: ListView.builder(
                controller: _listController,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCategoryTap(index),
                    child: Container(
                      key: categoryItemKeys[index],
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
                        categories[index]['categoryName'] ?? '',
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
            Expanded(
              child: ListView.builder(
                controller: _gridController,
                itemCount: categories.length,
                itemBuilder: (context, categoryIndex) {
                  final List<dynamic> subCategories = 
                    categories[categoryIndex]['childCommodityCategoryList'] ?? [];
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Text(
                          categories[categoryIndex]['categoryName'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (subCategories.isNotEmpty)
                      GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: subCategories.length,
                            itemBuilder: (context, index) {
                              final subCategory = subCategories[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => ShoppingListWidget(
                                        firstCategoryId: categories[categoryIndex]['categoryId']?.toString() ?? '',
                                        secondCategoryId: subCategory['categoryId']?.toString() ?? '',
                                        categoryName: subCategory['categoryName']?.toString() ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                          child: NetworkImageHelper().getCachedNetworkImage(
                                            imageUrl: subCategory['categoryIcon']?.toString() ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          subCategory['categoryName']?.toString() ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _getCategory() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get('/api/shopping/category');

      if (response != null && mounted) {
        final data = List<Map<String, dynamic>>.from(response);
        if (data.isNotEmpty) {
          setState(() {
            categories = data;
            categoryItemKeys = List.generate(data.length, (index) => GlobalKey());
          });
        }
      }
    } catch (e) {
      print('获取分类数据错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取分类数据失败，请稍后重试')),
        );
      }
    }
  }
}