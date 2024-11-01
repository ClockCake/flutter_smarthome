import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NickNameDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const NickNameDialog({
    Key? key,
    this.title = "",
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 280.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              height: 48.h, // 设置固定高度
              margin: EdgeInsets.symmetric(horizontal: 16.h), // 设置左右边距
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "请填写",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text("取消", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ),
         
                TextButton(
                  onPressed: onConfirm,
                  child: Text("确定", style: TextStyle(color: Colors.black,fontSize: 14.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}