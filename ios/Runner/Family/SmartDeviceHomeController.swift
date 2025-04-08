//
//  SmartDeviceHomeController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

import UIKit
import RxSwift
class SmartDeviceHomeController: BaseViewController {
    private let disposeBag = DisposeBag()
    //进入配网的按钮
    private var addDeviceImageBtn:UIImageView!
    //涂鸦家庭管理
    private let homeManager = ThingSmartHomeManager()
    
    private var home:ThingSmartHome?
    //设备列表
    private var deviceModels:[ThingSmartDeviceModel] = []
    // 房间列表
    private var roomModels:[ThingSmartRoomModel] = []
    //选中的家庭 ID
    private var selectHomeId:Int64 = 0
    
    //是否需要刷新设备列表的头部
    private var needRefreshHeader = true

    private var selectModel:ThingSmartDeviceModel?
    
    func updateCollectionViewHeight(height: CGFloat) {
          collectionView.snp.updateConstraints { make in
              make.height.equalTo(height)
          }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLab.text = ""
        self.backArrowButton.isHidden = true
        registerProtocol()
        self.customNavBar.backgroundColor = UIColor.white.withAlphaComponent(0)
        let imageBtn = UIImageView.init(image: UIImage(systemName: "plus.circle"))
        imageBtn.tintColor = .white
        self.customNavBar.addSubview(imageBtn)
        imageBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight + 5.0)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        self.addDeviceImageBtn = imageBtn
        // 禁用自动调整行为
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        self.view.bringSubviewToFront(self.customNavBar)
        
        refreshData()

        imageBtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            let impl = ThingSmartBizCore.sharedInstance().service(of: ThingActivatorProtocol.self) as? ThingActivatorProtocol
            impl?.gotoCategoryViewController()
            //配网后的回调
            impl?.activatorCompletion(.normal, customJump: false, completionBlock: { [weak self] (evIdList:[Any]?) in
                guard let self = self else { return  }
                self.getDeviceList(homeId: self.selectHomeId, roomId: 0)
            })

        }).disposed(by: disposeBag)
        
        
        let projectBtn = UIImageView.init(image:UIImage(named: "icon_project_checklist"))
        self.customNavBar.addSubview(projectBtn)
        projectBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight + 5.0)
            make.trailing.equalTo(imageBtn.snp.leading).offset(-16)
            make.width.height.equalTo(24)
        }
        
        projectBtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            // 先请求使用时定位权限
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                // 通知 Flutter 显示项目列表页面
                appDelegate.navigateToFlutterRoute("showProjectList")
            }
        }).disposed(by: disposeBag)
 

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true) //防止 flutter 工程中出现导航栏
    }

    //子类重写刷新的方法
    override func refreshData() {
        super.refreshData()
        if UserManager.shared.isLoggedIn {
            collectionView.isHidden = false
            needRefreshHeader = true
            self.roomModels.removeAll()
            ///请求数据
            getHomeList()
            

        }else{
            collectionView.isHidden = true
        }
        ///请求数据
        getHomeList()
        
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerProtocol(){
        //注册协议
        ThingSmartBizCore.sharedInstance().registerService(ThingSmartHomeDataProtocol.self, withInstance: self)
        ThingSmartBizCore.sharedInstance().registerService(ThingSmartHouseIndexProtocol.self, withInstance: self)
        ThingSmartBizCore.sharedInstance().registerService(ThingFamilyProtocol.self, withInstance: self)

    }

    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SmartDeviceReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SmartDeviceReusableView")  //分区表头
        collectionView.register(SmartDeviceHomeHeaderCell.self, forCellWithReuseIdentifier: "SmartDeviceHomeHeaderCell")  ///头部 Cell
        collectionView.register(SmartDeviceInspirationListCell.self, forCellWithReuseIdentifier: "SmartDeviceInspirationListCell") //灵感来源
        collectionView.register(SmartDeviceListCell.self, forCellWithReuseIdentifier: "SmartDeviceListCell")  //智能设备列表
        return collectionView
    }()
}



