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
    private var buttonView: HorizontalScrollingButtonsView?
    private var currentRooms: [ThingSmartRoomModel] = []
    private let disposeBag = DisposeBag()
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
        let hangView = UIView.init()
        addSubview(hangView)
        hangView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        hangView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.onAllDevicesTapped?()
            })
            .disposed(by: disposeBag)
        
        let titleLab = UILabel.labelLayout(text: "全部设备", font: FontSizes.medium16, textColor: AppColors.c_333333, ali: .left, isPriority: false, tag: 0)
        hangView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        self.titleLab = titleLab

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16) // 设定图像大小为 12 点
        let image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        let tintedImage = image?.withTintColor(AppColors.c_333333)
        let imageView = UIImageView(image: tintedImage)
        hangView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
            make.trailing.equalToSuperview().offset(-16)
        }
        
    }
    
    func configure(for type: SmartDeviceReusableViewType, rooms: [ThingSmartRoomModel]? = nil) {
        currentType = type
        updateUIForCurrentType()
        
        if type == .deviceFilter, let rooms = rooms {
            currentRooms = rooms
            updateRoomButtons()
        } else {
            buttonView?.isHidden = true
        }
    }
    
    private func updateUIForCurrentType() {
        switch currentType {
        case .common:
            buttonView?.isHidden = true
        case .deviceFilter:
            buttonView?.isHidden = false
        case .none:
            break
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

        } else {
            let newButtonView = HorizontalScrollingButtonsView(items: items)
            buttonView = newButtonView
            addSubview(newButtonView)
            setupButtonViewConstraints(newButtonView)
            newButtonView.onButtonTapped = { [weak self] index in
                print("Button tapped at index: \(index)")
                self?.onButtonTapped?(index)
            }

        }
    }
   
    private func setupButtonViewConstraints(_ buttonView: HorizontalScrollingButtonsView) {
        buttonView.snp.remakeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }

    
    deinit {
        print("SmartDeviceReusableView deinitialized")
    }
}
