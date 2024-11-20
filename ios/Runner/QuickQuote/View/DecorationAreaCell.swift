//
//  DecorationNumCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/24.
//

import UIKit
import RxSwift
class DecorationAreaCell: UICollectionViewCell {
    var model:DecorationTypeModel?{
        didSet{
            setModel()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    private let disposeBag = DisposeBag()
    private var img:UIImageView!
    private var nameLab:UILabel!
    private var addBtn:UIButton!
    public var textField:UITextField!
    private var whiteView:UIView!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //model 赋值
    func setModel(){
        guard let model = self.model else { return  }
        if model.type == .add {
            self.addBtn.isHidden = false
            self.img.isHidden = true
            self.nameLab.isHidden = true
            self.whiteView.isHidden = true
        }else{
            self.addBtn.isHidden = true
            self.img.isHidden = false
            self.nameLab.isHidden = false
            self.img.image = UIImage(named: model.icon)
            self.nameLab.text = model.name
            self.whiteView.isHidden = false
        }

    }
    func setupView(){
        let bgView = UIView()
        bgView.backgroundColor = AppColors.c_F8F8F8
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        self.contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let img = UIImageView()
        bgView.addSubview(img)
        img.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
            make.width.height.equalTo(40)
        }
        self.img = img
        
        let nameLab = UILabel.labelLayout(text: "主卧", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .center, isPriority: true, tag: 0)
        bgView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        self.nameLab = nameLab
        
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        whiteView.layer.cornerRadius = 18
        whiteView.layer.masksToBounds = true
        bgView.addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(12)
            make.height.equalTo(36)
        }
        self.whiteView = whiteView
        
        let m2Lab = UILabel.labelLayout(text: "m²", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .right, isPriority: true, tag: 0)
        whiteView.addSubview(m2Lab)
        m2Lab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        let textField = UITextField(placeholder: "请输入", font: FontSizes.regular14, textColor: AppColors.c_222222, borderStyle: .none, keyboardType: .numberPad)
        whiteView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(m2Lab.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        self.textField = textField
        // 从 textField 到 model
        textField.rx.text
            .map { text -> Double? in
                guard let text = text, !text.isEmpty else { return nil }
                return Double(text)
            }
            .bind { [weak self] value in
                self?.model?.area = String(value ?? 0.0)
            }
            .disposed(by: disposeBag)
        
        
        let addBtn = UIButton.init(title: "添加房间部位", backgroundColor: .clear, titleColor: AppColors.c_999999, font: FontSizes.regular14, alignment: .center, image: UIImage(named: "icon_room_add"))
        addBtn.alignImageAboveLabel(withSpacing: 8)
        bgView.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        addBtn.isHidden = true
        self.addBtn = addBtn
    }
}
