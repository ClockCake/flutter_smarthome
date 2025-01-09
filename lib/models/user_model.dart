import 'dart:convert';

class UserModel {
  String? mobile;       // 手机号
  String? password;     // 密码
  String? nickname;     // 昵称
  String? name;         // 姓名
  String? sex;          // 性别 0：未知  1：男  2：女
  String? avatar;       // 头像（https Url）
  String? tuyaPwd;      // 涂鸦密码
  String? terminalId;   // 终端 ID
  String? accessToken;  // 鉴权
  String? refreshToken; // 刷新 Token
  String? city;         // 城市
  String? profile;      // 简介

  // 构造函数
  UserModel({
    this.mobile,
    this.password,
    this.nickname,
    this.name,
    this.sex,
    this.avatar,
    this.tuyaPwd,
    this.terminalId,
    this.accessToken,
    this.refreshToken,
    this.city,
    this.profile,
  });



  // 从 JSON 创建一个 UserModel 实例
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      mobile: json['mobile'] as String?,
      password: json['password'] as String?,
      nickname: json['nickname'] as String?,
      name: json['name'] as String?,
      sex: json['sex'] as String?,
      avatar: json['avatar'] as String?,
      tuyaPwd: json['tuyaPwd'] as String?,
      terminalId: json['terminalId'] as String?,
      accessToken: json['accessToken'] as String?,
      city: json['city'] as String?,
      profile: json['profile'] as String?,
    );
  }

  // 将 UserModel 实例转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'password': password,
      'nickname': nickname,
      'name': name,
      'sex': sex,
      'avatar': avatar,
      'tuyaPwd': tuyaPwd,
      'terminalId': terminalId,
      'accessToken': accessToken,
      'city': city,
      'profile': profile,
    };
  }

  // 方便打印调试
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}