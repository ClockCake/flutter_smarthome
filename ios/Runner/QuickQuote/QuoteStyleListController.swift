//
//  QuoteStyleListController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/31.
//

import UIKit
import JXSegmentedView
import RxSwift
import RxRelay
import MJRefresh
class QuoteStyleListController: UIViewController {
    private var senderModel:DecorationTypeModel?
    private let disposeBag = DisposeBag()
    private let viewModel = PackageViewModel()
    private var index:Int = 0
    private var packageId:String = ""
    private var savePackageArr = BehaviorRelay<[SoftDecorationStyleListModel]>(value: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLab = UILabel.labelLayout(text: "选择风格・套餐包名称", font: FontSizes.medium20, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        requestData()
        
        // Do any additional setup after loading the view.
    }
    init(model:DecorationTypeModel,savePackageArr:BehaviorRelay<[SoftDecorationStyleListModel]>,index:Int,packageId:String) {
        self.senderModel = model
        self.savePackageArr = savePackageArr
        self.index = index
        self.packageId = packageId
        

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: (kScreenWidth - 48) / 2, height:(kScreenWidth - 48) / 2 + 40 )
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.register(SoftDecorationStyleListCell.self, forCellWithReuseIdentifier: "SoftDecorationStyleListCell")
        return collectionView
    }()
    
    func requestData(){
        var roomType = 0
        switch self.senderModel?.type {
        case .restaurant:
            roomType = 5
        case .masterBedroom:
            roomType = 6
        case .livingDiningRoom:
            roomType = 7
        default:
            break
        }
        viewModel.fetchSoftDecorationStyle(packageId: packageId, roomType: roomType)
        viewModel.softDecorationStyleList.withUnretained(self).subscribe { (vc , results) in
            for (_ ,model) in results.enumerated() {
                model.index = vc.index
            }
            vc.collectionView.reloadData()
        }.disposed(by: disposeBag)
    }
}

extension QuoteStyleListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.softDecorationStyleList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoftDecorationStyleListCell", for: indexPath) as! SoftDecorationStyleListCell
        let model = self.viewModel.softDecorationStyleList.value[indexPath.row]
        cell.model = model
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = self.viewModel.softDecorationStyleList.value.map({$0.isSelected = false})

        let model = self.viewModel.softDecorationStyleList.value[indexPath.row]
        model.isSelected = true
        
        var updatedArray = self.savePackageArr.value

        for (index, item) in updatedArray.enumerated() {
            if item.index == self.index {
                updatedArray.remove(at: index)
                break
            }
        }        
        updatedArray.append(model)
        self.savePackageArr.accept(updatedArray)
        
        self.collectionView.reloadData()


    }
}


extension QuoteStyleListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
