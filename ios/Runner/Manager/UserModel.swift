//
//  UserModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/21.
//

import Foundation

// MARK: - UserModel
class UserModel: Codable {
    var mobile:String?  //手机号
    var password:String? //密码
    var nickname:String? //昵称
    var name:String? //姓名
    var sex:String? //性别 0：未知  1：男  2：女
    var avatar:String? //头像（https Url）
    var tuyaPwd:String? //涂鸦密码
    var terminalId:String? //终端 ID
    var accessToken:String? //鉴权
    var city:String? //城市
    var profile:String? //简介
    
}
