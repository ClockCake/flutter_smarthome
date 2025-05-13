//
//  APIService.swift
//
//  Created by hyd on 2023/10/25.
//


import Moya

enum APIService {
    //字典数据查询
    case getDictionaryData(path:String)
    ///获取验证码
    case getVerificationCode(mobile:String)
    ///手机密码登录
    case loginViaPassword(mobile:String,password:String)
    /// 验证码登录
    case loginViaCode(mobile:String,code:String)

    /// 退出登录
    case logout
    ///获取套餐列表
    case getPackageList(type:String)
    ///获取微装套餐包列表
    case getRenovationPackageList(type:String)
    ///软装风格列表
    case getSoftDecorationStyle(packageId:String,roomType:Int)
    ///报价明细(整装)
    case getQuoteDetail(param: [String: Any])
    ///报价明细(微装)
    case getMicroQuoteDetail(param: [String: Any])
    /// 报价明细(软装)
    case getSoftQuoteDetail(param: [String: Any])
    /// 设计师列表
    case getDesignerList(pageNum:Int,pageSize:Int)
    ///设计师个人信息部分
    case getDesignerInfo(userId:String)
    ///设计师案例信息部分
    case getCaseInfo(userId:String)
    /// 设计师动态信息部分
    case getDynamicInfo(userId:String)
    ///推荐案例
    case getRecommendCase(pageNum:Int,pageSize:Int)
    ///装修榜单案例列表
    case getRankCaseList(pageNum:Int,pageSize:Int)
    ///案例详情
    case getCaseDetail(caseId:String)
    ///点赞
    case likeCase(businessType:String,businessId:String)
    ///个人信息
    case getUserInfo
    ///历史活动
    case getHistoryActivity(pageNum: Int, pageSize: Int)
    ///当前活动(不分页)
    case getCurrentActivity
    ///活动详情
    case getActivityDetail(activityId: String)
    ///资讯分类列表
    case getInformationCategoryList
    ///热门资讯
    case getHotInformationList(pageNum:Int,pageSize:Int)
    ///资讯详情
    case getInformationDetail(articleId:String)
    ///获取区域
    case getArea(areaId:String)
    ///装修表单
    case postDecorationForm(param: [String: Any])
    ///装修记录
    case getDecorationRecord
    ///快速预约
    case quickReservation(param: [String: Any])
    ///首页-招标数据
    case getBiddingData
    //量房参数
    case getMeasurementParameter(customerProjectId:String)
    //确认量房参数
    case postMeasurementParameter(customerProjectId:String)
    //量房照
    case getLogsMeasurePhotos(customerProjectId:String)
    //设计照
    case getLogsDesignerPhotos(customerProjectId:String)
    ///合同列表
    case getContractList(customerProjectId:String)
    ///合同详情
    case getContractDetail(contractId:String)
    ///项目清单
    case getProjectCheckList(contractId:String)
    ///项目列表
    case getProjectList(phone:String)
    //首页 Banner 临时
    case getBanner
    
    /* 个人中心 */
    
    //获取用户收藏商品信息
    case getCollectionGoods(pageNum:Int,pageSize:Int)
    //获取用户收藏案例信息
    case getCollectionCase(pageNum:Int,pageSize:Int)
    //获取用户收藏活动信息
    case getCollectionActivity(pageNum:Int,pageSize:Int)
    //获取用户点赞案例信息
    case getPraiseCase(pageNum:Int,pageSize:Int)
    //获取用户点赞活动信息
    case getPraiseActivity(pageNum:Int,pageSize:Int)
    //获取用户点赞资讯信息
    case getPraiseInformation(pageNum:Int,pageSize:Int)
    /// 修改个人信息
    case updateUserInfo(param: [String: Any])
    // 上传用户头像
    case uploadAvatar(UIImage, fileName: String)
    //在建工地数量
    case getUnderConstructionCount
    //工地列表
    case getConstructionList(pageNo:Int,pageSize:Int)
    //工地直播URL
    case getConstructionLiveUrl(projectId:String)
    //是否可以预约
    case getCanReservation(projectId:String)

}

