//
//  ViewModel.swift
//
//  Created by hyd on 2023/10/25.
//
import Moya
import RxSwift
import RxCocoa

protocol JSONDictionaryResponse {}
// 新增：定义一个通用的数组响应
struct CommonArrayResponse: JSONDictionaryResponse {
    let code: Int
    let msg: String
    let data: [[String: Any]]
}
// 新增：定义一个通用的字典响应
struct CommonMapResponse: JSONDictionaryResponse {
    let code: Int
    let msg: String
    let data: [String: Any]
}
enum APIError: Error {
    case parsingFailed(String)
    case dataFieldMissing
    case badCode(Int, String)
    case tokenExpired
    case unknownError(String)

    var errorMessage: String {
        switch self {
        case .parsingFailed(let message):
            return message
        case .dataFieldMissing:
            return "Data field is missing or null."
        case .badCode(_, let message):
            ProgressHUDManager.shared.showMessageOnWindow(message: message)
            return message  // 这里直接返回服务器的错误信息
        case .tokenExpired:
            return "Token has expired"
        case .unknownError(let message):
            return message
        }
    }
}

class ViewModel {
    // 添加一个新的协议来标记那些应该直接返回 JSON 的请求
    
    let commonParametersPlugin: CommonParametersPlugin
    let networkLogger = NetworkLoggerPlugin()
    var provider: MoyaProvider<BFFAPIService>
    let disposeBag = DisposeBag()
    
    // 新增：加载状态
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    // 新增：分页相关属性
    var pageNum: Int = 1
    var pageSize: Int = 10
    //token 失效
    let tokenExpiredSubject = PublishSubject<Void>()

    
    /// <#Description#>
    /// - Parameter timeoutInterval: <#timeoutInterval description#>
    init(timeoutInterval: TimeInterval = 10) {
        commonParametersPlugin = CommonParametersPlugin()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = Session(configuration: configuration)
        
        provider = MoyaProvider<BFFAPIService>(
            session: session, plugins: [commonParametersPlugin, networkLogger]
        )
        // 订阅 isLoading 以控制加载框的显示和隐藏
        isLoading
            .asDriver()
            .drive(onNext: { isLoading in
                if isLoading {
                    ProgressHUDManager.shared.showLoadingOnWindow()
                } else {
                    ProgressHUDManager.shared.hideHUDOnWindow()
                }
            })
            .disposed(by: disposeBag)
        
        tokenExpiredSubject
            .subscribe(onNext: { _ in
                UserManager.shared.handleLogoutOrTokenExpiration(isTokenExpired: true)
                // 通知 UI 层显示登录界面
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("ShowLoginScreen"), object: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 通用网络请求方法
    func request<T>(_ target: BFFAPIService) -> Single<T> {
        return provider.rx.request(target)
            .flatMap { response -> Single<T> in
                do {
                    if T.self is JSONDictionaryResponse.Type {
                        guard let jsonResponse = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
                            throw APIError.parsingFailed("Failed to parse JSON.")
                        }
                        
                        guard let code = jsonResponse["code"] as? Int else {
                            throw APIError.parsingFailed("Failed to parse 'code' field.")
                        }
                        
                        let message = jsonResponse["msg"] as? String ?? "Unknown error"
                        
                        switch code {
                        case 200:
                            if let data = jsonResponse["data"] as? [[String: Any]] {
                                return .just(CommonArrayResponse(code: code, msg: message, data: data) as! T)
                            }else if let data = jsonResponse["data"] as? [String: Any]
                            {
                                return .just(CommonMapResponse(code: code, msg: message, data: data) as! T)
                            }
                            else {
                                throw APIError.parsingFailed("Failed to parse 'data' field.")
                            }
                        case 401:
                            self.tokenExpiredSubject.onNext(())
                            throw APIError.tokenExpired
                        default:
                            throw APIError.badCode(code, message)
                        }
                    } else {
                        return .just(try self.mapDataField(from: response, type: T.self))
                    }
                } catch {
                    return .error(error)
                }
            }
    }

    
    // 错误处理方法
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            ProgressHUDManager.shared.hideHUDOnWindow()
            
            let errorMessage: String
            if let apiError = error as? APIError {
                errorMessage = apiError.errorMessage
            } else {
                errorMessage = error.localizedDescription
            }
            
            // 显示错误消息
            ProgressHUDManager.shared.showErrorOnWindow(message: errorMessage)
        }
    }
    
    // 新增：重置分页
    func resetPagination() {
        pageNum = 1
    }
    
    // 新增：增加页码
    func incrementPage() {
        pageNum += 1
    }
    
    // 新增：设置加载状态
    func setLoading(_ loading: Bool) {
        isLoading.accept(loading)
    }
}

extension ViewModel {
    /// Json 解析过滤
    /// - Parameters:
    ///   - response: <#response description#>
    ///   - type: <#type description#>
    /// - Returns: <#description#>
    func mapDataField<T>(from response: Response, type: T.Type) throws -> T {
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any] else {
            throw APIError.parsingFailed("Failed to parse JSON.")
        }
        
        // 解析返回结构体中的 code
        guard let code = jsonResponse["code"] as? Int else {
            throw APIError.parsingFailed("Failed to parse 'code' field.")
        }
        
        let message = jsonResponse["msg"] as? String ?? "Unknown error"
        
        // 处理不同的 code 情况
        switch code {
        case 200:
            // 成功情况，继续解析数据
            let dataField = jsonResponse["data"]
            // 处理 data 为 null 的情况，将其视为空字典
            let processedData: Any = dataField is NSNull ? [:] : (dataField ?? [:])
            
            if T.self is [String: Any].Type {
                if let dictResult = processedData as? [String: Any] {
                    return dictResult as! T
                } else {
                    throw APIError.parsingFailed("Failed to parse data field as dictionary.")
                }
            } else if let decodableType = T.self as? Decodable.Type {
                let jsonDecoder = DebuggingDecoder()
                let data = try JSONSerialization.data(withJSONObject: processedData, options: [])
                do {
                    return try jsonDecoder.decode(decodableType, from: data) as! T
                } catch {
                    print("Error decoding \(decodableType): \(error)")
                    throw error
                }
            } else {
                throw APIError.parsingFailed("Unsupported type: \(T.self)")
            }
            
        case 401:
            // Token 失效情况
            tokenExpiredSubject.onNext(())
            throw APIError.tokenExpired
            
        default:
            // 其他错误情况
            throw APIError.badCode(code, message)

        }
    }

}

// 新增：响应式扩展
extension Reactive where Base: ViewModel {
    var loading: Binder<Bool> {
        return Binder(base) { viewModel, isLoading in
            viewModel.setLoading(isLoading)
        }
    }
}
