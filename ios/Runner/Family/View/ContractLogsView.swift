//
//  ContractLogsView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
import RxSwift
class ContractLogsView: UIView {
    private let disposeBag = DisposeBag()
    private let viewModel = FurnishLogsViewModel()
    private var emptyView = BlankCanvasView()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = AppColors.c_F8F8F8
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContractLogsCell.self, forCellReuseIdentifier: "ContractLogsCell")
        let footView = UIView.init()
        footView.backgroundColor = AppColors.c_F8F8F8
        tableView.tableFooterView = footView
        return tableView
    }()
    init(frame: CGRect,customerProjectId:String) {
        super.init(frame: frame)
        self.viewModel.projectId.accept(customerProjectId)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let canvas = BlankCanvasView(frame: .zero)
        self.addSubview(canvas)
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
    func requestData() {
        self.viewModel.fetchContractList(projectId: self.viewModel.projectId.value)
        self.viewModel.contractList.withUnretained(self).subscribe(onNext: { owner, results in
            if results.count == 0 {
                owner.tableView.isHidden = true
                owner.emptyView.isHidden = false
            }else{
                owner.tableView.isHidden = false
                owner.emptyView.isHidden = true
                owner.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ContractLogsView:UITableViewDelegate,UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.contractList.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContractLogsCell", for: indexPath) as! ContractLogsCell
        cell.selectionStyle = .none
        let model = self.viewModel.contractList.value[indexPath.row]
        cell.model = model
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = .clear
        let titleLab = UILabel.labelLayout(text: "合同信息", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.viewModel.contractList.value[indexPath.row]
        let vc = ContractDetailViewController.init(contractId: model.contractId ?? "")
        UINavigationController.getCurrentNavigationController()?.pushViewController(vc, animated: true)
    }
}