extension APIService: TargetType {
    //API 基础地址
    var baseURL: URL {
      //  let baseUrl = "http://192.168.130.13/dev-api/bdj"  //本地
      //  let baseUrl = "https://mock.iweekly.top"    // Mock
      //  let baseUrl = "http://erf.gazo.net.cn:8087/test-api" //测试
      //  let baseUrl = "https://erf.zglife.com.cn/prod-api" //生产
        
        let baseUrl = UserDefaults.standard.string(forKey: "CurrentBaseUrl") ?? "http://erf.gazo.net.cn:8087/test-api"
        return URL(string: baseUrl)!
    }
    
    var path: String {
        switch self {
            case .getDictionaryData(path: let path):
                return "/system/dict/data/types/\(path)"
            case .getVerificationCode:
                return "/message/sms/send/securityCode"
            case .updateUserInfo:
                return "/product/customer/memberUser"
            case .getPackageList(let path):
                return "/scm/customer/package/huiApp/noAuth/package/list\(path)"
            case .getRenovationPackageList:
                return "/scm/customer/package/huiApp/noAuth/micro/package/list"
            case .getSoftDecorationStyle:
                return "/scm/customer/packageQuota/huiApp/noAuth/soft/suitableCase"
            case .getQuoteDetail:
                return "/scm/customer/budget/huiApp/noAuth/quick/price"
            case .getMicroQuoteDetail:
                return "/scm/customer/budget/huiApp/noAuth/micro/quick/price"
            case .getSoftQuoteDetail:
                return "/scm/customer/budget/huiApp/noAuth/soft/quick/price"
            case .loginViaPassword:
                return "/auth/member/login"
            case .loginViaCode:
                return "/auth/member/sms/login"
            case .logout:
                return "/auth/member/logout"
            case .getDesignerList:
                return "/product/customer/gazoHui/designerInfo/found/page"
            case .getDesignerInfo:
                return "/product/customer/gazoHui/designerInfo"
            case .getCaseInfo:
                return "/product/customer/gazoHui/designerCase/designerInfo/page"
            case .getDynamicInfo:
                return "/product/customer/gazoHui/designerDynamic/designerInfo/page"
            case .getRecommendCase:
                return "/product/customer/gazoHui/resourcesRecommend/page"
            case .getRankCaseList:
                return "/product/customer/gazoHui/designerCase/found/page"
            case .getCaseDetail:
                return "/product/customer/gazoHui/designerCase/info"
            case .getUserInfo:
                return "/product/customer/memberUser/getInfo"
            case .likeCase:
                return "/product/userSynthesisBehavior/addLike"
            case .getHistoryActivity:
                return "/product/customer/gazoHui/activity/history"
            case .getCurrentActivity:
                return "/product/customer/gazoHui/activity/now"
            case .getActivityDetail:
                return "/product/customer/gazoHui/activity/info"
            case .getInformationCategoryList:
                return "/product/customer/gazoHui/article/resourcesGroupList"
            case .getHotInformationList:
                return "/product/customer/gazoHui/article/hot"
            case .getInformationDetail:
                return "/product/customer/gazoHui/article/info"
            case .getArea:
                return "/system/place/placeList"
            case .postDecorationForm:
                return "/crm/customer/decorationResource/huiApp/add"
            case .getDecorationRecord:
                return "/crm/customer/decorationResource/huiApp/list"
            case .quickReservation:
                return "/product/customer/gazoHui/appointment"
            case .getBiddingData:
                return "/crm/customer/decorationResource/huiApp/noAuth/home"
            case .getMeasurementParameter:
                return "/crm/customer/room/measure/huiApp/list"
            case .postMeasurementParameter:
                return "/crm/customer/room/measure/huiApp/confirm"
            case .getLogsMeasurePhotos:
                return "/scm/customer/drawing/huiApp/measureRoom/list"
            case .getLogsDesignerPhotos:
                return "/scm/customer/drawing/huiApp/design/list"
            case .getContractList:
                return "/scm/customer/contract/huiApp/list"
            case .getContractDetail:
                return "/scm/customer/contract/huiApp/info"
            case .getProjectCheckList:
                return "/scm/customer/packageQuota/huiApp/item/list"
            case .getProjectList:
                return "/crm/customer/project/huiApp/list"
            case .getBanner:
                return "/scm/customer/package/huiApp/noAuth/temp/banner"
            case .getCollectionGoods:
                return "/product/customer/gazoHui/userSynthesisBehavior/commodityCollectionPage"
            case .getCollectionCase:
                return "/product/customer/gazoHui/userSynthesisBehavior/designerCaseCollectionPage"
            case .getCollectionActivity:
                return "/product/customer/gazoHui/userSynthesisBehavior/activityCollectionPage"
            case .getPraiseCase:
                return "/product/customer/gazoHui/userSynthesisBehavior/designerCaseLikePage"
            case .getPraiseActivity:
                return "/product/customer/gazoHui/userSynthesisBehavior/activityLikePage"
            case .getPraiseInformation:
                return "/product/customer/gazoHui/userSynthesisBehavior/articleLikePage"
            case .getUnderConstructionCount:
                return "/product/c/getConstructionSite/count"
            case .getConstructionList:
                return "/product/c/getConstructionSite/list"
            case .getConstructionLiveUrl:
                return "/product/c/getConstructionSite/live"
            case .getCanReservation(projectId: let path):
                return "product/sys/selectSysUserBehaviorAppointmentById/\(path)"
            case .uploadAvatar:
                return "/file/upload/oss"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getQuoteDetail,
             .getMicroQuoteDetail,
             .getSoftQuoteDetail,
             .loginViaCode,
             .likeCase,
             .postDecorationForm,
             .quickReservation,
             .postMeasurementParameter,
             .getConstructionList,
             .getConstructionLiveUrl,
             .uploadAvatar,
             .loginViaPassword:
            return .post
        case .logout:
            return .delete
        case .updateUserInfo:
            return .put
        default:
            return .get
                
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
            case .getDictionaryData:
                return .requestPlain
            case let .getVerificationCode(mobile: mobile):
                params["phone"] = mobile
                params["type"] = 1
            case .getPackageList:
                return .requestPlain
            case let .getRenovationPackageList(type: type):
                params["roomType"] = type
            case let .getSoftDecorationStyle(packageId: packageId, roomType: roomType):
                params["packageId"] = packageId
                params["roomType"] = roomType
            case .getQuoteDetail(param: let param):
                params = param
            case .getMicroQuoteDetail(param: let param):
                params = param
            case .getSoftQuoteDetail(param: let param):
                params = param
            case let .loginViaPassword(mobile:mobile, password:password):
                params["mobile"] = mobile
                params["password"] = password
            case let .loginViaCode(mobile:mobile, code:code):
                params["mobile"] = mobile
                params["code"] = code
            case let .getDesignerList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getDesignerInfo(userId: userId):
                params["userId"] = userId
            case let .getCaseInfo(userId: userId):
                params["userId"] = userId
            case let .getDynamicInfo(userId: userId):
                params["userId"] = userId
            case let .getRecommendCase(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getRankCaseList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getCaseDetail(caseId: caseId):
                params["id"] = caseId
            case .getUserInfo:
                return .requestPlain
            case let .likeCase(businessType: businessType, businessId: businessId):
                params["businessType"] = businessType
                params["businessId"] = businessId
            case let .getHistoryActivity(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCurrentActivity:
                return .requestPlain
            case let .getActivityDetail(activityId: activityId):
                params["id"] = activityId
            case .getInformationCategoryList:
                return .requestPlain
            case let .getHotInformationList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getInformationDetail(articleId: articleId):
                params["id"] = articleId
            case let .getArea(areaId: areaId):
                params["parentId"] = areaId
            case .postDecorationForm(param: let param):
                params = param
            case .getDecorationRecord:
                return .requestPlain
            case .quickReservation(param: let param):
                params = param
            case .getBiddingData:
                return .requestPlain
            case .logout:
                return .requestPlain
            case let .getMeasurementParameter(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .postMeasurementParameter(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getLogsMeasurePhotos(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getLogsDesignerPhotos(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getContractList(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getContractDetail(contractId: contractId):
                params["contractId"] = contractId
            case let .getProjectCheckList(contractId: contractId):
                params["contractId"] = contractId
            case let .getProjectList(phone: phone):
                params["phone"] = phone
            case .getBanner:
                return .requestPlain
            case .getCollectionGoods(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCollectionCase(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCollectionActivity(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseCase(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseActivity(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseInformation(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getUnderConstructionCount:
                return .requestPlain
            case .getConstructionList(pageNo: let pageNo, pageSize: let pageSize):
                params["pageNo"] = pageNo
                params["pageSize"] = pageSize
            case .getConstructionLiveUrl(projectId: let projectId):
                params["projectId"] = projectId
            case .getCanReservation:
                return .requestPlain
            case .updateUserInfo(param: let param):
                params = param
            
            case let .uploadAvatar (image, fileName):
                let imageData = image.jpegData(compressionQuality: 0.6)!
                let formData: [MultipartFormData] = [
                    MultipartFormData(provider: .data(imageData), name: "file", fileName: fileName, mimeType: "image/jpeg")
                ]
                return .uploadMultipart(formData)
        }
        
        
        switch self.method {
        case .post:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .get:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        // 公共参数
        switch self {
            case .uploadAvatar:
                return ["Content-Type": "multipart/form-data",
                        "TerminalId":"ce5c98bea83e4d3289f3fc5f25c445a6",
                        "Authorization":UserManager.shared.accessToken ?? ""
                       ]
            default:
                return ["Content-Type": "application/json",
                        "TerminalId":"ce5c98bea83e4d3289f3fc5f25c445a6",
                        "Authorization":UserManager.shared.accessToken ?? ""
                        
                       ]
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}


enum BFFAPIService {
    //字典数据查询
    case getDictionaryData(path:String)
    //获取首页 segment
    case getHomeSegment
    ///获取验证码
    case getVerificationCode(mobile:String)
    ///手机密码登录
    case loginViaPassword(mobile:String,password:String)
    /// 验证码登录
    case loginViaCode(mobile:String,code:String)

    /// 退出登录
    case logout
    ///获取套餐列表
    case getPackageList(type:String)
    ///获取微装套餐包列表
    case getRenovationPackageList(type:String)
    ///软装风格列表
    case getSoftDecorationStyle(packageId:String,roomType:Int)
    ///报价明细(整装)
    case getQuoteDetail(param: [String: Any])
    ///报价明细(微装)
    case getMicroQuoteDetail(param: [String: Any])
    /// 报价明细(软装)
    case getSoftQuoteDetail(param: [String: Any])
    /// 设计师列表
    case getDesignerList(pageNum:Int,pageSize:Int)
    ///设计师个人信息部分
    case getDesignerInfo(userId:String)
    ///设计师案例信息部分
    case getCaseInfo(userId:String)
    /// 设计师动态信息部分
    case getDynamicInfo(userId:String)
    ///推荐案例
    case getRecommendCase(pageNum:Int,pageSize:Int)
    ///装修榜单案例列表
    case getRankCaseList(pageNum:Int,pageSize:Int)
    ///案例详情
    case getCaseDetail(caseId:String)
    ///历史活动
    case getHistoryActivity(pageNum: Int, pageSize: Int)
    ///当前活动(不分页)
    case getCurrentActivity
    ///活动详情
    case getActivityDetail(activityId: String)
    ///资讯分类列表
    case getInformationCategoryList
    ///热门资讯
    case getHotInformationList(pageNum:Int,pageSize:Int)
    ///资讯详情
    case getInformationDetail(articleId:String)
    ///获取区域
    case getArea(areaId:String)
    ///装修表单
    case postDecorationForm(param: [String: Any])
    ///装修记录
    case getDecorationRecord
    ///快速预约
    case quickReservation(param: [String: Any])
    ///首页-招标数据
    case getBiddingData
    //量房参数
    case getMeasurementParameter(customerProjectId:String)
    //确认量房参数
    case postMeasurementParameter(customerProjectId:String)
    //量房照
    case getLogsMeasurePhotos(customerProjectId:String)
    //设计照
    case getLogsDesignerPhotos(customerProjectId:String)
    ///合同列表
    case getContractList(customerProjectId:String)
    ///合同详情
    case getContractDetail(contractId:String)
    ///项目清单
    case getProjectCheckList(contractId:String)
    ///项目列表
    case getProjectList(phone:String)
    //首页 Banner 临时
    case getBanner
    
    /* 个人中心 */
    
    //获取用户收藏商品信息
    case getCollectionGoods(pageNum:Int,pageSize:Int)
    //获取用户收藏案例信息
    case getCollectionCase(pageNum:Int,pageSize:Int)
    //获取用户收藏活动信息
    case getCollectionActivity(pageNum:Int,pageSize:Int)
    //获取用户点赞案例信息
    case getPraiseCase(pageNum:Int,pageSize:Int)
    //获取用户点赞活动信息
    case getPraiseActivity(pageNum:Int,pageSize:Int)
    //获取用户点赞资讯信息
    case getPraiseInformation(pageNum:Int,pageSize:Int)
    /// 修改个人信息
    case updateUserInfo(param: [String: Any])
    // 上传用户头像
    case uploadAvatar(UIImage, fileName: String)
    //在建工地数量
    case getUnderConstructionCount
    //工地列表
    case getConstructionList(pageNo:Int,pageSize:Int)
    //工地直播URL
    case getConstructionLiveUrl(projectId:String)
    //是否可以预约
    case getCanReservation(projectId:String)
    
    
    //购物中心
    case shoppingHome(categoryId:String)  //首页
    case shoppingCategory  //商品品类
    case shoppingPageList(param: [String: Any])  //商品列表
    case shoppingDetail(commodityId:String)     //商品详情
    case shoppingProperty(commodityId:String)  //商品属性
    case shoppingSkuList(commodityId:String,commodityPropertyId:[String])     //商品SKU

}


extension BFFAPIService: TargetType {
    //API 基础地址
    var baseURL: URL {
  //      let baseUrl = "http://192.168.201.21:6380"  //本地
   //     let baseUrl = "http://erf.gazo.net.cn:6380" //测试
      let baseUrl = "https://api.gazolife.cn" //生产
        return URL(string: baseUrl)!
    }
    
    var path: String {
        switch self {
            case .getHomeSegment:
                return "/api/home/segments"
            case .getDictionaryData(path: let path):
                return "/api/home/dict/\(path)"
            case .getVerificationCode:
                return "/api/login/verification/code"
            case .updateUserInfo:
                return "/api/personal/edit/info"
            case .getPackageList(let path):
                return "/api/valuation/packages/\(path)"
            case .getRenovationPackageList:
                return "/api/valuation/packages/micro"
            case .getSoftDecorationStyle:
                return "/api/valuation/packages/soft"
            case .getQuoteDetail:
                return "/api/valuation/quick/quote/whole"
            case .getMicroQuoteDetail:
                return "/api/valuation/quick/quote/micro"
            case .getSoftQuoteDetail:
                return "/api/valuation/quick/quote/soft"
            case .loginViaPassword:
                return "/api/login/via-password"
            case .loginViaCode:
                return "/api/login/via-code"
            case .logout:
                return "/api/login/logout"
            case .getDesignerList:
                return "/api/designer/list"
            case .getDesignerInfo:
                return "/api/designer/profile"
            case .getCaseInfo:
                return "/api/designer/cases"
            case .getDynamicInfo:
                return "/api/designer/dynamic"
            case .getRecommendCase:
                return "/api/home/recommend/case"
            case .getRankCaseList:
                return "/api/cases/list"
            case .getCaseDetail:
                return "/api/cases/detail"
            case .getHistoryActivity:
                return "/api/activity/history"
            case .getCurrentActivity:
                return "/api/activity/current"
            case .getActivityDetail:
                return "/api/activity/detail"
            case .getInformationCategoryList:
                return "/api/article/category/list"
            case .getHotInformationList:
                return "/api/article/hot/list"
            case .getInformationDetail:
                return "/api/article/detail"
            case .getArea:
                return "/api/home/furnish/area"
            case .postDecorationForm:
                return "/api/home/furnish/submit"
            case .getDecorationRecord:
                return "/api/home/furnish/record"
            case .quickReservation:
                return "/api/home/overall/quick/appointment"
            case .getBiddingData:
                return "/api/home/tender"
            case .getMeasurementParameter:
                return "/api/furnish/logs/estimate/params"
            case .postMeasurementParameter:
                return "/api/furnish/logs/estimate/submit"
            case .getLogsMeasurePhotos:
                return "/api/furnish/logs/estimate/photos"
            case .getLogsDesignerPhotos:
                return "/api/furnish/logs/design/photos"
            case .getContractList:
                return "/api/furnish/logs/contract/list"
            case .getContractDetail:
                return "/api/furnish/logs/contract/detail"
            case .getProjectCheckList:
                return "/api/furnish/logs/project/list"
            case .getProjectList:
                return "/api/furnish/logs/project/list"
            case .getBanner:
                return "/api/home/banner"
            case .getCollectionGoods:
                return "/api/personal/collection/goods"
            case .getCollectionCase:
                return "/api/personal/collection/case"
            case .getCollectionActivity:
                return "/api/personal/collection/activity"
            case .getPraiseCase:
                return "/api/personal/like/case"
            case .getPraiseActivity:
                return "/api/personal/like/activity"
            case .getPraiseInformation:
                return "/api/personal/like/article"
            case .getUnderConstructionCount:
                return "/api/construction/count"
            case .getConstructionList:
                return "/api/construction/list"
            case .getConstructionLiveUrl:
                return "/api/construction/live"
            case .getCanReservation(projectId: let path):
                return "product/sys/selectSysUserBehaviorAppointmentById/\(path)"
            case .uploadAvatar:
                return "/api/personal/file/upload/oss"
            
            //购物中心
            case .shoppingHome:
                return "/api/shopping/home"
            case .shoppingCategory:
                return "/api/shopping/category"
            case .shoppingPageList:
                return "/api/shopping/commodity/list"
            case .shoppingDetail:
                return "/api/shopping/commodity/detail"
            case .shoppingProperty:
                return "/api/shopping/commodity/property"
            case .shoppingSkuList:
                return "/api/shopping/commodity/skuGroup"
            
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getQuoteDetail,
             .getVerificationCode,
             .getMicroQuoteDetail,
             .getSoftQuoteDetail,
             .loginViaCode,
             .postDecorationForm,
             .quickReservation,
             .postMeasurementParameter,
             .getConstructionList,
             .getConstructionLiveUrl,
             .uploadAvatar,
             .loginViaPassword:
            return .post
        case .logout:
            return .delete
        case .updateUserInfo:
            return .put
        default:
            return .get
                
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
            case .getDictionaryData:
                return .requestPlain
            case .getHomeSegment:
                return .requestPlain
            case let .getVerificationCode(mobile: mobile):
                params["phone"] = mobile
                params["type"] = 1
            case .getPackageList:
                return .requestPlain
            case let .getRenovationPackageList(type: type):
                params["roomType"] = type
            case let .getSoftDecorationStyle(packageId: packageId, roomType: roomType):
                params["packageId"] = packageId
                params["roomType"] = roomType
            case .getQuoteDetail(param: let param):
                params = param
            case .getMicroQuoteDetail(param: let param):
                params = param
            case .getSoftQuoteDetail(param: let param):
                params = param
            case let .loginViaPassword(mobile:mobile, password:password):
                params["mobile"] = mobile
                params["password"] = password
            case let .loginViaCode(mobile:mobile, code:code):
                params["mobile"] = mobile
                params["code"] = code
            case let .getDesignerList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getDesignerInfo(userId: userId):
                params["userId"] = userId
            case let .getCaseInfo(userId: userId):
                params["userId"] = userId
            case let .getDynamicInfo(userId: userId):
                params["userId"] = userId
            case let .getRecommendCase(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getRankCaseList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getCaseDetail(caseId: caseId):
                params["id"] = caseId
            case let .getHistoryActivity(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCurrentActivity:
                return .requestPlain
            case let .getActivityDetail(activityId: activityId):
                params["id"] = activityId
            case .getInformationCategoryList:
                return .requestPlain
            case let .getHotInformationList(pageNum: pageNum, pageSize: pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case let .getInformationDetail(articleId: articleId):
                params["id"] = articleId
            case let .getArea(areaId: areaId):
                params["parentId"] = areaId
            case .postDecorationForm(param: let param):
                params = param
            case .getDecorationRecord:
                return .requestPlain
            case .quickReservation(param: let param):
                params = param
            case .getBiddingData:
                return .requestPlain
            case .logout:
                return .requestPlain
            case let .getMeasurementParameter(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .postMeasurementParameter(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getLogsMeasurePhotos(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getLogsDesignerPhotos(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getContractList(customerProjectId: projectId):
                params["customerProjectId"] = projectId
            case let .getContractDetail(contractId: contractId):
                params["contractId"] = contractId
            case let .getProjectCheckList(contractId: contractId):
                params["contractId"] = contractId
            case let .getProjectList(phone: phone):
                params["phone"] = phone
            case .getBanner:
                return .requestPlain
            case .getCollectionGoods(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCollectionCase(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getCollectionActivity(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseCase(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseActivity(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getPraiseInformation(pageNum: let pageNum, pageSize: let pageSize):
                params["pageNum"] = pageNum
                params["pageSize"] = pageSize
            case .getUnderConstructionCount:
                return .requestPlain
            case .getConstructionList(pageNo: let pageNo, pageSize: let pageSize):
                params["pageNo"] = pageNo
                params["pageSize"] = pageSize
            case .getConstructionLiveUrl(projectId: let projectId):
                params["projectId"] = projectId
            case .getCanReservation:
                return .requestPlain
            case .updateUserInfo(param: let param):
                params = param
            case .shoppingHome(categoryId: let categoryId):
                params["categoryId"] = categoryId
            case .shoppingCategory:
                return .requestPlain
            case .shoppingPageList(param: let param):
                params = param
            case .shoppingDetail(commodityId: let commodityId):
                params["commodityId"] = commodityId
            case .shoppingProperty(commodityId: let commodityId):
                params["commodityId"] = commodityId
            case .shoppingSkuList(commodityId: let commodityId, commodityPropertyId: let commodityPropertyId):
                params["commodityId"] = commodityId
                params["commodityPropertyId"] = commodityPropertyId
            
            
            
            case let .uploadAvatar (image, fileName):
                let imageData = image.jpegData(compressionQuality: 0.6)!
                let formData: [MultipartFormData] = [
                    MultipartFormData(provider: .data(imageData), name: "file", fileName: fileName, mimeType: "image/jpeg")
                ]
                return .uploadMultipart(formData)
        }
        
        
        switch self.method {
        case .post:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .get:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        // 公共参数
        switch self {
            case .uploadAvatar:
                return ["Content-Type": "multipart/form-data",
                        "TerminalId":"ce5c98bea83e4d3289f3fc5f25c445a6",
                        "Authorization":UserManager.shared.accessToken ?? ""
                       ]
            default:
                return ["Content-Type": "application/json",
                        "TerminalId":"ce5c98bea83e4d3289f3fc5f25c445a6",
                        "Authorization":UserManager.shared.accessToken ?? ""
                        
                       ]
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}
