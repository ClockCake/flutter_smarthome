//
//  QuoteMicroDetailController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/30.
//  报价明细 (翻新，软装)

import UIKit
import RxRelay
import RxSwift
class QuoteMicroDetailController: BaseViewController {
    private var savePackageArr = BehaviorRelay<[PackageListModel]>(value: [])
    private let disposeBag = DisposeBag()
    private let viewModel = PackageViewModel()
    private var priceLab:UILabel!
    private var type:QuickQuoteType?
    private var saveStylesArr = BehaviorRelay<[SoftDecorationStyleListModel]>(value: [])
    private var packageId:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.titleLab.text = "报价明细"
        let reserveBtn = UIButton.init(title: "免费领取设计方案和精准报价", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center)
        reserveBtn.layer.cornerRadius = 6
        reserveBtn.layer.masksToBounds = true
        self.view.addSubview(reserveBtn)
        reserveBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-kSafeHeight - 12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        reserveBtn.rx.tap.withUnretained(self).subscribe(onNext: { owner, _ in
            let view = GlobalReserveView(frame: .zero,businessType: "6")
            //获取window
            let window = UIApplication.shared.windows.first
            window?.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            view.closeCallBack = {
                view.removeFromSuperview()

            }
        }).disposed(by: disposeBag)
        
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(customNavBar.snp.bottom)
            make.bottom.equalTo(reserveBtn.snp.top).offset(-20)
        }
        
        requestData()
        
    }
    
    /// 翻新初始化
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - isShowBack: <#isShowBack description#>
    ///   - savePackageArr: <#savePackageArr description#>
    ///   - type: <#type description#>
    init(title: String, isShowBack: Bool = true,savePackageArr:BehaviorRelay<[PackageListModel]>,type:QuickQuoteType = .renovation) {
        self.savePackageArr = savePackageArr
        self.type = type
        super.init(title: title, isShowBack: isShowBack)
    }
    
    /// 软装初始化
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - isShowBack: <#isShowBack description#>
    ///   - saveStylesArr: <#saveStylesArr description#>
    ///   - type: <#type description#>
    init(title: String, isShowBack: Bool = true,saveStylesArr:BehaviorRelay<[SoftDecorationStyleListModel]>,type:QuickQuoteType = .softDecoration,packageId:String) {
        self.saveStylesArr = saveStylesArr
        self.type = type
        self.packageId  = packageId
        super.init(title: title, isShowBack: isShowBack)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuoteMicroDetailListCell.self, forCellReuseIdentifier: "QuoteMicroDetailListCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headView
        return tableView
    }()
    
    lazy var headView = { () -> UIView in
        let headView = UIView()
        headView.backgroundColor = AppColors.c_F8F8F8
        headView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight / 4.0 )

        let bgView = UIView.init()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 8
        bgView.layer.masksToBounds = true
        headView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    
        
        let priceLab = UILabel.labelLayout(text: "", font: FontSizes.DINBoldFont32, textColor: AppColors.c_222222, ali: .center, isPriority: true, tag: 0)
        bgView.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.priceLab = priceLab
        
        let unitLab = UILabel.labelLayout(text: "万", font:  FontSizes.medium12, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        bgView.addSubview(unitLab)
        unitLab.snp.makeConstraints { make in
            make.centerY.equalTo(priceLab)
            make.leading.equalTo(priceLab.snp.trailing).offset(5)
        }

        if type == .renovation {
            let names = self.savePackageArr.value.map { $0.name ?? "" }.joined(separator: " · ")
            let roomsLab = UILabel.labelLayout(text: names, font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
            bgView.addSubview(roomsLab)
            roomsLab.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(priceLab.snp.bottom).offset(10)
            }
        }
        
        if type == .softDecoration {
            let gradientLabel = GradientLabelWithIndentedCorner(frame: .zero)
            gradientLabel.text = ""
            gradientLabel.startColor = .white
            gradientLabel.endColor = AppColors.c_FFB74A.withAlphaComponent(0.2)
            gradientLabel.cornerRadius = 15
            gradientLabel.frame.origin = CGPoint(x: 16, y: 16)
            gradientLabel.layer.borderWidth = 1
            gradientLabel.layer.borderColor =  UIColor.white.cgColor

            bgView.addSubview(gradientLabel)
            
            let textLab = UILabel.labelLayout(text: "" , font: FontSizes.medium12, textColor: AppColors.c_FFB74A, ali: .center, isPriority: true, tag: 0)
            gradientLabel.addSubview(textLab)
            textLab.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            let roomType6Count = saveStylesArr.value.filter { $0.roomType == "6" }.count
            let roomType7Count = saveStylesArr.value.filter { $0.roomType == "7" }.count
            
            let roomsLab = UILabel.labelLayout(text: "\(roomType6Count)室\(roomType7Count)厅", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
            bgView.addSubview(roomsLab)
            roomsLab.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(priceLab.snp.bottom).offset(10)
            }
            
            viewModel.packageName.bind(to: textLab.rx.text,gradientLabel.rx.text).disposed(by: disposeBag)
        }
        return headView
    }()
    
    
    func requestData() {
        if type == .renovation {
            var param = [String:Any]() //总参数
            var roomList = [[String:Any]]()
            param["packageGroupType"] = "minute"
            for model in self.savePackageArr.value {
                var roomDic = [String:Any]()
                roomDic["bindingPackageId"] = model.packageId
                roomDic["landArea"] = model.areaNum
                switch model.type {
                case .kitchen:
                    roomDic["roomType"] = "1"
                case .masterBathroom:
                    roomDic["roomType"] = "9"
                case .wallRefresh:
                    roomDic["roomType"] = "28"
                default:
                    break
                }
                    
                roomList.append(roomDic)
            }
            param["roomList"] = roomList
            self.viewModel.fetchQuickRenovationQuoteDetail(param: param)
        }
        if type == .softDecoration {
            var param = [String:Any]() //总参数
            var roomList = [[String:Any]]()
            param["packageId"] = self.packageId
            for model in self.saveStylesArr.value {
                var roomDic = [String:Any]()
                roomDic["suitableCase"] = model.dictValue
                roomDic["roomType"] = model.roomType
                roomList.append(roomDic)
            }
            param["roomList"] = roomList
            self.viewModel.fetchSoftQuoteDetail(param: param)

        }

        //监听数据流
        self.viewModel.MicroPriceDetail
            .withUnretained(self)
            .subscribe(onNext: { (vc ,model) in
                if let model = model {
                    vc.priceLab.text = "\(model.quickPriceResult.totalPrice)"
                    for item in model.material ?? [] {
                        for subItem in item.respVos ?? [] {
                            subItem.type = self.type
                        }
                    }
                    vc.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
    }
}

extension QuoteMicroDetailController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.MicroPriceDetail.value?.material?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = self.viewModel.MicroPriceDetail.value?.material?[section]
        return model?.respVos?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = AppColors.c_F8F8F8
        
        let bgView = UIView.init()
        bgView.backgroundColor = AppColors.c_FFB26D.withAlphaComponent(0.8)
        let cornerRadius: CGFloat = 10 // 设置圆角半径
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bgView.layer.cornerRadius = cornerRadius
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        
        let model = self.viewModel.MicroPriceDetail.value?.material?[section]
        let titleLab = UILabel.labelLayout(text: model?.roomTypeDisplay ?? "", font: FontSizes.medium14, textColor: .white, ali: .left, isPriority: true, tag: 0)
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        let areaLab = UILabel.labelLayout(text: "\(model?.landArea ?? 0)㎡", font: FontSizes.medium14, textColor: .white, ali: .left, isPriority: true, tag: 0)
        bgView.addSubview(areaLab)
        areaLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        return view
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteMicroDetailListCell", for: indexPath) as! QuoteMicroDetailListCell
        let sectionModel = self.viewModel.MicroPriceDetail.value?.material?[indexPath.section]
        let model = sectionModel?.respVos?[indexPath.row]
        cell.selectionStyle = .none
        cell.model = model
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = AppColors.c_F8F8F8
        return view
    }
    
}
