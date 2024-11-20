//
//  MeasurementDetailModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//

import Foundation
struct MeasurementDetailModel:Codable {
    let id:String? //公司id
    let roomType:String? //房间类型
    let roomTypeDisplay:String? //房间类型显示
    let landArea:Double? //土地面积
    let wallArea:Double? //墙面积
    let floorHeight:Double? //楼层高度
    let perimeter:Double? //周长
    
}
