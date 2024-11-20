//
//  DesignLogsLIstCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
class DesignLogsLIstCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let mainImageView = UIImageView.init()
        mainImageView.backgroundColor = UIColor.randomColor()
        mainImageView.layer.cornerRadius = 6
        mainImageView.layer.masksToBounds = true
        self.contentView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            //高度等于宽度
            make.height.equalTo(mainImageView.snp.width)
        }
        
        let titleLab = UILabel.labelLayout(text: "户外照", font: FontSizes.regular14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
