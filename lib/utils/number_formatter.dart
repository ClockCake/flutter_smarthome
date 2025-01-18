class NumberFormatter {
  /// 移除数字末尾的0
  /// 可以处理int和double类型的数字
  /// 例如: 
  /// - 1.0 -> 1
  /// - 1.50 -> 1.5
  /// - 1.0000 -> 1
  /// - 42 -> 42
  /// - 42.0 -> 42
  static String removeTrailingZeros(num number) {
    // 将数字转为字符串，避免科学计数法
    String numStr = number.toString();
    
    // 如果不包含小数点，直接返回
    if (!numStr.contains('.')) {
      return numStr;
    }
    
    // 移除末尾的0
    while (numStr.endsWith('0')) {
      numStr = numStr.substring(0, numStr.length - 1);
    }
    
    // 如果末尾是小数点，移除小数点
    if (numStr.endsWith('.')) {
      numStr = numStr.substring(0, numStr.length - 1);
    }
    
    return numStr;
  }
}