//
//  QuickQuoteNumCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/19.
//
import UIKit
import PPNumberButton
class QuickQuoteNumCell: UICollectionViewCell {
    var model:DecorationTypeModel?{
        didSet{
            setModel()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private var img:UIImageView!
    private var nameLab:UILabel!
    private var numberButton:PPNumberButton!
    private var addBtn:UIButton!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //model 赋值
    func setModel(){
        guard let model = model else { return  }
        if model.type == .add {
            self.addBtn.isHidden = false
            self.img.isHidden = true
            self.nameLab.isHidden = true
            self.numberButton.isHidden = true
        }else{
            self.addBtn.isHidden = true
            self.img.isHidden = false
            self.nameLab.isHidden = false
            self.img.image = UIImage(named: model.icon)
            self.nameLab.text = model.name
            self.numberButton.isHidden = false
            self.numberButton.currentNumber = CGFloat(model.number)
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
        

        let numberButton = PPNumberButton.init(frame: .zero)
        numberButton?.shakeAnimation = true
        numberButton?.borderColor = UIColor.gray
        numberButton?.increaseTitle = "＋"
        numberButton?.decreaseTitle = "－"
        numberButton?.isEditing = false
        numberButton?.resultBlock = { (ppBtn, number, isIncrease) in
            print("Number: \(number), Is Increase: \(isIncrease)")
            self.model?.number = Int(number)
        }
        self.contentView.addSubview(numberButton ?? UIView.init())
        numberButton?.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        self.numberButton = numberButton
        
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
