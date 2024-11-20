//
//  CommonParametersPlugin.swift
//
//  Created by hyd on 2023/10/25.
//

import Moya
import Foundation

public struct CommonParametersPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        // 公共参数
        let commonParameters: [String: Any] = [:]
        

        do {
            if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false),
               var queryItems = urlComponents.queryItems {
                
                // 将公共参数添加到已有参数中
                for (key, value) in commonParameters {
                    let queryItem = URLQueryItem(name: key, value: "\(value)")
                    queryItems.append(queryItem)
                }

                urlComponents.queryItems = queryItems
                request.url = urlComponents.url
            } else {
                var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
                urlComponents?.queryItems = commonParameters.map {
                    URLQueryItem(name: $0, value: "\($1)")
                }
                request.url = urlComponents?.url
            }
        } catch {
            // 错误处理
        }

        return request
    }
}
