//
//  SmartDeviceReusableView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

import UIKit
import RxSwift
enum SmartDeviceReusableViewType {
    case common
    case deviceFilter
}


class SmartDeviceReusableView: UICollectionReusableView {
    public var titleLab: UILabel!
    private var currentType: SmartDeviceReusableViewType?
    private var filterBtn: UIButton?
    private var buttonView: HorizontalScrollingButtonsView?
    private var currentRooms: [ThingSmartRoomModel] = []
    private let disposeBag = DisposeBag()
    private var arrowImageView:UIImageView!
    //房间按钮点击回调
    var onButtonTapped: ((Int) -> Void)?
    // 家庭管理回调
    var onFamilyManageTapped: (() -> Void)?
    //全部设备点击回调
    var onAllDevicesTapped: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private func setupCommonUI() {
        titleLab = UILabel.labelLayout(text: "", font: FontSizes.medium16, textColor: AppColors.c_333333, ali: .left, isPriority: false, tag: 0)
        addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16) // 设定图像大小为 12 点
        let image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        let tintedImage = image?.withTintColor(AppColors.c_333333)
        let imageView = UIImageView(image: tintedImage)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
            make.leading.equalTo(titleLab.snp.trailing).offset(8)
        }
        self.arrowImageView = imageView
        imageView.isHidden = true
        let titleLabTap = titleLab.rx.tapGesture().when(.recognized)
        let imageViewTap = imageView.rx.tapGesture().when(.recognized)

        Observable.merge(titleLabTap, imageViewTap)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.currentType == .deviceFilter {
                    owner.onFamilyManageTapped?()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configure(for type: SmartDeviceReusableViewType, rooms: [ThingSmartRoomModel]? = nil) {
        currentType = type
        updateUIForCurrentType()
        
        if type == .deviceFilter, let rooms = rooms {
            currentRooms = rooms
            updateRoomButtons()
        } else {
            buttonView?.isHidden = true
            self.arrowImageView.isHidden = true
        }
    }
    
    private func updateUIForCurrentType() {
        switch currentType {
        case .common:
            filterBtn?.isHidden = true
            buttonView?.isHidden = true
            arrowImageView.isHidden = true
        case .deviceFilter:
            setupDeviceFilterUIIfNeeded()
            filterBtn?.isHidden = false
            buttonView?.isHidden = false
            arrowImageView.isHidden = false
        case .none:
            break
        }
    }
    
    private func setupDeviceFilterUIIfNeeded() {
        if filterBtn == nil {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12) // 设定图像大小为 12 点
            let image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
            let tintedImage = image?.withTintColor(AppColors.c_999999)
            filterBtn = UIButton(title: "全部设备", backgroundColor: .clear, titleColor: AppColors.c_999999, font: FontSizes.regular12, alignment: .right,image: tintedImage)
            filterBtn?.adjustTitleAndImage(spacing: 8.0)
            if let filterBtn = filterBtn {
                addSubview(filterBtn)
                filterBtn.snp.makeConstraints { make in
                    make.centerY.equalTo(titleLab)
                    make.trailing.equalToSuperview().offset(-0)
                }
            }
            filterBtn?.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.onAllDevicesTapped?()
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func updateRoomButtons() {
        let items = currentRooms.map { $0.name ?? "" }
        if let existingButtonView = buttonView {
            existingButtonView.updateButtons(with: items)
            existingButtonView.isHidden = false
            if existingButtonView.superview == nil {
                addSubview(existingButtonView)
                setupButtonViewConstraints(existingButtonView)
            }
            self.arrowImageView.isHidden = false

        } else {
            let newButtonView = HorizontalScrollingButtonsView(items: items)
            buttonView = newButtonView
            addSubview(newButtonView)
            setupButtonViewConstraints(newButtonView)
            newButtonView.onButtonTapped = { [weak self] index in
                print("Button tapped at index: \(index)")
                self?.onButtonTapped?(index)
            }
            self.arrowImageView.isHidden = false

        }
    }
    
    private func setupButtonViewConstraints(_ buttonView: HorizontalScrollingButtonsView) {
        buttonView.snp.remakeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLab.text = ""
        filterBtn?.isHidden = true
        buttonView?.isHidden = true
        arrowImageView.isHidden = true
        // 保持 currentType 和 currentRooms 不变
    }
    
    deinit {
        print("SmartDeviceReusableView deinitialized")
    }
}
