//
//  SoftDecorationStyleListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/31.
//

import UIKit
import Kingfisher
class SoftDecorationStyleListCell: UICollectionViewCell {
    private var bgImageView:UIImageView!
    private var selectImageView:UIImageView!
    private var titleLab:UILabel!
    public var model: SoftDecorationStyleListModel?{
        didSet{
            setModel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        let bgImageView = UIImageView()
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.layer.cornerRadius = 4
        bgImageView.layer.masksToBounds = true
        self.contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            //高度等于宽度
            make.height.equalTo(bgImageView.snp.width)
        }
        self.bgImageView = bgImageView
        
        let selectImageView = UIImageView.init(image: UIImage(named: "icon_noSelect"))
        bgImageView.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(20)
        }
        self.selectImageView = selectImageView
        
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .center, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(bgImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        self.titleLab = titleLab
        
    }
    
    func setModel() {
        guard let model = model else { return  }
        self.bgImageView.kf.setImage(with: URL(string: model.pic ?? ""))
        self.titleLab.text = model.dictLabel
        selectImageView.image = model.isSelected  ?? false == true ? UIImage(named: "icon_select") : UIImage(named: "icon_noSelect")
    }
    
}
