//
//  QuickQuoteHeaderView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/24.
//

import UIKit
import RxSwift
import BRPickerView
//枚举 (整装，翻新，软装，局改，维修)
enum QuickQuoteType:Codable {
    case wholeHouse //整装
    case renovation //翻新
    case softDecoration //软装
    case localChange //局改
    case repair //维修
    case none //隐藏
}

enum pageType {
    case numPage //填数字的页面
    case areaPage //填面积的页面
}
class QuickQuoteHeaderView: UICollectionReusableView {
    public var selectIndex = 0
    public var textField:UITextField!
    //callback
    public var selectTypeCallBack:((_ index:Int) -> Void)?
    
    private var houseAreaView:UIView!
    private var decorationTypeView:UIView!
    
    public var type:QuickQuoteType?{
        didSet{
            guard let type = type else { return  }
            self.houseAreaView.isHidden = false
            if type == .wholeHouse {
                selectButton.setTitle("整装", for: .normal)
                selectIndex = 0
            }else if type == .renovation {
                selectButton.setTitle("翻新", for: .normal)
                selectIndex = 1
            }else if type == .softDecoration {
                selectButton.setTitle("软装", for: .normal)
                self.houseAreaView.isHidden = true
                selectIndex = 2
            }else if type == .localChange {
                selectButton.setTitle("局改", for: .normal)
                selectIndex = 3
            }else if type == .repair {
                selectButton.setTitle("维修", for: .normal)
                selectIndex = 4
            }
        }
    }
    
    public var pageType:pageType?{
        didSet {
            guard let pageType = pageType else { return  }
            if pageType == .numPage {
                self.decorationTypeView.isHidden = false
                self.houseAreaView.isHidden = false
            }else {
                self.decorationTypeView.isHidden = true
                self.houseAreaView.isHidden = true
            }

        }
    }

    private let disposeBag = DisposeBag()

    private var selectButton:UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        let titleLab = UILabel.labelLayout(text: "请您选择新居结构", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        let descLab = UILabel.labelLayout(text: "您可以通过增加或减少按钮来选择您相应房间的数量为您的新家搭配理想方案", font: FontSizes.regular13, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        descLab.numberOfLines = 0
        self.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        let decorationTypeView = creatDecorationTypeView()
        decorationTypeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        self.decorationTypeView = decorationTypeView
        
        let houseAreaView = creatHouseAreaView()
        houseAreaView.snp.makeConstraints { make in
            make.top.equalTo(decorationTypeView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        self.houseAreaView = houseAreaView
    }
    
}

extension QuickQuoteHeaderView {
    //装修类型
    func creatDecorationTypeView() ->UIView {
        let decorationTypeView = UIView.init()
        self.addSubview(decorationTypeView)

        
        let starView = UILabel.labelLayout(text: "*", font: FontSizes.regular13, textColor: AppColors.c_FF995B, ali: .left, isPriority: true, tag: 0)
        decorationTypeView.addSubview(starView)
        starView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let nameLab = UILabel.labelLayout(text: "装修类型", font: FontSizes.regular14, textColor: AppColors.c_666666, ali: .left, isPriority: true, tag: 0)
        decorationTypeView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.leading.equalTo(starView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        let button = UIButton.init(title: "整装", backgroundColor: .white, titleColor: .black, font: FontSizes.regular14, alignment: .center,image: UIImage(named: "icon_arrow_right"))
        button.adjustTitleAndImage(spacing: 8)
        decorationTypeView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
        }
        button.isUserInteractionEnabled = false
        
        self.selectButton = button
        decorationTypeView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return  }
            let stringPickerView = BRStringPickerView.init(pickerMode: .componentSingle)
            stringPickerView.pickerStyle?.selectRowColor = UIColor.black.withAlphaComponent(0.3)
//            stringPickerView.title = "请选择装修类型"
            stringPickerView.dataSourceArr = ["整装","翻新","软装"]
            stringPickerView.selectIndex = self.selectIndex;
            stringPickerView.resultModelBlock = { [weak self] model in
                guard let self = self else { return  }
                button.setTitle(model?.value, for: .normal)
                self.selectIndex = model?.index ?? 0
                guard let callback = self.selectTypeCallBack else { return }
                callback(self.selectIndex)
            }
            stringPickerView.show()
            
        }).disposed(by: disposeBag)
        
        
        return decorationTypeView
    }
    
    //房屋面积
    func creatHouseAreaView() ->UIView {
        let houseAreaView = UIView.init()
        self.addSubview(houseAreaView)

        
        let starView = UILabel.labelLayout(text: "*", font: FontSizes.regular13, textColor: AppColors.c_FF995B, ali: .left, isPriority: true, tag: 0)
        houseAreaView.addSubview(starView)
        starView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let nameLab = UILabel.labelLayout(text: "房屋面积", font: FontSizes.regular14, textColor: AppColors.c_666666, ali: .left, isPriority: true, tag: 0)
        houseAreaView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.leading.equalTo(starView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        let m2Lab = UILabel.labelLayout(text: "m²", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        houseAreaView.addSubview(m2Lab)
        m2Lab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        let textField = UITextField(placeholder: "请输入房屋面积", font: FontSizes.regular14, textColor: AppColors.c_222222, borderStyle: .none, keyboardType: .numberPad)
        textField.textAlignment = .right
        houseAreaView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.trailing.equalTo(m2Lab.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }
        self.textField = textField
        
        return houseAreaView
    }
}