extension SmartDeviceHomeController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1: //随心搭/智能设备列表
            return self.deviceModels.count
        case 2:
            return 10
        default:
            return 0
        }
    }
    
    // 设置 section 的边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
    
    // 设置每行之间的最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    // 设置同一行的 item 之间的最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: kScreenWidth, height: kStatusBarHeight + 250)
        case 1: //随心搭/智能设备列表
//            return CGSize(width: kScreenWidth, height: 200)
            return CGSize(width: (kScreenWidth - 48) / 2.0, height: 130)
        case 2:
            return CGSize(width: kScreenWidth, height: 280)
        default:
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return .zero
        case 1: //随心搭/智能设备列表
        //    return CGSize(width: kScreenWidth, height: 40)
            return CGSize(width: kScreenWidth, height: 80)
        case 2:
            return CGSize(width: kScreenWidth, height: 40)
        default:
            return .zero
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SmartDeviceReusableView", for: indexPath) as! SmartDeviceReusableView
            switch indexPath.section {
            case 1:
                if self.roomModels.count == 0 {
                    return header
                }
                header.configure(for: .deviceFilter, rooms: self.roomModels)
                //全部设备的回调
                header.onAllDevicesTapped = { [weak self] in
                    guard let self = self else { return  }
                    let vc = SmartDeviceSegmentController.init(homeId: self.selectHomeId)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                //房间按钮点击回调
                header.onButtonTapped = { [weak self] index in
                    guard let self = self else { return }
                    let roomId = self.roomModels[index].roomId
                    self.getDeviceList(homeId: self.selectHomeId, roomId: roomId)
                }

            case 2:
                header.configure(for: .common)
                header.titleLab.text = "灵感来源"

            default:
                header.configure(for: .common)
                header.titleLab.text = ""
            }
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmartDeviceHomeHeaderCell", for: indexPath) as! SmartDeviceHomeHeaderCell
            cell.titleLab.text = self.homeManager.homes.first?.name ?? ""
            cell.toogleBtnAction = { [weak self] in
                guard let self = self else { return  }
                let vc = SmartHomeFamilysController(data: self.homeManager.homes)
                self.navigationController?.pushViewController(vc, animated: true)
                vc.onFamilyTapped = { [weak self] model in
                    guard let self = self else { return  }
                    self.roomModels.removeAll()
                    self.selectHomeId = model.homeId
                    cell.titleLab.text = model.name
                    self.needRefreshHeader = true
                    self.getRoomList(homeId: model.homeId)
                }
            }
            
            cell.imageViewTapAction = { [weak self] in
                guard let self = self else { return }
                let vc = QuoteSceneWebViewController(title: "", isShowBack: false, model: self.selectModel ?? ThingSmartDeviceModel())
                self.navigationController?.pushViewController(vc, animated: true)
            }
          
            return cell
        case 1: //随心搭/智能设备列表
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmartDeviceListCell", for: indexPath) as! SmartDeviceListCell
            let model = self.deviceModels[indexPath.row]
            cell.model = model
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmartDeviceInspirationListCell", for: indexPath) as! SmartDeviceInspirationListCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let model = self.deviceModels[indexPath.row]
            self.selectModel = model
            let impl = ThingSmartBizCore.sharedInstance().service(of: ThingPanelProtocol.self) as? ThingPanelProtocol
            impl?.gotoPanelViewController(withDevice: model, group: nil, initialProps: nil, contextProps: nil, completion: nil)
        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        // 假设初始偏移量为0，即从顶部开始滚动
        let initialOffset: CGFloat = 0.0

        // 设置透明度变化的最大偏移量
        let maxOffsetForFullAlpha: CGFloat = 200.0 + kStatusBarHeight

        // 计算透明度
        // 当滚动偏移量大于初始偏移量时，透明度增加
        let alpha = offsetY > initialOffset ? min((offsetY - initialOffset) / maxOffsetForFullAlpha, 1) : 0

        // 应用透明度到 customNavBar
        customNavBar.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        self.titleLab.textColor = UIColor.black.withAlphaComponent(alpha)
        
        let toBlackColor = UIColor.white.lerp(to: .black, amount: alpha)
        addDeviceImageBtn.image = UIImage(systemName: "plus.circle")?.withTintColor(toBlackColor)?.withRenderingMode(.alwaysOriginal)

    }
}

