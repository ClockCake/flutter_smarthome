//
//  ContractDetailViewController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/23.
//  合同详情

import UIKit
import RxSwift
class ContractDetailViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = FurnishLogsViewModel()
    
    init(title: String = "", isShowBack: Bool = true,contractId:String) {
        super.init()
        self.viewModel.contractId.accept(contractId)
        self.view.backgroundColor = AppColors.c_F8F8F8
        setUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        let contentView = UIView()
        contentView.backgroundColor = AppColors.c_F8F8F8

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let topView = UIView()
        topView.backgroundColor = .white
        topView.layer.cornerRadius = 8
        topView.layer.masksToBounds = true
        contentView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
            make.height.equalTo(102)
        }
        
        let titleLab = UILabel.labelLayout(text: "", font: FontSizes.medium16, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        topView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
        }
        
        let planLab = UILabel.labelLayout(text: "", font: FontSizes.regular13, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        topView.addSubview(planLab)
        planLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
        }
        
        //合同编号
        let numLab = UILabel.labelLayout(text: "", font: FontSizes.regular13, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        topView.addSubview(numLab)
        numLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(planLab.snp.bottom).offset(12)
        }
        
        let button = UIButton.init(title: "查看项目清单 >", backgroundColor: .white, titleColor: AppColors.c_CA9C72, font: FontSizes.regular12, alignment: .right)
        topView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(numLab)
        }
        
        button.rx.tap.withUnretained(self).subscribe(onNext: { owner , _ in
            let vc = ProjectSegmentController.init(contractId: owner.viewModel.contractDetail.value?.contractId ?? "")
            owner.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        
        let middleView = UIView()
        middleView.backgroundColor = .white
        middleView.layer.cornerRadius = 12
        middleView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        contentView.addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(16)
        }
        
        let middleLab = UILabel.labelLayout(text: "合同总价", font: FontSizes.medium15, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        middleView.addSubview(middleLab)
        middleLab.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
        }
        
        let scanBtn = UIButton.init(title: "查看合同 >", backgroundColor: .white, titleColor: AppColors.c_CA9C72, font: FontSizes.regular12, alignment: .right)
        middleView.addSubview(scanBtn)
        scanBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(middleLab)
        }
        
        let stackView = UIStackView.init(axis: .vertical)
        middleView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(middleLab.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        let totalLab = UILabel.labelLayout(text: "", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .right, isPriority: true, tag: 0)
        middleView.addSubview(totalLab)
        totalLab.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        let tlab = UILabel.labelLayout(text: "合计：", font: FontSizes.regular12, textColor: AppColors.c_333333, ali: .right, isPriority: true, tag: 0)
        middleView.addSubview(tlab)
        tlab.snp.makeConstraints { make in
            make.centerY.equalTo(totalLab)
            make.trailing.equalTo(totalLab.snp.leading).offset(-8)
        }
        
        
        let bottomView = UIView.init()
        bottomView.backgroundColor = .white
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(middleView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        let bottomLab = UILabel.labelLayout(text: "付款方式", font: FontSizes.medium15, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        bottomView.addSubview(bottomLab)
        bottomLab.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        
        let listStackView = UIStackView.init(axis: .vertical)
        bottomView.addSubview(listStackView)
        listStackView.snp.makeConstraints { make in
            make.top.equalTo(bottomLab.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        //Rx 订阅赋值渲染
        self.viewModel.contractDetail.skip(1).subscribe(onNext: { [weak self] info in
            guard let self = self else { return  }
            //顶部
            self.titleLab.text = info?.contractTypeDisPlay ?? ""
            titleLab.text = info?.contractTypeDisPlay ?? ""
            planLab.text = "设计方案: \(info?.packageName ?? "")"
            numLab.text = "合同编号: \(info?.contractNo ?? "")"
            
            //中部
            totalLab.text = "¥\(info?.contractPrice ?? 0.0)"
            let titles = ["直接费","税金","服务费","优惠"]
            let values = ["¥\(info?.directPrice ?? 0.0)","¥\(info?.taxPrice ?? 0.0)","¥\(info?.managePrice ?? 0.0)","¥\(info?.discountPrice ?? 0.0)"]
            
            for (x,y) in zip(titles, values) {
                let view = self.creatMiddleSubView(left: x, right: y)
                stackView.addArrangedSubview(view)
                view.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(40)
                }
            }
            
        }).disposed(by: disposeBag)
        
        self.viewModel.contractPayList.skip(1).subscribe(onNext:{ [weak self] models in
            if models.count > 0 {
                //底部
                for (index,element) in models.enumerated() {
                    let view = self?.creatListStackSubView(index: index+1, price: element.price ?? 0.0, desc: element.type ?? "0")
                    listStackView.addArrangedSubview(view ?? UIView.init())
                    view?.snp.makeConstraints { make in
                        make.leading.trailing.equalToSuperview()
                        make.height.equalTo(50)
                    }
                }
            }
            else{
                bottomView.isHidden = true
                middleView.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(topView.snp.bottom).offset(16)
                    make.bottom.equalToSuperview().offset(-16)
                }
            }

            
        }).disposed(by: disposeBag)
        
    }
    
    func creatMiddleSubView(left:String,right:String) ->UIView{
        let view = UIView.init()
        view.backgroundColor = .white
        let titleLab = UILabel.labelLayout(text: left, font: FontSizes.regular14, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let valueLab = UILabel.labelLayout(text: right, font: FontSizes.regular14, textColor: AppColors.c_333333, ali: .right, isPriority: true, tag: 0)
        view.addSubview(valueLab)
        valueLab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        return view
    }
    
    func creatListStackSubView(index:Int,price:Double,desc:String) ->UIView {
        let view = UIView.init()
        view.backgroundColor = .white
        let indexLab = UILabel.labelLayout(text: "\(index).", font: FontSizes.DINBoldFont15, textColor: AppColors.c_FFB26D, ali: .left, isPriority: true, tag: 0)
        view.addSubview(indexLab)
        indexLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        let  priceLab = UILabel.labelLayout(text: "¥\(price)", font: FontSizes.medium14, textColor: AppColors.c_333333, ali: .left, isPriority: true, tag: 0)
        view.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(36)
        }
        
        let descLab = UILabel.labelLayout(text: "", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        view.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.leading.equalTo(priceLab)
            make.top.equalTo(priceLab.snp.bottom).offset(4)
        }
        switch Int(desc) {
        case 1:
            descLab.text = "一期"
        case 2:
            descLab.text = "二期"
        case 3:
            descLab.text = "三期"
        case 4:
            descLab.text = "四期"
        default:
            break
        }
        return view
    }
}
