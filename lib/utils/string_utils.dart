class StringUtils {
  /// 基础列表拼接，支持动态类型转换
  static String joinList<T>(
    dynamic list, {
    String separator = ', ',
    String defaultValue = '',
    bool skipEmpty = true,
  }) {
    if (list == null) return defaultValue;
    
    try {
      final List<dynamic> dynamicList = list is List ? list : [];
      
      return dynamicList
          .where((item) => !skipEmpty || (item?.toString() ?? '').isNotEmpty)
          .map((item) => item?.toString() ?? '')
          .join(separator);
    } catch (e) {
      print('StringUtils.joinList error: $e');
      return defaultValue;
    }
  }

  /// 带转换功能的拼接
  static String joinWithTransform<T>(
    dynamic list, {
    String separator = ', ',
    String defaultValue = '',
    String Function(T)? transform,
    bool skipEmpty = true,
  }) {
    if (list == null) return defaultValue;

    try {
      final List<dynamic> dynamicList = list is List ? list : [];
      
      return dynamicList
          .where((item) => item != null)
          .map((item) {
            try {
              if (transform != null) {
                return transform(item as T);
              }
              return item.toString();
            } catch (e) {
              print('Transform error: $e');
              return '';
            }
          })
          .where((str) => !skipEmpty || str.isNotEmpty)
          .join(separator);
    } catch (e) {
      print('StringUtils.joinWithTransform error: $e');
      return defaultValue;
    }
  }

  /// 带长度限制的拼接
  static String joinWithLimit(
    dynamic list, {
    String separator = ', ',
    String defaultValue = '',
    int maxLength = 100,
    String overflow = '...',
    bool skipEmpty = true,
  }) {
    if (list == null) return defaultValue;

    try {
      final List<dynamic> dynamicList = list is List ? list : [];
      
      final joined = dynamicList
          .where((item) => !skipEmpty || (item?.toString() ?? '').isNotEmpty)
          .map((item) => item?.toString() ?? '')
          .join(separator);

      if (joined.length <= maxLength) {
        return joined;
      }

      return '${joined.substring(0, maxLength)}$overflow';
    } catch (e) {
      print('StringUtils.joinWithLimit error: $e');
      return defaultValue;
    }
  }

  /// 安全地获取列表项的字符串值
  static String getListItemSafe(
    dynamic list,
    int index, {
    String defaultValue = '',
  }) {
    if (list == null || !(list is List) || index < 0 || index >= list.length) {
      return defaultValue;
    }
    return list[index]?.toString() ?? defaultValue;
  }

  /// 格式化显示
  static String formatDisplay(
    dynamic value, {
    String prefix = '',
    String suffix = '',
    String defaultValue = '',
    bool skipIfEmpty = true,
  }) {
    if (value == null) return defaultValue;
    
    final strValue = value.toString();
    if (strValue.isEmpty && skipIfEmpty) return defaultValue;
    
    return '$prefix$strValue$suffix';
  }
}