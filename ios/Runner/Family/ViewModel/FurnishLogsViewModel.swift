//
//  FurnishLogsViewModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//

import RxSwift
import RxRelay
class FurnishLogsViewModel: ViewModel {
    /// 照片数据源
    var dataSource: BehaviorRelay<[FurnishPhotosListModel]> = BehaviorRelay(value: [])
    //请求参数
    var projectId = BehaviorRelay<String>(value: "")
    
    //合同列表
    var contractList = BehaviorRelay<[ContractListModel]>(value: [])
    
    ///合同详情
    var contractDetail = BehaviorRelay<ContractInfoModel?>(value: nil)
    
    /// 请求参数 合同 ID
    var contractId = BehaviorRelay<String>(value: "")
    
    ///  合同详情支付列表
    var contractPayList = BehaviorRelay<[ContractPayInfoModel]>(value: [])
    
    ///项目清单
    var projectContractId = BehaviorRelay<String>(value: "")
    var projectCheckList = BehaviorRelay<[ProjectCheckListModel]>(value: [])
    

    init(){
        super.init()
        setupBindings()
    }
    
    ///获取量房照
    func fetchFurnishLogsMeasurePhotos(projectId:String) {
        setLoading(true)
        request(.getLogsMeasurePhotos(customerProjectId: projectId))
            .subscribe(onSuccess: { [weak self] (model: [FurnishPhotosListModel]) in
                self?.dataSource.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    //获取设计照片
    func fetchFurnishLogsDesignPhotos(projectId:String) {
        setLoading(true)
        request(.getLogsDesignerPhotos(customerProjectId: projectId))
            .subscribe(onSuccess: { [weak self] (model: [FurnishPhotosListModel]) in
                self?.dataSource.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    //获取合同列表
    func fetchContractList(projectId:String) {
        setLoading(true)
        request(.getContractList(customerProjectId: projectId))
            .subscribe(onSuccess: { [weak self] (model: [ContractListModel]) in
                self?.contractList.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    //获取合同详情
    func fetchContractDetail(contractId:String) {
        setLoading(true)
        request(.getContractDetail(contractId: contractId))
            .subscribe(onSuccess: { [weak self] (model: ContractDataModel) in
                self?.contractDetail.accept(model.contractInfo)
                self?.contractPayList.accept(model.payList ?? [])
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    ///获取项目清单
    func fetchProjectCheckList(contractId:String) {
        setLoading(true)
        request(.getProjectCheckList(contractId: contractId))
            .subscribe(onSuccess: { [weak self] (model: [ProjectCheckListModel]) in
                self?.projectCheckList.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
}


extension FurnishLogsViewModel{
    ///数据流绑定
    private func setupBindings() {
        ///合同详情
        contractId
            .skip(1) // 跳过初始值
            .distinctUntilChanged() // 只有当值真正改变时才触发
            .subscribe(onNext: { [weak self] newId in
                self?.fetchContractDetail(contractId: newId)
            })
            .disposed(by: disposeBag)
        
        ///项目清单
        projectContractId
            .skip(1) // 跳过初始值
            .distinctUntilChanged() // 只有当值真正改变时才触发
            .subscribe(onNext: { [weak self] newId in
                self?.fetchProjectCheckList(contractId:newId)
            })
            .disposed(by: disposeBag)
    }
}
