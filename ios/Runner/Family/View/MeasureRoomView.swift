//
//  MeasureRoomView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/12.
//

import UIKit
import RxSwift
class MeasureRoomView: UIView {
    private let disposeBag = DisposeBag()
    private let viewModel = FurnishLogsViewModel()
    private var emptyView = BlankCanvasView()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (kScreenWidth - 3 * 16) / 2.0, height: (kScreenWidth - 3 * 16) / 2.0 + 30)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MeasureRoomListCell.self, forCellWithReuseIdentifier: "MeasureRoomListCell")
        collectionView.register(MeasureHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MeasureHeaderView")
        return collectionView
    }()

    init(frame:CGRect,customerProjectId:String) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.viewModel.projectId.accept(customerProjectId)
        
        let canvas = BlankCanvasView(frame: .zero)
        self.addSubview(canvas)
        canvas.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        canvas.isHidden = true
        canvas.refreshBlock = { [weak self] in
            self?.requestData()
        }
        
        self.emptyView = canvas
        requestData()

    }
    func requestData(){
        self.viewModel.fetchFurnishLogsMeasurePhotos(projectId: self.viewModel.projectId.value)
        self.viewModel.dataSource.withUnretained(self).subscribe(onNext: { owner, results in
            if results.count == 0 {
                owner.collectionView.isHidden = true
                owner.emptyView.isHidden = false
            }else{
                owner.collectionView.isHidden = false
                owner.emptyView.isHidden = true
                owner.collectionView.reloadData()
            }
        }).disposed(by: disposeBag)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MeasureRoomView: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.dataSource.value.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let model = self.viewModel.dataSource.value[section]
        return model.row?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeasureRoomListCell", for: indexPath) as! MeasureRoomListCell
        let model = self.viewModel.dataSource.value[indexPath.section].row?[indexPath.row]
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //头部高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: kScreenWidth, height: 30)
    }
    
    //头部视图
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MeasureHeaderView", for: indexPath) as! MeasureHeaderView
            let model = self.viewModel.dataSource.value[indexPath.section]
            header.titlleLab.text = model.typeDisplay ?? ""
            header.arrowBtn.isHidden = indexPath.section == 0 ? false : true
            return header
            
        } else {
            return UICollectionReusableView()
        }
    }
}
