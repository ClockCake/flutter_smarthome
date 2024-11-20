//
//  BlankCanvasView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/10.
//  缺省页

import UIKit
import RxSwift
//标准的空白页
class BlankCanvasView: UIView {
    //点击刷新回调
    var refreshBlock:(()->())?
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        let image = UIImageView(image: UIImage(named: "BlankCanvas"), contentMode: .scaleAspectFit, enableInteraction: false)
        self.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(66)
        }
        
        let label = UILabel.labelLayout(text: "暂无数据", font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let refreshBtn = UIButton.init(title: "点击刷新", backgroundColor: .white, titleColor: AppColors.c_666666, font: FontSizes.regular14, alignment: .center, image: nil)
        self.addSubview(refreshBtn)
  
        refreshBtn.layer.borderWidth = 0.5
        refreshBtn.layer.borderColor = AppColors.c_000000.cgColor
        refreshBtn.layer.cornerRadius = 4
        refreshBtn.layer.masksToBounds = true
        
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
        refreshBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.refreshBlock?()
        }).disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UITableViewCell 空白页
class BlackCanvasTableCell:UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        let image = UIImageView(image: UIImage(named: "BlankCanvas"), contentMode: .scaleAspectFit, enableInteraction: false)
        self.contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(66)
        }
        
        let label = UILabel.labelLayout(text: "暂无数据", font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let refreshBtn = UIButton.init(title: "点击刷新", backgroundColor: .white, titleColor: AppColors.c_666666, font: FontSizes.regular14, alignment: .center, image: nil)
        self.contentView.addSubview(refreshBtn)
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        refreshBtn.layer.borderWidth = 0.5
        refreshBtn.layer.borderColor = AppColors.c_000000.cgColor
        refreshBtn.layer.cornerRadius = 4
        refreshBtn.layer.masksToBounds = true
        
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UICollectionViewCell 空白页
class BlackCanvasCollectionCell:UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        let image = UIImageView(image: UIImage(named: "BlankCanvas"), contentMode: .scaleAspectFit, enableInteraction: false)
        self.contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(66)
        }
        
        let label = UILabel.labelLayout(text: "暂无数据", font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        self.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let refreshBtn = UIButton.init(title: "点击刷新", backgroundColor: .white, titleColor: AppColors.c_666666, font: FontSizes.regular14, alignment: .center, image: nil)
        self.contentView.addSubview(refreshBtn)
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        refreshBtn.layer.borderWidth = 0.5
        refreshBtn.layer.borderColor = AppColors.c_000000.cgColor
        refreshBtn.layer.cornerRadius = 4
        refreshBtn.layer.masksToBounds = true
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
