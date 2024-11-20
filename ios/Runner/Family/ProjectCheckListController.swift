//
//  ProjectCheckListController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/23.
//

import UIKit
import JXSegmentedView
class ProjectCheckListController: UIViewController {
    private var dataSource:[ProjectCheckRowModel] = []
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ProjectCheckListCell.self, forCellReuseIdentifier: "ProjectCheckListCell")
        return tableView
    }()
    
    init(data:[ProjectCheckRowModel]) {
        self.dataSource = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    

}
extension ProjectCheckListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension ProjectCheckListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCheckListCell", for: indexPath) as! ProjectCheckListCell
        let model = self.dataSource[indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
