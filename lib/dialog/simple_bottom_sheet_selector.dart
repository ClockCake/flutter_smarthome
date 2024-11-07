import 'package:flutter/material.dart';

class SimpleBottomSheetSelector extends StatelessWidget {
  final List<Map<String, dynamic>> items; // 数据源，包含 title 和 id
  final Function(int) onSelected; // 选择回调
  final int? initialSelectedIndex; // 初始选中的索引

  const SimpleBottomSheetSelector({
    Key? key,
    required this.items,
    required this.onSelected,
    this.initialSelectedIndex,
  }) : super(key: key);

  // 显示底部弹框的静态方法
  static Future<void> show(
    BuildContext context, {
    required List<Map<String, dynamic>> items,
    required Function(int) onSelected,
    int? initialSelectedIndex,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SimpleBottomSheetSelector(
        items: items,
        onSelected: onSelected,
        initialSelectedIndex: initialSelectedIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = initialSelectedIndex == index;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onSelected(index);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              item['title'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}