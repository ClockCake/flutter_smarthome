import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserChangeNotifier extends ChangeNotifier {
  static final UserChangeNotifier _instance = UserChangeNotifier._internal();
  factory UserChangeNotifier() => _instance;
  UserChangeNotifier._internal();
  
  void notifyUserChanged() {
    notifyListeners();
  }
}

class UserManagerException implements Exception {
  final String message;
  final dynamic cause;

  UserManagerException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'UserManagerException: $message\nCause: $cause';
    }
    return 'UserManagerException: $message';
  }
}

class UserManager {
  // 单例实现
  UserManager._privateConstructor() {
    _notifier = UserChangeNotifier();
    _setupMethodChannel();
  }
  static final UserManager _instance = UserManager._privateConstructor();
  static UserManager get instance => _instance;

  // 成员变量
  SharedPreferences? _prefs;
  UserModel? _user;
  late final UserChangeNotifier _notifier;
  static const String _userKey = 'user_key';
  bool _isSyncing = false;
  
  // Method Channel 设置
  static const _channel = MethodChannel('com.example.app/user');
  
  // Getters
  UserChangeNotifier get notifier => _notifier;
  UserModel? get user => _user;
  bool get isLoggedIn => _user?.accessToken?.isNotEmpty ?? false;

  // 设置 Method Channel 监听
  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'userUpdated':
            if (call.arguments != null) {
              _isSyncing = true;
              final userMap = Map<String, dynamic>.from(call.arguments);
              await saveUser(UserModel.fromJson(userMap));
              _isSyncing = false;
            }
            break;
          case 'userCleared':
            _isSyncing = true;
            await clearUser();
            _isSyncing = false;
            break;
        }
      } catch (e) {
        print('Error handling method call ${call.method}: $e');
        _isSyncing = false;
        rethrow;
      }
    });
  }

  // 初始化
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await loadUser();
      if (_user?.accessToken?.isNotEmpty ?? false) {
        await _syncToNative();
      }
    } catch (e) {
      throw UserManagerException('Failed to initialize UserManager', e);
    }
  }

  // 加载用户
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

  // 保存用户
  Future<void> saveUser(UserModel user) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    try {
      String userJson = jsonEncode(user.toJson());
      await _prefs!.setString(_userKey, userJson);
      _user = user;
      _notifier.notifyUserChanged();
      
      if (!_isSyncing) {
        await _syncToNative();
      }
      
      print('保存用户信息成功: $userJson');
    } catch (e) {
      print('保存用户信息失败: $e');
      _user = null;
      _notifier.notifyUserChanged();
      throw UserManagerException('Failed to save user', e);
    }
  }

  // 清除用户
  Future<void> clearUser() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    
    try {
      if (!_isSyncing) {
        await _channel.invokeMethod('clearUser');
      }
      await _prefs!.remove(_userKey);
      
      _user = null;
      _notifier.notifyUserChanged();
      print('用户信息已清除');
    } catch (e) {
      print('清除用户信息失败: $e');
      throw UserManagerException('Failed to clear user', e);
    }
  }

  // 更新用户
  Future<void> updateUser(void Function(UserModel) updateFn) async {
    if (_user == null) {
      throw UserManagerException('No user to update');
    }
    
    final updatedUser = UserModel.fromJson(_user!.toJson());
    updateFn(updatedUser);
    await saveUser(updatedUser);
  }

  // 同步到原生端
  Future<void> _syncToNative() async {
    try {
      _isSyncing = true;
      print('Syncing user to native: ${jsonEncode(_user?.toJson())}');
      final result = await _channel.invokeMethod('syncUser', _user?.toJson());
      print('Sync result: $result');
    } catch (e) {
      print('Error syncing to native: $e');
      throw UserManagerException('Failed to sync with native', e);
    } finally {
      _isSyncing = false;
    }
  }
}