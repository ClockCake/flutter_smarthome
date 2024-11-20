//
//  QuoteDetailController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/20.
//  报价明细整装

import UIKit
import RxSwift
class QuoteDetailController: BaseViewController {
    
    private var decorations:[DecorationTypeModel]
    private var areaNum:String
    private let viewModel = PackageViewModel()
    private let disposeBag = DisposeBag()
    private var packageId:String
    private var priceLab:UILabel!
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.c_F8F8F8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuoteDetailListCell.self, forCellReuseIdentifier: "QuoteDetailListCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight/4.0))
        view.backgroundColor = AppColors.c_F8F8F8
        
        let bgView = UIView.init()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 8
        bgView.layer.masksToBounds = true
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        let gradientLabel = GradientLabelWithIndentedCorner(frame: .zero)
        gradientLabel.text = ""
        gradientLabel.startColor = .white
        gradientLabel.endColor = AppColors.c_FFB74A.withAlphaComponent(0.2)
        gradientLabel.cornerRadius = 15
        gradientLabel.frame.origin = CGPoint(x: 0, y: 0)
        gradientLabel.layer.borderWidth = 1
        gradientLabel.layer.borderColor =  UIColor.white.cgColor

        bgView.addSubview(gradientLabel)
        
        let textLab = UILabel.labelLayout(text: "" , font: FontSizes.medium12, textColor: AppColors.c_FFB74A, ali: .center, isPriority: true, tag: 0)
        gradientLabel.addSubview(textLab)
        textLab.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        viewModel.packageName.bind(to: textLab.rx.text,gradientLabel.rx.text).disposed(by: disposeBag)

   
        
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
        let bedRoomNumber = self.decorations.first { $0.type == .masterBedroom }?.number ?? 0
        let livingRoomNumber = self.decorations.first { $0.type == .livingDiningRoom }?.number ?? 0
        let bathroomNumber = self.decorations.first { $0.type == .masterBathroom }?.number ?? 0
        let descLab = UILabel.labelLayout(text: "\(bedRoomNumber)室\(livingRoomNumber)厅\(bathroomNumber)卫 · \(self.areaNum)m²", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        bgView.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.top.equalTo(priceLab.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        tableView.tableHeaderView = view
        
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
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
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(reserveBtn.snp.top).offset(-16)
        }
        
        requestData()
    }
    
    
    /// 初始化
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - isShowBack: <#isShowBack description#>
    ///   - decorations: 几室几厅
    ///   - areaNum: 面积
    ///   - packageId: 套餐 ID
    init(title: String, isShowBack: Bool = true,decorations:[DecorationTypeModel],areaNum:String,packageId:String) {
        self.decorations = decorations
        self.areaNum = areaNum
        self.packageId = packageId
        super.init(title: "", isShowBack: true)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestData() {
        let bedRoomNumber = self.decorations.first { $0.type == .masterBedroom }?.number ?? 0
        let livingRoomNumber = self.decorations.first { $0.type == .livingDiningRoom }?.number ?? 0
        let kitchenNumber = self.decorations.first { $0.type == .kitchen }?.number ?? 0
        let bathroomNumber = self.decorations.first { $0.type == .masterBathroom }?.number ?? 0
        
        viewModel.fetchQuickQuoteDetail(param: [
            "packageId": self.packageId,
            "area": self.areaNum,
            "bedroomNumber":bedRoomNumber,
            "livingRoomNumber":livingRoomNumber,
            "kitchenRoomNumber":kitchenNumber,
            "toiletRoomNumber":bathroomNumber
        ])
        
        viewModel.quickQuoteDetail.withUnretained(self).subscribe(onNext:{ vc,model in
            vc.tableView.reloadData()
            vc.priceLab.text = "\(vc.viewModel.quickQuoteDetail.value?.quickPriceResult.totalPrice ?? 0.0)"
        }).disposed(by: disposeBag)
    }
    
    
}

extension QuoteDetailController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.quickQuoteDetail.value?.material.count ?? 0

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = viewModel.quickQuoteDetail.value?.material[section].items
        {
            return items.count
        }
        return 0

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteDetailListCell", for: indexPath) as! QuoteDetailListCell
        let model = viewModel.quickQuoteDetail.value?.material[indexPath.section].items[indexPath.row]
        cell.model = model
    
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = AppColors.c_F8F8F8
        
        let containerView = UIView.init()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        
        let item = viewModel.quickQuoteDetail.value?.material[section]
        let titleLab  = UILabel.labelLayout(text: item?.budgetDisplay ?? "", font: FontSizes.medium14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        containerView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = AppColors.c_F8F8F8
        return view
    }
    
    
}


class GradientLabelWithIndentedCorner: UIView {
    
    private let label: UILabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    var cornerRadius: CGFloat = 20 {
        didSet { setNeedsDisplay() }
    }
    
    var startColor: UIColor = .blue {
        didSet { updateGradient() }
    }
    
    var endColor: UIColor = .purple {
        didSet { updateGradient() }
    }
    
    var text: String? {
        didSet {
            label.text = text
            updateFrame()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        label.numberOfLines = 0
        label.textColor = .clear
        label.font = FontSizes.medium12
        addSubview(label)
        
        layer.addSublayer(gradientLayer)
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        label.frame = bounds.insetBy(dx: 16, dy: 8)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.width - cornerRadius, y: rect.height),
                          controlPoint: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    private func updateFrame() {
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        frame.size = CGSize(width: size.width + 32, height: 20)
        setNeedsLayout()
    }
}
