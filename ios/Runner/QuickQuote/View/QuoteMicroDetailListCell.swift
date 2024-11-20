//
//  QuoteMicroDetailListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/30.
//

import UIKit
class QuoteMicroDetailListCell: UITableViewCell {
    private var titleLab:UILabel!
    private var stackView:UIStackView!
    public var model:MicroRespVoModel?{
        didSet{
            setModel()
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = AppColors.c_F8F8F8
        setUI()
    }
    
    func setModel(){
        guard let model = model else { return  }
        let _ = self.stackView.subviews.map({$0.removeFromSuperview()})
        if let items = model.items,items.count > 0 {
            for item in items {
                let subView = creatSubView(model: item)
                self.stackView.addArrangedSubview(subView)
                subView.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(94)
                }
            }
        }
        if model.type == .renovation {
            self.titleLab.text = model.budgetDisplay
            self.titleLab.isHidden = false
            self.titleLab.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.equalToSuperview().offset(16)
            }
            self.stackView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(titleLab.snp.bottom).offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-0)
            }
        }else{
            self.titleLab.isHidden = true
            self.titleLab.snp.remakeConstraints { make in
                
            }
            self.stackView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-0)
            }
        }
    }
    func setUI() {
        let bgView = UIView()
        bgView.backgroundColor = .white
        self.contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.medium14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        self.titleLab = titleLab
        
        let stackView = UIStackView(axis: .vertical)
        bgView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-0)
        }
        self.stackView = stackView
    }
    
    func creatSubView(model:MicroItemModel) ->UIView {
        let view = UIView.init()
        view.backgroundColor = .white
        let img = UIImageView.init()
        img.kf.setImage(with: URL(string: model.skuPic ?? ""))
        view.addSubview(img)
        img.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.width.height.equalTo(62)
        }
        img.layer.cornerRadius = 4
        img.layer.masksToBounds = true
        
        let nameLab = UILabel.labelLayout(text: model.materialName, font: FontSizes.regular14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        view.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.leading.equalTo(img.snp.trailing).offset(12)
            make.top.equalTo(img)
        }
        let brandNameLab = UILabel.labelLayout(text: "品牌: \(model.brandName ?? "")", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        view.addSubview(brandNameLab)
        brandNameLab.snp.makeConstraints { make in
            make.leading.equalTo(nameLab)
            make.top.equalTo(nameLab.snp.bottom).offset(6)
        }
        let standardLab = UILabel.labelLayout(text: "规格: \(model.sku ?? "")", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        view.addSubview(standardLab)
        standardLab.snp.makeConstraints { make in
            make.top.equalTo(brandNameLab.snp.bottom).offset(4)
            make.leading.equalTo(brandNameLab)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        let numLab = UILabel.labelLayout(text: "x\(model.quotaUsage?.formattedString() ?? "")", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .right, isPriority: true, tag: 0)
        view.addSubview(numLab)
        numLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        return view
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
