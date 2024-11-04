import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheUtil {
  static final ValueNotifier<String> cacheSizeNotifier = ValueNotifier('0.00B');

  /// 获取缓存大小
  static Future<String> getCacheSize() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      
      int tempSize = await _calculateDirSize(tempDir);
      int appDocSize = await _calculateDirSize(appDocDir);
      
      int totalSize = tempSize + appDocSize;
      
      return _formatSize(totalSize);
    } catch (e) {
      return '0.00B';
    }
  }

  // 更新缓存大小显示
  static Future<void> updateCacheSize() async {
    String size = await getCacheSize();
    cacheSizeNotifier.value = size;
  }

  // 清除缓存并更新显示
  static Future<bool> clearCacheAndUpdate() async {
    bool result = await clearCache();
    if (result) {
      await updateCacheSize();
    }
    return result;
  }

  /// 清除缓存
  static Future<bool> clearCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      
      await _deleteDirectory(tempDir);
      await _deleteDirectory(appDocDir);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 计算目录大小
  static Future<int> _calculateDirSize(Directory dir) async {
    try {
      int size = 0;
      
      if (dir.existsSync()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
      
      return size;
    } catch (e) {
      return 0;
    }
  }

  /// 删除目录内容
  static Future<void> _deleteDirectory(Directory dir) async {
    if (dir.existsSync()) {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
  }

  /// 格式化文件大小
  static String _formatSize(int size) {
    if (size <= 0) return '0.00B';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    int index = 0;
    double convertedSize = size.toDouble();
    
    while (convertedSize > 1024 && index < units.length - 1) {
      convertedSize /= 1024;
      index++;
    }
    
    return '${convertedSize.toStringAsFixed(2)}${units[index]}';
  }
}