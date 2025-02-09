//
//  SmartHomeFamilysController.swift
//  Runner
//
//  Created by huangyaodong on 2025/2/9.
//

import UIKit
import RxSwift
class SmartHomeFamilysController: BaseViewController {
    private var dataSource:[ThingSmartHomeModel] = []
    //点击回调
    var onFamilyTapped: ((ThingSmartHomeModel) -> Void)?
    private let disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    init(data:[ThingSmartHomeModel]) {
        self.dataSource = data
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "icon_family_manager"))
        self.customNavBar.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLab)
            make.trailing.equalTo(self.customNavBar).offset(-16)
            make.width.height.equalTo(24)
        }
        imageView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let impl = ThingSmartBizCore.sharedInstance().service(of: ThingFamilyProtocol.self) as? ThingFamilyProtocol else {
                    return
                }
                impl.gotoFamilyManagement?()
            }).disposed(by: disposeBag)
        self.titleLab.text = "我的家"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(customNavBar.snp.bottom)
        }

    }
    
}
extension SmartHomeFamilysController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = self.dataSource[indexPath.row]
        cell.textLabel?.text = model.name
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSource[indexPath.row]
        if let callback = self.onFamilyTapped {
            callback(model)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
