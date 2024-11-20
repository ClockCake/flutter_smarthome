//
//  ProjectModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/29.
//

import Foundation

/// 我的家-项目列表
struct PropertyInfo: Codable {
    let projectId: String?            // 项目id
    let communityName: String?        // 小区名
    let bedroomNumber: Int?           // 卧室房间数
    let livingRoomNumber: Int?        // 客厅房间数
    let kitchenRoomNumber: Int?       // 厨房房间数
    let toiletRoomNumber: Int?        // 卫生间数
    let area: Double?                 // 面积
    let address: String?              // 客户地址
}
