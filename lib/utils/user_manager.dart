import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// 创建一个通知器类来管理用户状态变化的监听
class UserChangeNotifier extends ChangeNotifier {
  static final UserChangeNotifier _instance = UserChangeNotifier._internal();
  
  factory UserChangeNotifier() {
    return _instance;
  }
  
  UserChangeNotifier._internal();
  
  void notifyUserChanged() {
    notifyListeners();
  }
}

class UserManager {
  // 私有构造函数
  UserManager._privateConstructor() {
    // 初始化通知器
    _notifier = UserChangeNotifier();
  }

  // 单例实例
  static final UserManager _instance = UserManager._privateConstructor();

  // 获取单例实例
  static UserManager get instance => _instance;

  // SharedPreferences 实例
  SharedPreferences? _prefs;

  // 存储用户信息的键
  static const String _userKey = 'user_key';

  // 当前用户信息
  UserModel? _user;

  // 状态通知器
  late final UserChangeNotifier _notifier;

  // 获取通知器实例，供外部监听使用
  UserChangeNotifier get notifier => _notifier;

  // 获取当前用户
  UserModel? get user => _user;

  // 获取登录状态
  bool get isLoggedIn => _user != null;

  // 初始化 SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadUser();
  }

  // 加载用户信息
  Future<void> loadUser() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    String? userJson = _prefs?.getString(_userKey);
    if (userJson != null) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        _user = UserModel.fromJson(userMap);
        _notifier.notifyUserChanged();
      } catch (e) {
        print('加载用户信息失败: $e');
        _user = null;
        _notifier.notifyUserChanged();
      }
    } else {
      _user = null;
      _notifier.notifyUserChanged();
    }
  }

  Future<void> saveUser(UserModel user) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    // 先清除旧数据
    await _prefs!.remove(_userKey);
    
    // 保存新数据
    String userJson = jsonEncode(user.toJson());
    bool success = await _prefs!.setString(_userKey, userJson);
    
    if (success) {
      _user = user;
      _notifier.notifyUserChanged();
      print('保存用户信息成功: $userJson'); // 添加日志
    } else {
      print('保存用户信息失败');
      // 保存失败时清除内存中的用户信息
      _user = null;
      _notifier.notifyUserChanged();
    }
  }

  Future<void> clearUser() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    // 清除所有相关数据
    await Future.wait([
      _prefs!.remove(_userKey),
      // 可以添加其他需要清除的数据
    ]);
    
    _user = null;
    _notifier.notifyUserChanged();
    print('用户信息已清除'); // 添加日志
  }
    // 更新用户信息
  Future<void> updateUser(Function(UserModel) updateFn) async {
    if (_user == null) {
      print('当前没有用户信息，无法更新');
      return;
    }
    updateFn(_user!);
    await saveUser(_user!);
    _notifier.notifyUserChanged();
  }
}