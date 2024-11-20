//
//  CommonModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/14.
//  通用字典映射

import Foundation
struct CommonRootModel:Codable{
    let crm_room_type:[CommonModel]?
    let crm_decorate_type:[CommonModel]?
}
struct CommonModel:Codable {
    var id: String
    var label: String
    var value: String
}
