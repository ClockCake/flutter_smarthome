//
//  ContractModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/23.
//

import Foundation
///合同列表
struct ContractListModel:Codable {
    let contractId:String? //合同id
    
    let contractNo:String? //编号
    
    let contractType:String? //
    
    let contractTypeDisPlay:String? //合同名称
    
    let packageName:String? //套餐包名称

}


// 包含合同信息和支付列表的模型
struct ContractDataModel: Codable {
    let contractInfo: ContractInfoModel // 合同详情
    let payList: [ContractPayInfoModel]? // 支付信息列表
}
/// 合同详情
struct ContractInfoModel:Codable{
    let contractId: String? // 合同ID
    let contractNo: String? // 合同编号
    let contractType: String? // 合同类型代码
    let contractTypeDisPlay: String? // 合同类型显示名称
    let packageName: String? // 套餐名称
    let directPrice: Double? // 直接价格
    let managePrice: Double? // 管理费价格
    let taxPrice: Double? // 税费价格
    let discountPrice: Double? // 折扣价格
    let contractPrice: Double? // 合同总价
    let contractPic: [String]? // 合同图片URL列表
}
// 支付信息模型
struct ContractPayInfoModel: Codable {
    let id: String? // 支付信息ID
    let contractId: String? // 关联合同ID
    let type: String? // 支付类型
    let price: Double? // 支付金额
}




// 房间信息模型
struct ProjectCheckListModel: Codable {
    let packageRoomId: String? // 房间的ID
    let roomName: String? // 房间名称
    let landArea: Double? // 房间面积
    let rows: [ProjectCheckRowModel]? // 房间内的配额信息列表
}

// 房间内的配额信息模型
struct ProjectCheckRowModel: Codable {
    let materialName:String? //材料名
    let sku:String?  //
    let materialPic:String? //主材图
    let unit:String? //单位
    let number:Double? //数量
    let brandName:String? //品牌名
    
}
