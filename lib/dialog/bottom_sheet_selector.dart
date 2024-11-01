import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class BottomSheetSelector extends StatefulWidget {
  final List<String> options;
  final int? initialSelectedIndex;
  final Function(int) onSelected;
  final String? title;

  const BottomSheetSelector({
    Key? key,
    required this.options,
    required this.onSelected,
    this.initialSelectedIndex,
    this.title,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required List<String> options,
    required Function(int) onSelected,
    int? initialSelectedIndex,
    String? title,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // 设置为 true 以确保底部 sheet 延伸到安全区域下方
      isScrollControlled: true,
      builder: (context) => BottomSheetSelector(
        options: options,
        onSelected: onSelected,
        initialSelectedIndex: initialSelectedIndex,
        title: title,
      ),
    );
  }

  @override
  State<BottomSheetSelector> createState() => _BottomSheetSelectorState();
}

class _BottomSheetSelectorState extends State<BottomSheetSelector> {
  late int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    // 获取底部安全区域的高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消', style: TextStyle(color: Colors.grey,fontSize: 16.sp)),
                ),
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    if (selectedIndex != null) {
                      widget.onSelected(selectedIndex!);
                    }
                    Navigator.pop(context);
                  },
                  child: Text('确定', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
                ),
              ],
            ),
          ),
          const Divider(),
          // Options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  color: isSelected ? Colors.grey[100] : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.options[index],
                            style: TextStyle(
                              color: isSelected ? HexColor('#FFB26D') : Colors.black,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      // if (isSelected)
                      //   const Icon(
                      //     Icons.check,
                      //     color: Colors.blue,
                      //   ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 底部安全区域填充
          SizedBox(height: bottomPadding)
        ],
      ),
    );
  }
}