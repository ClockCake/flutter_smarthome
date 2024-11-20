//
//  PackageListModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/19.
//  套餐列表模型

import Foundation
///套餐列表 Model
class PackageListModel: Codable {
    var packageId: String
    var packageName: String
    var packagePic: String
    var basePrice: Double
    var areaNum:String?
    var isSelected:Bool?
    var name:String? //房间名称
    var index:Int?
    var type:DecorationType? //房间类型
    var style:QuickQuoteType? //装修方式
}
// 报价明细模型(整装)
struct QuickPriceRootModel:Codable {
    let quickPriceResult:QuickPriceResultModel
    let material:[MaterialModel]
}
struct QuickPriceResultModel: Codable {
    let packageId: String?       // 套餐包id
    let packageName:String      // 套餐名
    let actualPackageId: String // 实际套餐包id
    let totalPrice: Double      // 报价结果
    let mainPrice: Double       // 主材价
    let auxPrice: Double        // 辅材价
    let artificialPrice: Double // 人工价
    let mainProportion: Double  // 主材占比
    let auxProportion: Double   // 辅材占比
    let artificialProportion: Double // 人工占比
}

struct MaterialModel:Codable {
    let budgetDisplay:String
    let items:[MaterialItemModel]
}

struct MaterialItemModel:Codable {
    let budgetDisplay: String?      // 预算显示
    let materialName: String?        // 材料名称
    let quotaUsage: Double?            // 数量
    let skuPic: String?               // 图片
    let sku: String?                // 规格
    let brandName: String?          // 品牌名称

    
}


// 报价明细模型(微装)
class MicroPriceRootModel:Codable {
    let quickPriceResult:QuickPriceResultModel
    let material:[MicroMaterialListModel]?
}

class MicroMaterialListModel:Codable {
    let roomID, roomType, roomTypeDisplay: String?
    let landArea: Int?
    let respVos: [MicroRespVoModel]?
    
    enum CodingKeys: String, CodingKey {
        case roomType, roomTypeDisplay,landArea,respVos
        case roomID = "roomId"
    }
}


// MARK: - RespVo
class MicroRespVoModel: Codable {
    let budgetDisplay: String?
    let items: [MicroItemModel]?
    var type:QuickQuoteType?
}

// MARK: - Item
struct MicroItemModel: Codable {
    let budgetDisplay, materialName: String?
    let quotaUsage: Double?
    let skuPic, sku, brandName, roomID: String?

    enum CodingKeys: String, CodingKey {
        case budgetDisplay, materialName, quotaUsage, skuPic, sku, brandName
        case roomID = "roomId"
    }
}

/// 软装风格列表
class SoftDecorationStyleListModel:Codable {
    let dictLabel: String? //描述
    let dictValue: String? //风格值
    let pic:String? //图片
    var roomType:String? //房间类型的传值
    var isSelected:Bool? //是否被选中
    var index:Int? //索引
    
}
