//
//  SmartDeviceListController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/29.
//

import UIKit
import JXSegmentedView

class SmartDeviceListController: UIViewController {
    private var dataSource:[ThingSmartDeviceModel] = []
    lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(SmartDeviceSegmentListCell.self, forCellReuseIdentifier: "SmartDeviceSegmentListCell")
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    init(dataSource:[ThingSmartDeviceModel]) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
                            
                            required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                            override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}
extension SmartDeviceListController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmartDeviceSegmentListCell", for: indexPath) as! SmartDeviceSegmentListCell
        cell.model = self.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}


extension SmartDeviceListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
