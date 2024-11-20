//
//  SmartDeviceSegmentListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/29.
//

import UIKit
import Kingfisher
class SmartDeviceSegmentListCell: UITableViewCell {
    private var icon:UIImageView!
    private var nameLab:UILabel!
    var model:ThingSmartDeviceModel?{
        didSet{
            guard let model = model else { return }
            self.icon.kf.setImage(with: URL(string: model.iconUrl ?? ""))
            self.nameLab.text = model.name
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        self.contentView.backgroundColor = .white
        let icon = UIImageView.init()
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        self.icon = icon
        
        let nameLab = UILabel.labelLayout(text: "", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(icon.snp.trailing).offset(12)
        }
        self.nameLab = nameLab
        
        let lineView = UIView.init()
        lineView.backgroundColor = AppColors.c_F8F8F8
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
        }
        
        
    }
}
