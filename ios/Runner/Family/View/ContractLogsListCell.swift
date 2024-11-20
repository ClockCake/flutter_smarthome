//
//  ContractLogsListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
class ContractLogsCell: UITableViewCell {
    private var titleLab:UILabel!
    private var planLab:UILabel!
    private var numLab:UILabel!
    public var model:ContractListModel?{
        didSet{
            guard let model = model else { return  }
            self.titleLab.text = model.contractTypeDisPlay ?? ""
            self.planLab.text = "设计方案：\(model.packageName ?? "")"
            self.numLab.text = "合同编号：\(model.contractNo ?? "")"
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = AppColors.c_F8F8F8
        let containerView = UIView.init()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }
        
        let titleLab = UILabel.labelLayout(text: "标准合同-标准包名称", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        self.titleLab = titleLab
        
        let planLab = UILabel.labelLayout(text: "设计方案：极简风", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        planLab.numberOfLines = 0
        containerView.addSubview(planLab)
        planLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
        }
        self.planLab = planLab
        
        let numLab = UILabel.labelLayout(text: "合同编号：20240412001", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(numLab)
        numLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(planLab.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)

        }
        self.numLab = numLab
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
