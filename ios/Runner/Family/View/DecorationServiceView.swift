//
//  DecorationServiceView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/13.
//

import UIKit

class DecorationServiceView: UIView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DecorationServiceListCell.self, forCellReuseIdentifier: "DecorationServiceListCell")
        let view = self.setHeaderView()
        tableView.tableHeaderView = view
        return tableView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeaderView() ->UIView {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 120))
        view.backgroundColor = .white
        let titleLab = UILabel.labelLayout(text: "装修时长", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        let arrowBtn = UIButton.init(title: "查看施工计划 >", backgroundColor: .clear, titleColor: AppColors.c_999999, font: FontSizes.regular12, alignment: .right)
        view.addSubview(arrowBtn)
        arrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
        }
        
        let startTimeLab = UILabel.labelLayout(text: "总时长：50天                  实际开工日期：2021-09-11", font: FontSizes.regular13, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        view.addSubview(startTimeLab)
        startTimeLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(24)
        }
        
        let endTimeLab = UILabel.labelLayout(text: "工作日：34天                  计划竣工日期：2021-12-12", font: FontSizes.regular13, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        view.addSubview(endTimeLab)
        endTimeLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(startTimeLab.snp.bottom).offset(8)
        }
        
        
        return view
    }
}


extension DecorationServiceView:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DecorationServiceListCell", for: indexPath) as! DecorationServiceListCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = .clear
        let titleLab = UILabel.labelLayout(text: "施工进度", font: FontSizes.medium16, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        let proportionLab = UILabel.labelLayout(text: "15%", font: FontSizes.regular11, textColor: .white, ali: .center, isPriority: true, tag: 0)
        proportionLab.backgroundColor = AppColors.c_FFA555
        proportionLab.layer.cornerRadius = 9
        proportionLab.layer.masksToBounds = true
        view.addSubview(proportionLab)
        proportionLab.snp.makeConstraints { make in
            make.leading.equalTo(titleLab.snp.trailing).offset(8)
            make.centerY.equalTo(titleLab)
            make.width.equalTo(34)
            make.height.equalTo(18)
        }

        let progressView = LinearProgressBar(frame: CGRect(x: 16, y: 50, width: kScreenWidth - 32, height: 10))
        view.addSubview(progressView)
        progressView.progress = 0.75  // 设置为 75% 的进度
        
        return view
    }
}
