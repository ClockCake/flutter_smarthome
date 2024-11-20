//
//  SmartDeviceListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

import UIKit
import RxSwift
import Kingfisher
class SmartDeviceListCell: UICollectionViewCell {
    public var model:ThingSmartDeviceModel?{
        didSet{
            setModel()
        }
    }
    private let disposeBag = DisposeBag()
    private var deviceIcon:UIImageView!
    private var controlBtn:UIButton!
    private var titleLab:UILabel!
    private var statusLab:UILabel!
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    //DP 快捷开关的回调
    var switchCallBack:((Bool)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = AppColors.c_F8F8F8
        self.contentView.layer.cornerRadius = 6
        self.contentView.layer.masksToBounds = true
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        let deviceIcon = UIImageView.init()
        self.contentView.addSubview(deviceIcon)
        deviceIcon.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.width.height.equalTo(60)
        }
        self.deviceIcon = deviceIcon
        
        let controlBtn = UIButton.init(image: UIImage(named: "icon_family_control_off"))
        controlBtn.isSelected = false
        controlBtn.backgroundColor = .clear
        self.contentView.addSubview(controlBtn)
        controlBtn.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        controlBtn.rx.tap.subscribe(onNext: { [weak self] in
            ///快捷开关的逻辑
            guard let self = self else { return  }
            controlBtn.isSelected = !controlBtn.isSelected
            let deviceGroup = ThingSmartDevice(deviceId: self.model?.devId ?? "")
            let dpsKey = self.model?.switchDps
            var dpsGroup = [String : Any]()
            for (_ ,key) in dpsKey!.enumerated(){
                let keyStr = "\(key)"
                let switchBool = controlBtn.isSelected ? true : false
                dpsGroup[keyStr] = switchBool
                
            }
            deviceGroup?.publishDps(dpsGroup, mode: ThingDevicePublishModeAuto, success: {
                // 触发震动反馈
                self.feedbackGenerator.impactOccurred()
                controlBtn.isSelected == true ? controlBtn.setImage(UIImage(named: "icon_family_control_on"), for: .normal) : controlBtn.setImage(UIImage(named: "icon_family_control_off"), for: .normal)
            }, failure: { error in
                ProgressHUDManager.shared.showErrorOnWindow(message: error?.localizedDescription ?? "操作失败")
            })

        }).disposed(by: disposeBag)
        
        self.controlBtn = controlBtn
        
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.regular13, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(deviceIcon.snp.bottom).offset(8)
        }
        self.titleLab = titleLab
        
        let statusLab = UILabel.labelLayout(text: "已关闭", font:  FontSizes.regular11, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(statusLab)
        statusLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
        }
        self.statusLab = statusLab
        
        // 准备反馈生成器
        feedbackGenerator.prepare()
    }
    
    func setModel(){
        guard let model = model else { return  }
        self.deviceIcon.kf.setImage(with: URL(string: model.iconUrl))
        self.titleLab.text = model.name
        if model.isOnline == true {
            self.statusLab.text = "在线"
            self.statusLab.textColor = AppColors.c_00C08A
        }
        else{
            self.statusLab.text = "已离线"
            self.statusLab.textColor = AppColors.c_999999
        }
        ///DP点检测
        if (model.switchDps.count >  0) && (model.isOnline == true){
            print("DPS----\(model.name ?? "")\(model.switchDps ?? [])")
            controlBtn.isHidden = false
            if model.dps["1"] as? Bool == true{
                controlBtn.isSelected = true
                controlBtn.setImage(UIImage(named: "icon_family_control_on"), for: .normal)
            }else{
                controlBtn.setImage(UIImage(named: "icon_family_control_off"), for: .normal)
                controlBtn.isSelected = false
            }
        }else{
            controlBtn.isHidden = true
        }
  
    }
    
    
}
