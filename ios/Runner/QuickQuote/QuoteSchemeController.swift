//
//  QuoteSchemeController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/29.
//  整装/软装报价方案列表

import UIKit
import RxSwift
import MJRefresh
class QuoteSchemeController: BaseViewController {
    private let viewModel = PackageViewModel()
    private let disposeBag = DisposeBag()
    private var param = ""
    private var decorations:[DecorationTypeModel]
    private var areaNum:String
    private var type:QuickQuoteType = .wholeHouse
    private var emptyView = BlankCanvasView()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuoteSchemeListCell.self, forCellReuseIdentifier: "QuoteSchemeListCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.requestData()
        })
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = ""
        self.view.addSubview(tableView)
        self.tableView.backgroundColor = .white
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeHeight)
        }
        let canvas = BlankCanvasView(frame: .zero)
        self.view.addSubview(canvas)
        canvas.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        canvas.isHidden = true
        canvas.refreshBlock = { [weak self] in
            self?.requestData()
        }
        
        self.emptyView = canvas
        
        requestData()
    }
    init(title: String, isShowBack: Bool = true,decorations:[DecorationTypeModel],type:QuickQuoteType,areaNum:String) {
        switch type {
        case .wholeHouse:
            param = "whole"
        case .softDecoration:
            param = "soft-loading"
        default:
            break
        }
        self.decorations = decorations
        self.areaNum = areaNum
        self.type = type
        super.init(title: title, isShowBack: isShowBack)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 网络请求
    func requestData() {
        // 触发数据获取
        viewModel.fetchPackageList(type: param)
        viewModel.packageList.withUnretained(self).subscribe(onNext:{ (vc,packages) in
            if packages.count == 0 {
                vc.emptyView.isHidden = false
                vc.tableView.isHidden = true
            }
            else {
                vc.emptyView.isHidden = true
                vc.tableView.isHidden = false
                for (_ ,item) in packages.enumerated() {
                    item.style = vc.type
                }
                vc.tableView.reloadData()
                vc.tableView.mj_header?.endRefreshing()
            }

        }).disposed(by: disposeBag)
    }
    
}

extension QuoteSchemeController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.packageList.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let titleLabel = UILabel.labelLayout(text: "选择方案", font: FontSizes.medium20, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(12)
        }
        
        let bedRoomNumber = self.decorations.first { $0.type == .masterBedroom }?.number ?? 0
        let livingRoomNumber = self.decorations.first { $0.type == .livingDiningRoom }?.number ?? 0
        let toiletRoomNumber = self.decorations.first { $0.type == .masterBathroom }?.number ?? 0
        var title = ""
        if let num = Int(self.areaNum),num > 0 {
            title = "\(bedRoomNumber)室\(livingRoomNumber)厅\(toiletRoomNumber)卫・\(self.areaNum)m²"
        }else{
            title = "\(bedRoomNumber)室\(livingRoomNumber)厅"
        }
        let descLab = UILabel.labelLayout(text: title, font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        headerView.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteSchemeListCell", for: indexPath) as! QuoteSchemeListCell
        cell.selectionStyle = .none
        let model = viewModel.packageList.value[indexPath.row]
        model.areaNum = self.areaNum
        cell.model = model
        cell.buttonCallBack = { [weak self] in
            guard let self = self else { return  }
            let model = viewModel.packageList.value[indexPath.row]
            switch self.type {
            case .wholeHouse:
                let vc = QuoteDetailController(title: "", decorations: self.decorations, areaNum: self.areaNum, packageId: model.packageId)
                self.navigationController?.pushViewController(vc, animated: true)
            case .softDecoration:
                let vc = QuoteSegmentStyleController.init(title: "", isShowBack: true, typeArr: self.decorations,packageId: model.packageId)
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
