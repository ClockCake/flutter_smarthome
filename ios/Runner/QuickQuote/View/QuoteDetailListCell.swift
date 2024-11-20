//
//  QuoteDetailListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/20.
//

import UIKit

class QuoteDetailListCell: UITableViewCell {
    private var image:UIImageView!
    private var nameLab:UILabel!
    private var brandNameLab:UILabel!
    private var standardLab:UILabel!
    private var numberLab:UILabel!
    var model: MaterialItemModel?{
        didSet{
            guard let model = model else { return  }
            self.image.kf.setImage(with: URL(string: model.skuPic ?? ""))
            self.nameLab.text = model.materialName ?? ""
            self.numberLab.text = "x\(model.quotaUsage?.formattedString() ?? "")"
            self.brandNameLab.text = "品牌:\(model.brandName ?? "")"
            self.standardLab.text = "规格:\(model.brandName ?? "")"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = AppColors.c_F8F8F8
        setUI()
    }
    func setUI() {
        let containerView = UIView.init()
        containerView.backgroundColor = .white
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        let image = UIImageView.init()
        containerView.addSubview(image)
        image.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(62)
        }
        
        image.layer.cornerRadius = 4
        image.layer.masksToBounds = true
        self.image = image
        
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(image)
            make.leading.equalTo(image.snp.trailing).offset(10)
        }
        self.nameLab = titleLab
        
        let brandNameLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(brandNameLab)
        brandNameLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.leading.equalTo(titleLab)
    
        }
        
        self.brandNameLab = brandNameLab
        
        let standardLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(standardLab)
        standardLab.snp.makeConstraints { make in
            make.top.equalTo(brandNameLab.snp.bottom).offset(5)
            make.leading.equalTo(titleLab)
        }
        
        self.standardLab = standardLab
        
        let numberLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        containerView.addSubview(numberLab)
        numberLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        self.numberLab = numberLab
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
