//
//  DecorationTypeModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/24.
//

import Foundation
//枚举房间类型 (卧室，客厅，厨房，卫生间,墙面刷新)
enum DecorationType:Codable {
    case masterBedroom //卧室
    case livingDiningRoom //客厅
    case kitchen //厨房
    case masterBathroom //卫生间
    case wallRefresh //墙面刷新
    case restaurant //餐厅
    case add //添加
}

class DecorationTypeModel:Codable {
  
    var name: String //房间名称
    var icon: String //房间图标
    var type: DecorationType //房间类型
    var area: String //房间面积
    var number: Int //房间数量
    
    init(name: String, icon: String, type: DecorationType, area: String, number: Int) {
        self.name = name
        self.icon = icon
        self.type = type
        self.area = area
        self.number = number
    }
    // 深拷贝方法
     func deepCopy() -> DecorationTypeModel? {
         do {
             let data = try JSONEncoder().encode(self)
             let copy = try JSONDecoder().decode(DecorationTypeModel.self, from: data)
             return copy
         } catch {
             print("Failed to copy: \(error)")
             return nil
         }
     }
}
