//
//  ProjectCheckListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/23.
//

import UIKit
import Kingfisher
class ProjectCheckListCell: UITableViewCell {
    private var icon:UIImageView!
    private var nameLab:UILabel!
    private var skuLab:UILabel!
    private var miniIcon:UIImageView!
    private var businessLab:UILabel!
    private var numLab:UILabel!
    
    public var model:ProjectCheckRowModel?{
        didSet {
            guard let model = model else { return  }
            self.icon.kf.setImage(with: URL(string: model.materialPic ?? ""), placeholder: UIImage(named: "placeholder"))
            self.nameLab.text = model.materialName ?? ""
            if let sku = model.sku, sku.count > 0 {
                self.skuLab.text = "\(model.sku ?? "")  单位: \(model.unit ?? "")"
            }else{
                self.skuLab.text = "单位: \(model.unit ?? "")"
            }
            self.businessLab.text = model.brandName ?? ""
            self.numLab.text = "*\(model.number?.formattedString() ?? "")"
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = .white
        setUI()
    }
    
    func setUI(){
        let icon = UIImageView.init()
        icon.layer.cornerRadius = 4
        icon.layer.masksToBounds = true
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(64)
            make.bottom.equalToSuperview()
        }
        self.icon = icon
        
        let nameLab = UILabel.labelLayout(text: "xxx", font: FontSizes.regular13, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.top.equalTo(icon)
            make.leading.equalTo(icon.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.nameLab = nameLab
        
        let skuLab = UILabel.labelLayout(text: "", font: FontSizes.regular11, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(skuLab)
        skuLab.snp.makeConstraints { make in
            make.top.equalTo(nameLab.snp.bottom).offset(4)
            make.leading.equalTo(nameLab)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.skuLab = skuLab
        
        let miniIcon = UIImageView.init(image: UIImage(named: "icon_mini_placeholder"))
        self.contentView.addSubview(miniIcon)
        miniIcon.snp.makeConstraints { make in
            make.leading.equalTo(nameLab)
            make.bottom.equalTo(icon)
        }
        self.miniIcon = miniIcon
        
        
        let businessLab = UILabel.labelLayout(text: "", font: FontSizes.regular10, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(businessLab)
        businessLab.snp.makeConstraints { make in
            make.leading.equalTo(miniIcon.snp.trailing).offset(4)
            make.centerY.equalTo(miniIcon)
        }
        self.businessLab = businessLab
        
        let numLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .right, isPriority: true, tag: 0)
        self.contentView.addSubview(numLab)
        numLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        self.numLab = numLab
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
