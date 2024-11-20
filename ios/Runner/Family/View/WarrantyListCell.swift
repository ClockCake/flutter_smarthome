//
//  WarrantyListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/13.
//

import UIKit
class WarrantyListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        let timeLab = UILabel.labelLayout(text: "14:38", font: FontSizes.medium14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview()
        }
        
        let daysLab = UILabel.labelLayout(text: "10-12", font: FontSizes.regular11, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(daysLab)
        daysLab.snp.makeConstraints { make in
            make.top.equalTo(timeLab.snp.bottom)
            make.leading.equalTo(timeLab)
        }
        
        let dotView = UIView.init()
        dotView.backgroundColor = AppColors.c_FFA555
        dotView.layer.cornerRadius = 6
        dotView.layer.masksToBounds = true
        self.contentView.addSubview(dotView)
        dotView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(timeLab)
            make.leading.equalToSuperview().offset(80)
        }
        
        let statusLab = UILabel.labelLayout(text: "预算中", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(statusLab)
        statusLab.snp.makeConstraints { make in
            make.centerY.equalTo(dotView)
            make.leading.equalTo(dotView.snp.trailing).offset(4)
        }
        
        let contentLab = UILabel.labelLayout(text: "去年在你们家装修的，整体装修还行，据说今年卫生间地板漏水了，帮我修复一下", font: FontSizes.regular13, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(contentLab)
        contentLab.snp.makeConstraints { make in
            make.leading.equalTo(dotView)
            make.top.equalTo(statusLab.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.equalTo(contentLab)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(contentLab.snp.bottom).offset(18)
            make.height.equalTo(92)
        }
        

        var previousImageView: UIImageView? = nil

        for i in 0..<10 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = UIColor.randomColor()
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            scrollView.addSubview(imageView)

            // 设置约束
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(92)
                make.height.equalTo(92)
                if let previous = previousImageView {
                    make.leading.equalTo(previous.snp.trailing).offset(8) // 位于前一个imageView之后
                } else {
                    make.leading.equalToSuperview() // 第一个imageView与scrollView左侧对齐
                }
            }

            previousImageView = imageView

            // 设置最后一个imageView的trailing与scrollView的trailing对齐
            if i == 9 {
                imageView.snp.makeConstraints { make in
                    make.trailing.equalToSuperview().offset(-16)
                }
            }
        }
        
        let priceLab = UILabel.labelLayout(text: "报价结果：¥1289.00", font: FontSizes.regular12, textColor: AppColors.c_FFA555, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.leading.equalTo(contentLab)
            make.top.equalTo(scrollView.snp.bottom).offset(32)
        }
        
        
        let contractBtn = UIButton.init(title: "立即签约", backgroundColor: .black, titleColor: .white, font: FontSizes.regular13, alignment: .center)
        contractBtn.layer.cornerRadius = 4
        contractBtn.layer.masksToBounds = true
        self.contentView.addSubview(contractBtn)
        contractBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(priceLab)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        let cancelBtn = UIButton.init(title: "撤销", backgroundColor: .white, titleColor: AppColors.c_999999, font: FontSizes.regular13, alignment: .center)
        cancelBtn.layer.cornerRadius = 4
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = AppColors.c_999999.cgColor
        self.contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.trailing.equalTo(contractBtn.snp.leading).offset(-8)
            make.centerY.equalTo(contractBtn)
            make.width.equalTo(54)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        
        let lineView = UIView.init()
        lineView.backgroundColor = AppColors.c_000000.withAlphaComponent(0.15)
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.equalTo(timeLab)
            make.top.equalTo(daysLab.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(0.5)
        }
        
        
    }
}
