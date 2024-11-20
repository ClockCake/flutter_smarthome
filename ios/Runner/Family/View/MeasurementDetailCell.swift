//
//  MeasurementDetailCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/22.
//

import UIKit
class MeasurementDetailCell: UITableViewCell {
    public var model: MeasurementDetailModel? {
        didSet {
            setModel()
        }
    }
    private var titleLab:UILabel!
    private var stackView:UIStackView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        let titleLab = UILabel.labelLayout(text: "| xxxx ", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        let stackView = UIStackView.init(axis: .vertical,spacing: 8)
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        self.titleLab = titleLab
        self.stackView = stackView
        
        
 
    }
    
    func creatSubView(leftStr:String,rightStr:String) -> UIView{
        let view = UIView.init()
        view.backgroundColor = .white
        
        let titleLab = UILabel.labelLayout(text: leftStr, font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let rightLab = UILabel.labelLayout(text: rightStr, font: FontSizes.regular14, textColor: AppColors.c_333333, ali: .right, isPriority: true, tag: 0)
        view.addSubview(rightLab)
        rightLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        return view
    }
    
    func setModel(){
        guard let model = model else { return }
        self.titleLab.text = "| \(model.roomTypeDisplay ?? "")"
        let _ = stackView.arrangedSubviews.map { $0.removeFromSuperview() }
        let titles = ["地面面积","墙面面积","地面周长","层高"]
        let values = ["\(model.landArea ?? 0.0)m²", "\(model.wallArea ?? 0.0)m²", "\(model.perimeter ?? 0.0)m","\(model.floorHeight ?? 0.0)m" ]
        for (x,y) in zip(titles, values) {
            let view = creatSubView(leftStr: x, rightStr: y)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(30)
            }
        }
        
    }
 }
