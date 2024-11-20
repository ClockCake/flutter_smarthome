//
//  SelectPackageTableView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/30.
//

import UIKit
import RxRelay
import Kingfisher
import RxSwift
class SelectPackageView: UIView {
    //回调不需要参数
    var closeCallBack:(() -> Void)?
    private let disposeBag = DisposeBag()
    private var savePackageList = BehaviorRelay<[PackageListModel]>(value: [])
    init(frame: CGRect,savePackageList:BehaviorRelay<[PackageListModel]>) {
        super.init(frame: frame)
        self.savePackageList = savePackageList
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(self.snp.bottom) // 初始位置在屏幕底部以下
        }
        showTableViewWithAnimation()
        // 立即更新约束
        self.layoutIfNeeded()
        
        
    }
    func showTableViewWithAnimation() {
        // 更新约束，将 tableView 移动到正确的位置
        let maxHeight = CGFloat(self.savePackageList.value.count) * 120.0 + 40.0 > (kScreenHeight / 3.0 * 2.0) ? (kScreenHeight / 3.0 * 2.0) : CGFloat(self.savePackageList.value.count) * 120.0 + 40.0
        //控制是否可滑动
        tableView.isScrollEnabled = CGFloat(self.savePackageList.value.count) * 120.0 + 40.0 > (kScreenHeight / 3.0 * 2.0) ? true : false
        
        tableView.snp.updateConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(-maxHeight)
        }

        // 使用动画效果显示 tableView
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded() // 这会触发约束的更新
        }, completion: nil)
    }
    init(savePackageList:BehaviorRelay<[PackageListModel]>) {
        self.savePackageList = savePackageList
        super.init(frame: .zero)
    
    }
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.register(SelectPackageCell.self, forCellReuseIdentifier: "SelectPackageCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        //只切割左上角和右上角
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        
        return tableView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectPackageView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savePackageList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPackageCell", for: indexPath) as! SelectPackageCell
        let model = self.savePackageList.value[indexPath.row]
        cell.selectionStyle = .none
        cell.model = model
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = .white

        let titleLab = UILabel.labelLayout(text: "已选方案", font: FontSizes.medium17, textColor: AppColors.c_222222, ali: .center, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let closeBtn = UIButton.init(image: UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal))
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        closeBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return  }

            //动画效果隐藏 tableView
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.tableView.snp.updateConstraints { make in
                    make.top.equalTo(self.snp.bottom)
                }
                self.layoutIfNeeded()
            }, completion: { _ in
                self.closeCallBack?()
            })
            
        }).disposed(by: disposeBag)
        
        return view
    }

}

class SelectPackageCell: UITableViewCell {
    public var model:PackageListModel?{
        didSet {
            setModel()
        }
    }
    private var imgView:UIImageView!
    private var nameLab:UILabel!
    private var titleLab:UILabel!
    private var priceLab:UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.medium14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        self.titleLab = titleLab
        
        let imgView = UIImageView.init()
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.leading.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(16)
            make.width.equalTo(93)
            make.height.equalTo(62)
        }
        imgView.layer.cornerRadius = 4
        imgView.layer.masksToBounds = true
        self.imgView = imgView
        
        let nameLab = UILabel.labelLayout(text: "", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        nameLab.numberOfLines = 1
        self.contentView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.leading.equalTo(imgView.snp.trailing).offset(16)
            make.top.equalTo(imgView.snp.top).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.nameLab = nameLab
        
        let priceLab = UILabel()
        self.contentView.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.leading.equalTo(nameLab)
            make.top.equalTo(nameLab.snp.bottom).offset(8)
        }
        self.priceLab = priceLab
    }
    
    func setModel() {
        guard let model = self.model else {
            return
        }
        self.titleLab.text = "\(model.name ?? "") \(model.areaNum ?? "")㎡"
        self.imgView.kf.setImage(with: URL(string: model.packagePic))
        self.nameLab.text = model.packageName
        
        let priceStr = model.basePrice
        let m2Str = "\(priceStr)元起"
        // 创建一个 NSMutableAttributedString 对象
        let attributedString = NSMutableAttributedString(string: m2Str)

        // 设置 priceStr 部分的属性
        let priceRange = (m2Str as NSString).range(of: "\(priceStr)")
        attributedString.addAttribute(.font, value: FontSizes.regular12, range: priceRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.c_FFA555, range: priceRange)

        // 设置其他部分的属性
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: FontSizes.medium18, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.c_FFA555, range: fullRange)

        // 避免覆盖 priceStr 部分的样式
        attributedString.addAttributes([.font: FontSizes.regular12, .foregroundColor: AppColors.c_999999], range: NSRange(location: 0, length: priceRange.location))
        attributedString.addAttributes([.font: FontSizes.regular12, .foregroundColor: AppColors.c_999999], range: NSRange(location: priceRange.location + priceRange.length, length: attributedString.length - (priceRange.location + priceRange.length)))
        self.priceLab.attributedText = attributedString
        
        
    }
}
