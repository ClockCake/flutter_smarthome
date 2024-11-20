//
//  MeasureRoomListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
import Kingfisher
class MeasureRoomListCell: UICollectionViewCell {
    private var containerImageView:UIImageView!
    private var titleLab:UILabel!
    public var model:FurnishPhotosUrlModel?{
        didSet {
            guard let model = model else { return  }
            self.containerImageView.kf.setImage(with: URL(string: model.url ?? ""))
            self.titleLab.text = model.title ?? ""
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let mainImageView = UIImageView.init()
        mainImageView.layer.cornerRadius = 6
        mainImageView.layer.masksToBounds = true
        self.contentView.addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            //高度等于宽度
            make.height.equalTo(mainImageView.snp.width)
        }
        self.containerImageView  = mainImageView
        
        let titleLab = UILabel.labelLayout(text: "户外照", font: FontSizes.regular14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.titleLab = titleLab
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
