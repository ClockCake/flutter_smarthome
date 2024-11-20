//
//  FamilyListCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/11.
//

import UIKit
import RxSwift
class FamilyListCell: UITableViewCell {
    private var titleLab:UILabel!
    private var styleLab:UILabel!
    private let disposeBag = DisposeBag()
    var model:PropertyInfo?{
        didSet{
            setModel()
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    func setUI(){
        let titleLab = UILabel.labelLayout(text: "锦绣小区", font: FontSizes.medium15, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        titleLab.numberOfLines = 0
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.titleLab = titleLab
        
        
        let styleLab = UILabel.labelLayout(text: "上海浦东新区・3室1厅1卫・120m²", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        styleLab.numberOfLines = 0
        self.contentView.addSubview(styleLab)
        styleLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.leading.equalTo(titleLab)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.styleLab = styleLab
        

        
        let lineView = UIView.init()
        lineView.backgroundColor = AppColors.c_F0F0F0
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(styleLab.snp.bottom).offset(16)
        }
        
    }
    
    func setModel(){
        guard let model = model else { return  }
        self.titleLab.text = model.address
        
        generateLayoutDescription(layout: model)
            .subscribe(onNext: { formattedString in
                self.styleLab.text = "\(model.address ?? "")・\(formattedString)・\(model.area ?? 0)㎡"
            })
            .disposed(by: disposeBag)

    }
    
    func generateLayoutDescription(layout: PropertyInfo) -> Observable<String> {
        return Observable.just(layout)
            .map { layout -> [(Int?, String)] in
                [
                    (layout.bedroomNumber, "室"),
                    (layout.livingRoomNumber, "厅"),
                    (layout.kitchenRoomNumber, "厨"),
                    (layout.toiletRoomNumber, "卫")
                ]
            }
            .map { rooms in
                rooms.compactMap { count, type in
                    guard let count = count, count > 0 else { return nil }
                    return "\(count)\(type)"
                }.joined()
            }
            .map { description in
                description.isEmpty ? "暂无布局信息" : description
            }
    }
}
