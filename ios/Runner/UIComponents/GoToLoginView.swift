//
//  GoToLoginView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/9/4.
//

import UIKit
import RxSwift
//去登录 提示页面
class GoToLoginView: UIView {
    private let disposeBag = DisposeBag()
    //去登录回调
    var goLoginBlock:(()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        let image = UIImageView(image: UIImage(named: "icon_gotologin"), contentMode: .scaleAspectFit, enableInteraction: false)
        self.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(66)
        }
        
        let label = UILabel.labelLayout(text: "登录后可查看", font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let goLoginBtn = UIButton.init(title: "登录", backgroundColor: .black, titleColor: .white, font: FontSizes.regular14, alignment: .center, image: nil)
        self.addSubview(goLoginBtn)
        goLoginBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(84)
            make.height.equalTo(36)
        }
        goLoginBtn.layer.borderWidth = 0.5
        goLoginBtn.layer.borderColor = AppColors.c_000000.cgColor
        goLoginBtn.layer.cornerRadius = 4
        goLoginBtn.layer.masksToBounds = true
        
    
        goLoginBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let callback = self?.goLoginBlock else { return  }
            callback()
            
        }).disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
