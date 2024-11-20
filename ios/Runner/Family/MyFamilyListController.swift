//
//  MyFamilyListController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/11.
//

import UIKit
import MJRefresh
import RxSwift
class MyFamilyListController: BaseViewController {
    private let disposeBag = DisposeBag()
    private var dataSource:[PropertyInfo] = []

    //点击回调
    var clickFamilyCell:((PropertyInfo)->Void)?
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(FamilyListCell.self, forCellReuseIdentifier: "FamilyListCell")
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.tableView.mj_header?.endRefreshing()
        })
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "我的家"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        let canvas = BlankCanvasView(frame: .zero)
        self.view.addSubview(canvas)
        canvas.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        canvas.isHidden = true
        canvas.refreshBlock = { [weak self] in
            
        }
        if self.dataSource.count == 0 {
            canvas.isHidden = false
            tableView.isHidden = true
        }else{
            canvas.isHidden = true
            tableView.isHidden = false
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    init(title: String = "", isShowBack: Bool = true,dataSource:[PropertyInfo]) {
        super.init()
        self.dataSource = dataSource
        
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyFamilyListController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyListCell", for: indexPath) as! FamilyListCell
        cell.model = self.dataSource[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSource[indexPath.row]
        if let clickFamilyCell = clickFamilyCell {
            clickFamilyCell(model)
        }
        self.navigationController?.popViewController(animated: true)
    }


}
