//
//  QuickQuoteIndexController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/19.
//  快速报价填的数字

import UIKit
import RxSwift
import BRPickerView
class QuickQuoteNumController: BaseViewController {
    public var selectIndex = 0
    private var repairView:UIView!
    public var type:QuickQuoteType = .wholeHouse
    private let disposeBag = DisposeBag()
    private var headerView:QuickQuoteHeaderView!
    private var typeArray = [DecorationTypeModel]()
    private var bottomButton:UIButton!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (kScreenWidth - 48) / 2.0, height: (kScreenWidth - 48) / 2.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(QuickQuoteNumCell.self, forCellWithReuseIdentifier: "QuickQuoteNumCell")
        collectionView.register(QuickQuoteHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "QuickQuoteHeaderView")

        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        setUI()
        
        backArrowButton.rx.tap.subscribe(onNext: { [weak self]  _ in
            guard let self = self else { return  }
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.popToFlutter()
            }
        }).disposed(by: disposeBag)
    }
    init(title:String,isShowBack:Bool = true,type:QuickQuoteType) {
        self.type = type
        super.init(title: title, isShowBack: isShowBack)
    }
  
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setUI(){
        let bottomButton = UIButton.init(title: "下一步", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center)
        bottomButton.layer.cornerRadius = 8
        bottomButton.layer.masksToBounds = true
        self.view.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20 - kSafeHeight)
            make.height.equalTo(48)
        }
        bottomButton.rx.tap.subscribe(onNext: { [weak self]  _ in
            guard let self = self else { return  }
            var textFieldValid: Bool {
                guard let text = self.headerView.textField.text,
                      !text.isEmpty,
                      let number = Double(text) else {
                    return false
                }
                return number > 0
            }
            let hasPositiveNumber = self.typeArray.map({$0.number}).contains(where: {$0 > 0})
            if (self.type == .wholeHouse || self.type == .renovation) && (!textFieldValid || !hasPositiveNumber) {
                ProgressHUDManager.shared.showErrorOnWindow(message: "请输入正确的面积和数量")
                return
            }
            if (self.type == .softDecoration) && (!hasPositiveNumber){
                ProgressHUDManager.shared.showErrorOnWindow(message: "请输入正确的数量")
                return
            }
            switch self.type {
            case .wholeHouse: // 整装跳转到 360 预览图
                let vc = QuoteSceneWebViewController.init(title: "", decorations:self.typeArray, type: self.headerView.type ?? .wholeHouse, areaNum: self.headerView.textField.text ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
            case .renovation: //翻新 去选面积
                let vc = QuickQuoteAreaController(title: "快速报价", isShowBack:true, type: .renovation,typeArr: self.typeArray)
                self.navigationController?.pushViewController(vc, animated: true)
            case .softDecoration:
                let vc = QuoteSceneWebViewController.init(title: "", decorations:self.typeArray, type: self.headerView.type ?? .wholeHouse, areaNum: self.headerView.textField.text ?? "")
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }

        }).disposed(by: disposeBag)
        
        self.bottomButton = bottomButton
        

    
        initRepairView()
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomButton.snp.top).offset(-32)
        }
        
        switch type {
        case .wholeHouse:
            self.selectIndex = 0
        case .renovation:
            self.selectIndex = 1
        case .softDecoration:
            self.selectIndex = 2
        case .localChange:
            self.selectIndex = 3
        case .repair:
            self.selectIndex = 4
        case .none:
            self.selectIndex = -1
        }
        reloadContentView()
    }
    
    /// 刷新主视图
    func reloadContentView(){
        switch selectIndex {
        case 0:
            self.type = .wholeHouse
        case 1:
            self.type = .renovation
        case 2:
            self.type = .softDecoration
        case 3:
            self.type = .localChange
        case 4:
            self.type = .repair
        default:
            break
        }
        initData()
        if type == .repair {
            self.repairView.isHidden = false
            self.collectionView.isHidden = true
            self.typeArray.removeAll()
        }else{
            self.repairView.isHidden = true
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    /// 维修类型特殊处理
    func initRepairView() {
        let bgView = UIView.init()
        self.view.addSubview(bgView)
        bgView.backgroundColor = .white
        bgView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-68 - kSafeHeight - 32)
        }
        self.repairView = bgView
        
        let titleLab = UILabel.labelLayout(text: "维修", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        let descLab = UILabel.labelLayout(text: "输入您的维修需求", font: FontSizes.regular13, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        descLab.numberOfLines = 0
        bgView.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        let decorationTypeView = creatDecorationTypeView(view: bgView)
        decorationTypeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        
        let grayView = UIView.init()
        bgView.addSubview(grayView)
        grayView.backgroundColor = AppColors.c_F8F8F8
        grayView.layer.cornerRadius = 6
        grayView.layer.masksToBounds = true
        grayView.snp.makeConstraints { make in
            make.top.equalTo(decorationTypeView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(120)
        }
        let textView = PlaceholderTextView()
        textView.placeholder = "请输入内容..."
        textView.font = FontSizes.regular14
        textView.textColor = AppColors.c_222222
        grayView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        

        
    }
    //初始化数据
    func initData(){
        typeArray.removeAll()
        if type == .localChange || type == .renovation { //局改和翻新
            typeArray.append(DecorationTypeModel(name: "卫生间", icon: "icon_room_masterBathroom", type: .masterBathroom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "厨房", icon: "icon_room_kitchen", type: .kitchen, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "墙面刷新", icon: "icon_room_wallRefresh", type: .wallRefresh, area: "", number: 0))
//            typeArray.append(DecorationTypeModel(name: "", icon: "", type: .add, area: "", number: 0))


        }else if type == .softDecoration { //软装
            typeArray.append(DecorationTypeModel(name: "卧室", icon: "icon_room_masterBedroom", type: .masterBedroom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "客厅", icon: "icon_room_livingDiningRoom", type: .livingDiningRoom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "餐厅", icon: "icon_room_restaurant", type: .restaurant, area: "", number: 0))
        }
        else{ //整装
            typeArray.append(DecorationTypeModel(name: "卧室", icon: "icon_room_masterBedroom", type: .masterBedroom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "客厅", icon: "icon_room_livingDiningRoom", type: .livingDiningRoom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "厨房", icon: "icon_room_kitchen", type: .kitchen, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "卫生间", icon: "icon_room_masterBathroom", type: .masterBathroom, area: "", number: 0))
        }

    }
}


extension QuickQuoteNumController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickQuoteNumCell", for: indexPath) as! QuickQuoteNumCell
        let model = typeArray[indexPath.row]
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height  = 250.0
        if type == .softDecoration {
            height = 180.0
        }
        return CGSize(width: kScreenWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "QuickQuoteHeaderView", for: indexPath) as! QuickQuoteHeaderView
        headerView.pageType = .numPage
        headerView.type = self.type
        headerView.selectTypeCallBack = { [weak self] index in
            guard let self = self else { return  }
            self.selectIndex = index
            headerView.textField.text = ""
            self.reloadContentView()
        }
        self.headerView = headerView
 
        return headerView
    }

  
}



extension QuickQuoteNumController {
    
 
    ///装修类型
    func creatDecorationTypeView(view:UIView) ->UIView {
        let decorationTypeView = UIView.init()
        view.addSubview(decorationTypeView)

        
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
        
        let button = UIButton.init(title: "维修", backgroundColor: .white, titleColor: .black, font: FontSizes.regular14, alignment: .center,image: UIImage(named: "icon_arrow_right"))
        button.adjustTitleAndImage(spacing: 8)
        decorationTypeView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
        }
        button.isUserInteractionEnabled = false
        
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
                let _ = self.typeArray.map({$0.number = 0})

                self.reloadContentView()
            }
            stringPickerView.show()
            
        }).disposed(by: disposeBag)
        
        return decorationTypeView
    }
}
