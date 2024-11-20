//
//  SmartDeviceInspirationListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

import Foundation
class SmartDeviceInspirationListCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        let sourceImageView = UIImageView.init()
        sourceImageView.layer.cornerRadius = 6
        sourceImageView.layer.masksToBounds = true
        sourceImageView.backgroundColor = UIColor.randomColor()
        self.contentView.addSubview(sourceImageView)
        sourceImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(190)
        }
        
        let styleLab = UILabel.labelLayout(text: "3室2厅 · 现代", font: FontSizes.regular11, textColor: AppColors.c_CA9C72, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(styleLab)
        styleLab.snp.makeConstraints { (make) in
            make.leading.equalTo(sourceImageView)
            make.top.equalTo(sourceImageView.snp.bottom).offset(10)
        }
        
        let titleLab = UILabel.labelLayout(text: "改造治愈系现代风新居，繁华都市中温馨质感新家", font: FontSizes.medium13, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalTo(sourceImageView)
            make.top.equalTo(styleLab.snp.bottom).offset(5)
            make.trailing.equalTo(sourceImageView)
        }
        
        let iconImageView = UIImageView.init()
        iconImageView.layer.cornerRadius = 8
        iconImageView.layer.masksToBounds = true
        iconImageView.backgroundColor = UIColor.randomColor()
        self.contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(sourceImageView)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.width.height.equalTo(16)
        }
        
        let nameLab = UILabel.labelLayout(text: "张楠青", font: FontSizes.regular11, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(nameLab)
        nameLab.snp.makeConstraints { (make) in
            make.leading.equalTo(iconImageView.snp.trailing).offset(5)
            make.centerY.equalTo(iconImageView)
            make.bottom.equalToSuperview().offset(0)
        }
    }
}
