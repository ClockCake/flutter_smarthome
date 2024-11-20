//
//  MeasureHeaderView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
import RxSwift
class MeasureHeaderView: UICollectionReusableView  {
    public var titlleLab:UILabel!
    public var arrowBtn:UIButton!
    var customerProjectId:String?
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let  titleLab = UILabel.labelLayout(text: "量房照", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        self.titlleLab = titleLab
        
        let arrowBtn = UIButton.init(title: "确认量房参数 >", backgroundColor: .white, titleColor: AppColors.c_999999, font: FontSizes.regular12, alignment: .right)
        self.addSubview(arrowBtn)
        arrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        self.arrowBtn = arrowBtn
        arrowBtn.rx.tap.withUnretained(self).subscribe(onNext: { owner, _ in
            let vc = MeasurementDetailController(projectId: owner.customerProjectId ?? "")
            UINavigationController.getCurrentNavigationController()?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
