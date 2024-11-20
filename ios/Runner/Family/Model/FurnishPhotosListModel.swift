//
//  FurnishPhotosListModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//

import UIKit
///装修/设计方案
struct FurnishPhotosListModel: Codable {
    let type:String?
    let typeDisplay:String?
    let row:[FurnishPhotosUrlModel]?
}

struct FurnishPhotosUrlModel:Codable {
    let url:String?
    let title:String?
}



