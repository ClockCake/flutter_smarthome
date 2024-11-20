//
//  QuoteSegmentListController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/29.
//

import UIKit
import JXSegmentedView
import RxSwift
import RxRelay
import MJRefresh
class QuoteSegmentListController: UIViewController {
    private var senderModel:DecorationTypeModel?
    private let disposeBag = DisposeBag()
    private let viewModel = PackageViewModel()
    private var index:Int = 0
    private var savePackageArr = BehaviorRelay<[PackageListModel]>(value: [])
    private var emptyView = BlankCanvasView()

    init(model:DecorationTypeModel,savePackageArr:BehaviorRelay<[PackageListModel]>,index:Int) {
        self.senderModel = model
        self.savePackageArr = savePackageArr
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuoteSegmentListCell.self, forCellReuseIdentifier: "QuoteSegmentListCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.requestData()
        })
        return tableView
    }()
    
    func requestData() {
        var paramType = ""
        switch self.senderModel?.type {
        case .kitchen:
            paramType = "1"
        case .masterBathroom:
            paramType = "9"
        case .wallRefresh:
            paramType = "28"
        default:
            break
        }
        self.viewModel.fetchMicroPackageList(type: paramType)
        viewModel.packageList.subscribe(onNext:{ [weak self] packages in
            guard let self = self else { return  }
            if packages.count == 0 {
                self.emptyView.isHidden = false
                self.tableView.isHidden = true
            }else{
                self.emptyView.isHidden = true
                self.tableView.isHidden = false
                for (_ ,packageModel) in packages.enumerated(){
                    packageModel.isSelected = false
                    packageModel.areaNum = self.senderModel?.area
                    packageModel.name = self.senderModel?.name
                    packageModel.index = self.index
                    packageModel.type = self.senderModel?.type
                }
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
            }

        }).disposed(by: disposeBag)
    }
}

extension QuoteSegmentListController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.packageList.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
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

        
        let descLab = UILabel.labelLayout(text: "\(self.senderModel?.name ?? "") · \(self.senderModel?.area ?? "")㎡", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        headerView.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        return footerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteSegmentListCell", for: indexPath) as! QuoteSegmentListCell
        cell.selectionStyle = .none
        let model = self.viewModel.packageList.value[indexPath.row]
        cell.model = model
        cell.buttonCallBack = { [weak self] in
            guard let self = self else { return  }
            self.reloadListData(model: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
extension QuoteSegmentListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

/// 此扩展专门用于数据处理
extension QuoteSegmentListController {
    func reloadListData(model:PackageListModel) {
        var updatedArray = self.savePackageArr.value

        for (index, item) in updatedArray.enumerated() {
            if item.index == self.index {
                updatedArray.remove(at: index)
                break
            }
        }

        let _ = self.viewModel.packageList.value.map({$0.isSelected = false})
        model.isSelected = true
        
        updatedArray.append(model)
        self.savePackageArr.accept(updatedArray)
        self.tableView.reloadData()
    }
}
