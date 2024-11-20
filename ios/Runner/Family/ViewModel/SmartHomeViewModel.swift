//
//  SmartHomeViewModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/29.
//

import RxSwift
import RxRelay
class SmartHomeViewModel: ViewModel {
    var phone =  BehaviorRelay<String>(value: "")
    var projectListModel: BehaviorRelay<[PropertyInfo]> = BehaviorRelay(value: [])
    
    init(){
        super.init()
    }
    
    func fetchProjectList() {
        setLoading(true)
        request(.getProjectList(phone:self.phone.value))
            .subscribe(onSuccess: { [weak self] (model: [PropertyInfo]) in
                self?.projectListModel.accept(model)
                self?.setLoading(false)
            }, onFailure: { [weak self] error in
                self?.handleError(error)
                self?.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
}
