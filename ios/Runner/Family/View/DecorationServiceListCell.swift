//
//  DecorationServiceListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/13.
//

import UIKit
class DecorationServiceListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    func setUI(){
        let titleLab = UILabel.labelLayout(text: "施工准备", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        let statusLab = UILabel.labelLayout(text: "已完成", font: FontSizes.regular12, textColor: AppColors.c_6EC64A, ali: .right, isPriority: true, tag: 0)
        self.contentView.addSubview(statusLab)
        statusLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        
        let timeLab = UILabel.labelLayout(text: "2022-01-01到2022-12-12", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
        }
        
        let daysLab = UILabel.labelLayout(text: "共5个工作日，占比12%", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(daysLab)
        daysLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(timeLab.snp.bottom).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