//涂鸦扩展
extension SmartDeviceHomeController {
    
    /// 获取所有家庭信息
    func getHomeList(){
        homeManager.getHomeList { [weak self] homes in
            guard let self = self else { return }
            if homes?.count ?? 0 > 0 {
                self.selectHomeId = self.homeManager.homes.first?.homeId ?? 0
                self.getRoomList(homeId: self.selectHomeId)
            }
        } failure: { error in
            print("获取家庭失败")
        }
    }
    ///获取该家庭下的所有房间信息
    func getRoomList(homeId:Int64){
        home = ThingSmartHome.init(homeId: homeId)
        home?.getDataWithSuccess({ [weak self] homeModels in
            guard let self = self else { return  }
            
//            let model = ThingSmartRoomModel()
//            model.name = "所有设备"
//            self.roomModels.append(model)
            if let roomList = home?.roomList {
                for (_ , roomModel) in roomList.enumerated() {
                    self.roomModels.append(roomModel)
                }
            }
            self.getDeviceList(homeId: self.selectHomeId, roomId:self.roomModels.first?.roomId ?? 0)
            //更新家庭 ID
            let impl = ThingSmartBizCore.sharedInstance().service(of: ThingFamilyProtocol.self) as? ThingFamilyProtocol
            impl?.updateCurrentFamilyId?(self.selectHomeId)
        }, failure: { error in
            
        })
    }
    
    
    /// 获取该房间下的设备信息
    /// - Parameters:
    ///   - homeId: <#homeId description#>
    ///   - roomId: <#roomId description#>
    /// - Returns: <#description#>
    func getDeviceList(homeId: Int64, roomId: Int64) {
        // 保存旧的设备数量
        let oldDeviceCount = self.deviceModels.count

        // 更新设备列表
//        if roomId == 0 {
//            self.deviceModels = self.home?.deviceList ?? []
//        } else {
//            let room = ThingSmartRoom(roomId: roomId, homeId: homeId)
//            self.deviceModels = room?.deviceList ?? []
//        }
        let room = ThingSmartRoom(roomId: roomId, homeId: homeId)
        self.deviceModels = room?.deviceList ?? []
        // 获取新的设备数量
        let newDeviceCount = self.deviceModels.count
        
        if needRefreshHeader == true {
            // 如果设备列表变化可能影响其他部分（例如 header），可能需要刷新整个 section
            self.collectionView.reloadSections(IndexSet(integer: 1))
            needRefreshHeader = false
            return
        }

        // 计算需要刷新的索引路径
        let indexPaths = (0..<max(oldDeviceCount, newDeviceCount)).map { IndexPath(item: $0, section: 1) }

        self.collectionView.performBatchUpdates({
            if newDeviceCount > oldDeviceCount {
                // 需要插入新项目
                let insertIndexPaths = (oldDeviceCount..<newDeviceCount).map { IndexPath(item: $0, section: 1) }
                self.collectionView.insertItems(at: insertIndexPaths)
            } else if newDeviceCount < oldDeviceCount {
                // 需要删除项目
                let deleteIndexPaths = (newDeviceCount..<oldDeviceCount).map { IndexPath(item: $0, section: 1) }
                self.collectionView.deleteItems(at: deleteIndexPaths)
            }
            
            // 无论如何，都刷新所有现有项目
            self.collectionView.reloadItems(at: indexPaths)
        }, completion: nil)

    }
    func homeAdminValidation() ->Bool {
        return true
    }
}
