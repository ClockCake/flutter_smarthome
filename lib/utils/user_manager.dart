import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart'; 

class UserManager {
  // 私有构造函数
  UserManager._privateConstructor();

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

  // 获取当前用户
  UserModel? get user => _user;

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
      } catch (e) {
        print('加载用户信息失败: $e');
        _user = null;
      }
    } else {
      _user = null;
    }
  }

  // 保存用户信息
  Future<void> saveUser(UserModel user) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    String userJson = jsonEncode(user.toJson());
    bool success = await _prefs!.setString(_userKey, userJson);
    if (success) {
      _user = user;
    } else {
      print('保存用户信息失败');
    }
  }

  // 更新用户信息
  Future<void> updateUser(Function(UserModel) updateFn) async {
    if (_user == null) {
      print('当前没有用户信息，无法更新');
      return;
    }
    updateFn(_user!);
    await saveUser(_user!);
  }

  // 清除用户信息
  Future<void> clearUser() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    bool success = await _prefs!.remove(_userKey);
    if (success) {
      _user = null;
    } else {
      print('清除用户信息失败');
    }
  }
}