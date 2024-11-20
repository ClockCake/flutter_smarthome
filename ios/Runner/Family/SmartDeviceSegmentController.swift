//
//  SmartDeviceSegmentController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/29.
//

import UIKit
import JXSegmentedView
class SmartDeviceSegmentController: BaseViewController {
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private let segmentedView = JXSegmentedView()
    private lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    private var homeId:Int64 = 0
    private var home:ThingSmartHome?
    private var roomModels:[ThingSmartRoomModel] = []

    init(title: String = "", isShowBack: Bool = true,homeId:Int64) {
        super.init(title: title, isShowBack: true)
        self.homeId = homeId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRoomList(homeId: self.homeId)
        self.titleLab.text = "所有设备"

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    ///获取该家庭下的所有房间信息
    func getRoomList(homeId:Int64){
        home = ThingSmartHome.init(homeId: homeId)
        home?.getDataWithSuccess({ [weak self] homeModels in
            guard let self = self else { return  }
            let model = ThingSmartRoomModel()
            model.name = "所有设备"
            self.roomModels.append(model)
            if let roomList = home?.roomList {
                for (_ , roomModel) in roomList.enumerated() {
                    self.roomModels.append(roomModel)
                }
            }
            self.addSegmentView()
        }, failure: { error in
            
        })
    }
    
    
    func addSegmentView() {
        let titles = self.roomModels.map({$0.name ?? ""})
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titleNormalColor = AppColors.c_999999
        dataSource.titleNormalFont = FontSizes.regular15
        dataSource.titleSelectedColor = AppColors.c_222222
        dataSource.titleSelectedFont = FontSizes.medium16
        dataSource.titles = titles
        dataSource.itemWidth = JXSegmentedViewAutomaticDimension
        self.segmentedDataSource = dataSource
        
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 15
        indicator.indicatorColor = AppColors.c_FFB26D
        segmentedView.indicators = [indicator]
        
        segmentedView.backgroundColor = .white
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        segmentedView.frame = CGRect(x: 0, y: kNavBarAndStatusBarHeight, width: view.bounds.size.width, height: segmentedTabHeight)
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalTo(0)
        }
        self.segmentedView.reloadDataWithoutListContainer()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SmartDeviceSegmentController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            return SmartDeviceListController.init(dataSource: home?.deviceList ?? [])
        }else{
            let model = self.roomModels[index - 1]
            let room = ThingSmartRoom(roomId: model.roomId, homeId: homeId)
            return SmartDeviceListController.init(dataSource: room?.deviceList ?? [])
        }
    }
    
}


extension SmartDeviceSegmentController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {

    }
}
