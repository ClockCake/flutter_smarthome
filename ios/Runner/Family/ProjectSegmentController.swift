//
//  ProjectSegmentController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/23.
//  项目清单

import UIKit
import RxSwift
import JXSegmentedView
class ProjectSegmentController: BaseViewController {
    private let viewModel = FurnishLogsViewModel()
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private let segmentedView = JXSegmentedView()
    private lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    private let disposeBag = DisposeBag()
    
    init(title: String = "", isShowBack: Bool = true,contractId:String) {
        super.init()
        self.viewModel.projectContractId.accept(contractId)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "项目清单"
        self.viewModel.projectCheckList.skip(1).withUnretained(self).subscribe(onNext: { owner, data in
            owner.addSegmentView()
        }).disposed(by: disposeBag)
    }
    

    func addSegmentView() {
        let titles = self.viewModel.projectCheckList.value.map { "\($0.roomName ?? "")\($0.landArea ?? 0.0)m²" }
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
}
extension ProjectSegmentController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let model = self.viewModel.projectCheckList.value[index]
        return ProjectCheckListController.init(data: model.rows ?? [])
    }
    
}


extension ProjectSegmentController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {

    }
}
