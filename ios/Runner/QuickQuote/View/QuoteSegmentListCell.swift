//
//  QuoteSegmentListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/29.
//  快速报价分栏 Cell (翻新等)

import UIKit
import Kingfisher
import RxSwift
class QuoteSegmentListCell:UITableViewCell {
    var model:PackageListModel?{
        didSet {
            setModel()
        }
    }
    private var descImageView = UIImageView()
    private var titleLabel = UILabel()
    private var priceLab = UILabel()
    private var disposeBag = DisposeBag()
    private var button:UIButton!
    //按钮回调
    var buttonCallBack:(() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setModel() {
        guard let model = model else { return  }
        self.descImageView.kf.setImage(with: URL(string: model.packagePic))
        self.titleLabel.text = model.packageName
        
        let priceStr = model.basePrice
        let m2Str = "\(priceStr)元起"
        // 创建一个 NSMutableAttributedString 对象
        let attributedString = NSMutableAttributedString(string: m2Str)

        // 设置 priceStr 部分的属性
        let priceRange = (m2Str as NSString).range(of: "\(priceStr)")
        attributedString.addAttribute(.font, value: FontSizes.regular12, range: priceRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.c_FFA555, range: priceRange)

        // 设置其他部分的属性
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: FontSizes.medium18, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.c_FFA555, range: fullRange)

        // 避免覆盖 priceStr 部分的样式
        attributedString.addAttributes([.font: FontSizes.regular12, .foregroundColor: AppColors.c_999999], range: NSRange(location: 0, length: priceRange.location))
        attributedString.addAttributes([.font: FontSizes.regular12, .foregroundColor: AppColors.c_999999], range: NSRange(location: priceRange.location + priceRange.length, length: attributedString.length - (priceRange.location + priceRange.length)))
        self.priceLab.attributedText = attributedString
        
        if model.isSelected ?? false == true {
            self.button.setTitleColor(AppColors.c_FFA555, for: .normal)
            self.button.layer.borderColor = AppColors.c_FFA555.cgColor
            //SF symbol ✔ 图片
            let image = UIImage(systemName: "checkmark")?.withTintColor(AppColors.c_FFA555, renderingMode: .alwaysOriginal)
            self.button.setImage(image, for: .normal)
            button.snp.remakeConstraints { make in
                make.top.equalTo(descImageView.snp.bottom).offset(18)
                make.trailing.equalToSuperview().offset(-20)
                make.width.equalTo(101)
                make.height.equalTo(34)
            }
        }else{
            self.button.setTitleColor(AppColors.c_333333, for: .normal)
            self.button.layer.borderColor = AppColors.c_000000.withAlphaComponent(0.15).cgColor
            button.snp.remakeConstraints { make in
                make.top.equalTo(descImageView.snp.bottom).offset(18)
                make.trailing.equalToSuperview().offset(-20)
                make.width.equalTo(88)
                make.height.equalTo(34)
            }
            self.button.setImage(nil, for: .normal)

        }
        
    }
    func setupView(){
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(148)
        }
        
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        
        self.descImageView = imageView
        
        let titleLabel = UILabel.labelLayout(text: "全屋定制", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalTo(imageView)
        }
        
        self.titleLabel = titleLabel
        

        // 在 UILabel 中展示
        let label = UILabel()
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        self.priceLab = label
        
        
        let button = UIButton.init(title: "选择方案", backgroundColor:.white, titleColor: AppColors.c_333333, font: FontSizes.regular13, alignment: .center)
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 0.5
        button.layer.borderColor = AppColors.c_000000.withAlphaComponent(0.15).cgColor
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(18)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(88)
            make.height.equalTo(34)
        }
        self.button = button
        
        button.rx.tap.withUnretained(self).subscribe(onNext: { owner, _ in
            guard let callback = owner.buttonCallBack else { return }
            callback()
        }).disposed(by: disposeBag)
    }
}
