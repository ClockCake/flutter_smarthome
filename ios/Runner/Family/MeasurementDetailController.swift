//
//  MeasurementDetailController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//  量房详情

import UIKit
import RxSwift
class MeasurementDetailController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = MeasurementViewModel()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(MeasurementDetailCell.self, forCellReuseIdentifier: "MeasurementDetailCell")
        return tableView
    }()
    init(title: String = "", isShowBack: Bool = true,projectId:String) {
        super.init()
        self.viewModel.projectId.accept(projectId)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "量房参数"
        setUI()
        self.viewModel.dataSource.withUnretained(self).subscribe(onNext: { owner, _ in
            owner.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
   
    func setUI() {
        let bottomButton = UIButton.init(title: "确认", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center)
        bottomButton.layer.cornerRadius = 8
        bottomButton.layer.masksToBounds = true
        self.view.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20 - kSafeHeight)
            make.height.equalTo(48)
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(customNavBar.snp.bottom)
            make.bottom.equalTo(bottomButton.snp.top).offset(-20)
        }
        bottomButton.rx.tap.withUnretained(self).subscribe(onNext: { owner , _ in
            owner.submitRequest()
        }).disposed(by: disposeBag)
        
    }
    
    /// 确认量房参数的网络请求
    func submitRequest(){
        self.viewModel.postMeasurementDetail()
        self.viewModel.submitSuccess.withUnretained(self).subscribe(onNext: { owner, result in
            if result {
                owner.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
    }
}

extension MeasurementDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementDetailCell", for: indexPath) as! MeasurementDetailCell
        cell.selectionStyle = .none
        let model = self.viewModel.dataSource.value[indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = .white
        let containView = UIView.init()
        containView.backgroundColor = AppColors.c_FFF9EE
        view.addSubview(containView)
        containView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        let icon = UIImageView(image: UIImage(named: "icon_measurement_info"))
        containView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(14)
        }
        
        let titleLab = UILabel.labelLayout(text: "量房参数将影响人工和材料的数量；如无疑问请确认该量房参数，如有疑问请联系设计师", font: FontSizes.regular12, textColor: AppColors.c_CA9C72, ali: .left, isPriority: true, tag: 0)
        titleLab.numberOfLines = 0
        containView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        
        return view
    }
    
}
