//
//  QuoteSegmentSchemeController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/29.
//

import UIKit
import JXSegmentedView
import RxSwift
import RxRelay
class QuoteSegmentSchemeController: BaseViewController {
    private let disposeBag = DisposeBag()
    private var segmentedDataSource: JXSegmentedTitleDataSource?
    private let segmentedView = JXSegmentedView()
    private lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    private var arrowImg:UIImageView!
    private var bottomView:UIView!
    private var typeArr:[DecorationTypeModel] = []
    
    /// 全局监听 选中的套餐
    private var savePackageArr = BehaviorRelay<[PackageListModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBottomView()
        addSegmentView()
    }
    init(title: String, isShowBack: Bool = true,typeArr:[DecorationTypeModel]) {
        self.typeArr = typeArr
        super.init(title: title, isShowBack: isShowBack)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setBottomView() {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeHeight - 20)
            make.height.equalTo(60)
        }
        self.bottomView = bottomView
        let nextBtn = UIButton.init(title: "下一步", backgroundColor: .black, titleColor: .white, font: FontSizes.medium14, alignment: .center)
        bottomView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(136)
            make.centerY.equalToSuperview()
            make.height.equalTo(42)
        }
        nextBtn.layer.cornerRadius = 6
        nextBtn.layer.masksToBounds = true
        
        let popView = UIView.init()
        bottomView.addSubview(popView)
        popView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(nextBtn.snp.leading).offset(-20)
            make.top.bottom.equalToSuperview()
        }
        
        let imgView = UIImageView(image: UIImage(named: "icon_file"))
        popView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalTo(nextBtn)
            make.leading.equalToSuperview()
        }
        
        let titleLab = UILabel.labelLayout(text: "已选方案", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        popView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(imgView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
       ///SF Symbol  ^ 向上的箭头
        let arrowImg = UIImageView(image: UIImage(systemName: "chevron.up")?.withTintColor(.black, renderingMode: .alwaysOriginal))
        popView.addSubview(arrowImg)
        arrowImg.snp.makeConstraints { make in
            make.leading.equalTo(titleLab.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(6)
        }
        self.arrowImg = arrowImg
        popView.isSelect = false
        popView.rx.tapGesture().when(.recognized).withUnretained(self).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return  }
            popView.isSelect = !popView.isSelect
            if popView.isSelect == true {
                self.arrowImg.image = UIImage(systemName: "chevron.down")?.withTintColor(.black, renderingMode: .alwaysOriginal)
                self.savePackageArr.accept(self.savePackageArr.value.sorted { $0.index ?? 0 < $1.index ?? 0 })
                let view = SelectPackageView.init(frame: .zero, savePackageList: self.savePackageArr)
                view.tag = 101
                //获取window
                let window = UIApplication.shared.windows.first
                window?.addSubview(view)
                view.snp.makeConstraints { make in
                    make.leading.trailing.top.equalToSuperview()
                    make.bottom.equalTo(bottomView.snp.top)
                }
                view.closeCallBack = { [weak self] in
                    view.removeFromSuperview()
                    popView.isSelect = !popView.isSelect
                    self?.arrowImg.image = UIImage(systemName: "chevron.up")?.withTintColor(.black, renderingMode: .alwaysOriginal)

                }
            }
            else{
                let window = UIApplication.shared.windows.first
                let tagView =  window?.viewWithTag(101)
                if let view = tagView as? SelectPackageView {
                    //动画效果隐藏 tableView
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        view.tableView.snp.updateConstraints { make in
                            make.top.equalTo(view.snp.bottom)
                        }
                        view.layoutIfNeeded()
                    }, completion: { _ in
                        view.removeFromSuperview()
                    })
                }
                self.arrowImg.image = UIImage(systemName: "chevron.up")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            }

            
        }).disposed(by: disposeBag)
        
        //nextBtn 是否可点击绑定savePackageArr
        savePackageArr.withUnretained(self).subscribe(onNext: { (vc, value) in
            nextBtn.isEnabled = value.count > 0 ? true : false
            nextBtn.backgroundColor = value.count > 0 ? .black : .lightGray
            popView.isUserInteractionEnabled = value.count > 0 ? true : false
        }).disposed(by: disposeBag)
        
        nextBtn.rx.tap.withUnretained(self).subscribe(onNext: { owner , _  in
            let vc = QuoteMicroDetailController.init(title: "", savePackageArr:owner.savePackageArr)
            owner.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
    }
    func addSegmentView() {
        //组装数据
        var titles:[String] = []
        for (_ ,model) in typeArr.enumerated() {
            ///model.area 有值并且大于 0
            if let m2 = Double(model.area),m2 > 0.0 {
                titles.append("\(model.name) \(model.area)㎡")
            }
        }
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titleNormalColor = AppColors.c_999999
        dataSource.titleNormalFont = FontSizes.regular15
        dataSource.titleSelectedColor = AppColors.c_FFA555
        dataSource.titleSelectedFont = FontSizes.medium16
        dataSource.titles = titles
//        dataSource.itemWidth = kScreenWidth / CGFloat(titles.count)
        dataSource.itemSpacing = 40.0
        self.segmentedDataSource = dataSource
        
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 15
        indicator.indicatorColor = AppColors.c_FFA555
        segmentedView.indicators = [indicator]
        segmentedView.backgroundColor = .white
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        segmentedView.frame = CGRect(x: 0, y: kStatusBarHeight + 34.0, width: view.bounds.size.width, height: segmentedTabHeight)
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }


    }
}
extension QuoteSegmentSchemeController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        var arr:[DecorationTypeModel] = []
        for (_ ,model) in typeArr.enumerated() {
            ///model.area 有值并且大于 0
            if let m2 = Double(model.area),m2 > 0.0 {
                arr.append(model)
            }
        }
        let model = arr[index]
        let vc = QuoteSegmentListController(model: model,savePackageArr: self.savePackageArr,index: index + 1)
        return vc
    }
    
}


extension QuoteSegmentSchemeController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
}
