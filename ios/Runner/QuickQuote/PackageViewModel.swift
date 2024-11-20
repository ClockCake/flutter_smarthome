//
//  PackageViewModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/19.
//  全局使用 MVVM 数据驱动
 
import RxSwift
import RxRelay
class PackageViewModel: ViewModel {
    //套餐列表(整装，翻新通用)
    var packageList = BehaviorRelay<[PackageListModel]>(value: [])
    
    /// 报价明细(整装)
    var quickQuoteDetail = BehaviorRelay<QuickPriceRootModel?>(value: nil)
    var packageName = BehaviorRelay<String>(value: "")
    
    /// 报价明细(翻新)
    var MicroPriceDetail = BehaviorRelay<MicroPriceRootModel?>(value: nil)

    //软装风格列表
    var softDecorationStyleList = BehaviorRelay<[SoftDecorationStyleListModel]>(value: [])
    
    /// 套餐包列表
    /// - Parameter type: <#type description#>
    func fetchPackageList(type: String) {
        setLoading(true)
        request(.getPackageList(type: type))
            .subscribe(onSuccess: { [weak self] (packages: [PackageListModel]) in
                self?.packageList.accept(packages)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    /// 翻新套餐包
    /// - Parameter type: <#type description#>
    func fetchMicroPackageList(type:String) {
        setLoading(true)
        request(.getRenovationPackageList(type: type))
            .subscribe(onSuccess: { [weak self] (packages: [PackageListModel]) in
                self?.packageList.accept(packages)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    ///拉取软装风格
    func fetchSoftDecorationStyle(packageId: String,roomType:Int) {
        setLoading(true)
        request(.getSoftDecorationStyle(packageId: packageId, roomType: roomType))
            .subscribe(onSuccess: { [weak self] (styles: [SoftDecorationStyleListModel]) in
                self?.softDecorationStyleList.accept(styles)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            }).disposed(by: disposeBag)
    }
    
    /// 快速报价-整装
    /// - Parameter param: <#param description#>
    func fetchQuickQuoteDetail(param: [String: Any]) {
        setLoading(true)
        request(.getQuoteDetail(param: param))
            .subscribe(onSuccess: { [weak self] (rootModel: QuickPriceRootModel) in
                self?.quickQuoteDetail.accept(rootModel)
                self?.packageName.accept(rootModel.quickPriceResult.packageName)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    /// 快速报价-翻新
    func fetchQuickRenovationQuoteDetail(param: [String: Any]) {
        setLoading(true)
        request(.getMicroQuoteDetail(param: param))
            .subscribe(onSuccess: { [weak self] (rootModel: MicroPriceRootModel) in
                self?.MicroPriceDetail.accept(rootModel)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    ///快速报价-软装 和 翻新共用一套模型
    func fetchSoftQuoteDetail(param: [String: Any]) {
        setLoading(true)
        request(.getSoftQuoteDetail(param: param))
            .subscribe(onSuccess: { [weak self] (rootModel: MicroPriceRootModel) in
                self?.MicroPriceDetail.accept(rootModel)
                self?.packageName.accept(rootModel.quickPriceResult.packageName)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    
}
