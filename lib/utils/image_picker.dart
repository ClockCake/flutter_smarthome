import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();
  
  // 显示选择菜单
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 8,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.black),
                title: const Text('拍照'),
                onTap: () async {
                  Navigator.pop(context); // 关闭底部菜单
                  final file = await _pickImage(ImageSource.camera);
                  if (file != null && context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop(file); // 返回文件
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text('从相册选择'),
                onTap: () async {
                  Navigator.pop(context); // 关闭底部菜单
                  final file = await _pickImage(ImageSource.gallery);
                  if (file != null && context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop(file); // 返回文件
                  }
                },
              ),
              Container(
                width: double.infinity,
                height: 8,
                color: Colors.grey[100],
              ),
              ListTile(
                title: const Text(
                  '取消',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context, null), // 返回 null
              ),
            ],
          ),
        );
      },
    );
  }

  // 选择图片
  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('选择图片错误: $e');
    }
    return null;
  }
}