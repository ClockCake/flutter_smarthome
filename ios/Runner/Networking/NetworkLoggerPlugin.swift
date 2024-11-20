//
//  NetworkLoggerPlugin.swift
//
//  Created by hyd on 2023/10/25.
//

import Moya
import RxSwift
import Foundation

public final class NetworkLoggerPlugin: PluginType {

    public func willSend(_ request: RequestType, target: TargetType) {
        print("Sending request:")
        print("URL: \(request.request?.url?.absoluteString ?? "")")
        print("Method: \(request.request?.httpMethod ?? "")")
        if let headers = request.request?.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.request?.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        print("Received response:")
        switch result {
        case .success(let response):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.withoutEscapingSlashes])
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("JSON: \(jsonString)")
                        }
                    }
                } catch {
                    print("Failed to parse JSON")
                }
        case .failure(let error):
            print("Error: \(error)")
        }
    }

}
