//
//  FurnishViewModel.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/14.
//

import RxSwift
import RxRelay
class FurnishViewModel: ViewModel {

    ///  提交是否成功
    var submitSuccess = BehaviorRelay<Bool>(value: false)

    ///全局快速预约
    public func fetchQuickReservation(params:[String:Any]) {
        setLoading(true)
        request(.quickReservation(param: params))
            .subscribe(onSuccess: { [weak self] (dataField: [String: Any]) in
                guard let self = self else { return  }
                self.submitSuccess.accept(true)
                self.setLoading(false)
                ProgressHUDManager.shared.showSuccessOnWindow(message: "预约成功")
            }, onFailure: { [weak self] error in
                guard let self = self else { return  }
                self.submitSuccess.accept(false)
                self.handleError(error)
                self.setLoading(false)
            })
            .disposed(by: disposeBag)
    }
    
    
}
