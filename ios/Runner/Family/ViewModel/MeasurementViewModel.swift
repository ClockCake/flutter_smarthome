//
//  MeasurementViewModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//

import RxSwift
import RxRelay
class MeasurementViewModel: ViewModel {
    var projectId = BehaviorRelay<String>(value: "")
    var dataSource = BehaviorRelay<[MeasurementDetailModel]>(value: [])
    var submitSuccess = PublishSubject<Bool>()
    
    init(){
        super.init()
        setupBindings()
    }
    
    //获取量房参数
    func fetchMeasurementDetail(projectId:String) {
        setLoading(true)
        request(.getMeasurementParameter(customerProjectId: projectId))
            .subscribe(onSuccess: { [weak self] (model: [MeasurementDetailModel]) in
                self?.dataSource.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    //确认量房参数
    func postMeasurementDetail() {
        setLoading(true)
        request(.postMeasurementParameter(customerProjectId: projectId.value))
            .subscribe(onSuccess: { [weak self] (model: [String: Any]) in
                self?.submitSuccess.onNext(true)
                self?.setLoading(false)
                ProgressHUDManager.shared.showSuccessOnWindow(message: "成功确认")
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.submitSuccess.onNext(false)
                self?.setLoading(false)
                ProgressHUDManager.shared.showErrorOnWindow(message: "确认失败")

            })
            .disposed(by: disposeBag)
    }
    
    
    
}
extension MeasurementViewModel {
    ///数据流绑定
    private func setupBindings() {
        projectId
            .skip(1) // 跳过初始值
            .distinctUntilChanged() // 只有当值真正改变时才触发
            .subscribe(onNext: { [weak self] newId in
                self?.fetchMeasurementDetail(projectId: newId)
            })
            .disposed(by: disposeBag)
    }
}
