//
//  QuickQuoteController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/24.
//  快速报价 输入 面积

import UIKit
import RxSwift
import BRPickerView
class QuickQuoteAreaController: BaseViewController {
    public var selectIndex = 0
    private var repairView:UIView!
    public var type:QuickQuoteType = .wholeHouse
    private let disposeBag = DisposeBag()
    private var typeArray:[DecorationTypeModel] = []

    
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
        collectionView.register(DecorationAreaCell.self, forCellWithReuseIdentifier: "DecorationAreaCell")
        collectionView.register(QuickQuoteHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "QuickQuoteHeaderView")

        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    init(title:String,isShowBack:Bool = true,type:QuickQuoteType,typeArr:[DecorationTypeModel]) {
        self.type = type
        
        for model in typeArr {
            for _ in 0..<model.number {
                // 创建 model 的深拷贝
                let newModel = model.deepCopy()!
                newModel.number = 1
                self.typeArray.append(newModel)
            }
        }
        
        super.init(title: title, isShowBack: isShowBack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        let bottomButton = UIButton.init(title: "查看报价", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center)
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
            ///是否至少有一个的面积值 > 0.0
            var isHave = false
            for model in self.typeArray {
                if let m2 = Double(model.area),m2 > 0.0 {
                    isHave = true
                    break
                }
            }
            if !isHave {
                ProgressHUDManager.shared.showErrorOnWindow(message: "至少有一个的面积不为 0")
                return
            }
            let vc = QuoteSegmentSchemeController.init(title: "", isShowBack: true, typeArr: self.typeArray)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
    
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
//        initData()
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
        if type == .localChange || type == .renovation {
            typeArray.append(DecorationTypeModel(name: "卫生间", icon: "icon_room_masterBathroom", type: .masterBathroom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "厨房", icon: "icon_room_kitchen", type: .kitchen, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "墙面刷新", icon: "icon_room_wallRefresh", type: .wallRefresh, area: "", number: 0))
//            typeArray.append(DecorationTypeModel(name: "", icon: "", type: .add, area: "", number: 0))

        }else{
            typeArray.append(DecorationTypeModel(name: "卧室", icon: "icon_room_masterBedroom", type: .masterBedroom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "客厅", icon: "icon_room_livingDiningRoom", type: .livingDiningRoom, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "厨房", icon: "icon_room_kitchen", type: .kitchen, area: "", number: 0))
            typeArray.append(DecorationTypeModel(name: "卫生间", icon: "icon_room_masterBathroom", type: .masterBathroom, area: "", number: 0))
//            typeArray.append(DecorationTypeModel(name: "", icon: "", type: .add, area: "", number: 0))
        }

    }
}


extension QuickQuoteAreaController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DecorationAreaCell", for: indexPath) as! DecorationAreaCell
        let model = typeArray[indexPath.row]
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: kScreenWidth, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "QuickQuoteHeaderView", for: indexPath) as! QuickQuoteHeaderView
        headerView.type = self.type
        headerView.pageType = .areaPage
        headerView.selectTypeCallBack = { [weak self] index in
            guard let self = self else { return  }
            self.selectIndex = index
            self.reloadContentView()
        }
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let model = typeArray[indexPath.row]
//        if model.type == .add {
//
//            let stringPickerView = BRStringPickerView.init(pickerMode: .componentSingle)
//            stringPickerView.pickerStyle?.selectRowColor = UIColor.black.withAlphaComponent(0.3)
//            stringPickerView.dataSourceArr = filterPickerViewData()
//            stringPickerView.resultModelBlock = { [weak self] model in
//                guard let self = self else { return  }
//                guard let item = model else { return  }
//                //名称类型匹配看后续需求
//                //插入到最后第二个
//                self.typeArray.insert(DecorationTypeModel(name: item.value ?? "", icon: item.remark ?? "", type: .masterBedroom, area: "", number: 0), at: self.typeArray.count - 1)
//                self.collectionView.reloadData()
//            }
//            stringPickerView.show()
//        }
    }
  
}



extension QuickQuoteAreaController {
    
    /// 组装 pickerVIew 的数据
    /// - Returns: <#description#>
    func filterPickerViewData() ->[BRResultModel]{
        var dataSource = [BRResultModel]()
        var values:[String] = []
        var imgs:[String] = []
        
        if type == .localChange || type == .renovation {
            values = ["卫生间", "厨房", "墙面刷新"]
            imgs = ["icon_room_masterBathroom", "icon_room_kitchen", "icon_room_wallRefresh"]
        }else{
            values = ["卧室", "客厅", "厨房", "卫生间"]
            imgs = ["icon_room_masterBedroom", "icon_room_livingDiningRoom", "icon_room_kitchen", "icon_room_masterBathroom"]
        }
        
        for(x,y) in zip(values,imgs){
            let model = BRResultModel.init()
            model.value = x
            model.remark = y
            dataSource.append(model)
        }
        
    
        return dataSource
    }
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
            stringPickerView.dataSourceArr = ["整装","翻新","软装"]
            stringPickerView.selectIndex = self.selectIndex;
            stringPickerView.resultModelBlock = { [weak self] model in
                guard let self = self else { return  }
                button.setTitle(model?.value, for: .normal)
                self.selectIndex = model?.index ?? 0
                self.reloadContentView()
            }
            stringPickerView.show()
            
        }).disposed(by: disposeBag)
        
        return decorationTypeView
    }
}
