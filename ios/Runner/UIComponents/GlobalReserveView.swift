//
//  GlobalReserveView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/16.
//  全局快速预约

import UIKit
import RxRelay
import Kingfisher
import RxSwift
class GlobalReserveView: UIView {
    private let disposeBag = DisposeBag()
    var closeCallBack:(() -> Void)?
    private var contentView:UIView!
    private var reserveBtn: UIButton!
    private var phoneTextField: UITextField!
    private let viewModel = FurnishViewModel()
    private var businessType:String = ""   //0:设计师  1：案例  2：动态  3：广告  4：文章（咨询） 5：活动 6：快速报价
    private var businessId:Int = 0
    
    init(frame: CGRect,businessType:String,businessId:Int = 0) {
        super.init(frame: frame)
        // 监听键盘事件
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.businessType = businessType
        self.businessId = businessId
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let contentView = UIView.init()
        contentView.backgroundColor = .white
        let cornerRadius: CGFloat = 12
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = cornerRadius
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(kScreenWidth)
            make.top.equalTo(self.snp.bottom) // 初始位置在屏幕底部以下

        }
        self.contentView = contentView
        
        let titleLab = UILabel.labelLayout(text: "免费领取设计方案", font: FontSizes.medium17, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(24)
        }
        
        //系统自带的SF Symbol 关闭图片
        let closeBtn = UIButton.init()
        closeBtn.setImage(UIImage.init(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = AppColors.c_666666
        contentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(36)
        }
        
        let nameView = UIView.init()
        nameView.backgroundColor = AppColors.c_F8F8F8
        nameView.layer.cornerRadius = 6
        nameView.layer.masksToBounds = true
        contentView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        let nameLab = UILabel.labelLayout(text: "姓名", font: FontSizes.regular14, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        nameView.addSubview(nameLab)
        nameLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        
        let nameTextField = UITextField(placeholder: "请输入您的姓名", font: FontSizes.regular14, textColor: AppColors.c_222222, borderStyle: .none, keyboardType: .default)
        nameTextField.textAlignment = .left
        nameView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalToSuperview().offset(104)
            make.height.equalTo(30)
        }

        let phoneView = UIView.init()
        phoneView.backgroundColor = AppColors.c_F8F8F8
        phoneView.layer.cornerRadius = 6
        phoneView.layer.masksToBounds = true
        contentView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        let phoneLab = UILabel()
        phoneLab.numberOfLines = 1
        // Create an attributed string for the asterisk
        let asteriskAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: AppColors.c_FF995B
        ]
        let asteriskString = NSAttributedString(string: "* ", attributes: asteriskAttributes)

        // Create an attributed string for the rest of the text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: AppColors.c_222222
        ]
        let textString = NSAttributedString(string: "联系方式", attributes: textAttributes)

        // Combine the attributed strings
        let combinedString = NSMutableAttributedString()
        combinedString.append(asteriskString)
        combinedString.append(textString)

        // Set the attributed text to the label
        phoneLab.attributedText = combinedString
        phoneView.addSubview(phoneLab)
        phoneLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        let phoneTextField = UITextField(placeholder: "请输入您的联系方式", font: FontSizes.regular14, textColor: AppColors.c_222222, borderStyle: .none, keyboardType: .numberPad)
        phoneTextField.textAlignment = .left
        phoneView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalToSuperview().offset(104)
            make.height.equalTo(30)
        }
        self.phoneTextField  = phoneTextField
        
        let reserveBtn = UIButton.init(title: "立即预约", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center, image: nil)
        reserveBtn.layer.cornerRadius = 6
        reserveBtn.layer.masksToBounds = true
        contentView.addSubview(reserveBtn)
        reserveBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-kSafeHeight - 20)
        }
        self.reserveBtn  = reserveBtn
        
        showViewWithAnimation()
        // 立即更新约束
        self.layoutIfNeeded()
        
        // 添加 phoneTextField 的文本变化监听
        phoneTextField.rx.text.orEmpty
            .map { [weak self] in self?.isValidPhoneNumber($0) ?? false }
            .subscribe(onNext: { [weak self] isValid in
                self?.updateButtonState(isEnabled: isValid)
            })
            .disposed(by: disposeBag)
        
        closeBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let self = self else { return  }
            self.dismissViewWithAnimation()
        }).disposed(by: disposeBag)
        
        reserveBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let param = ["businessType":self.businessType,"businessId":self.businessId,"userName":nameTextField.text ?? "", "userPhone":phoneTextField.text ?? "","userAddress": ""]
            self.viewModel.fetchQuickReservation(params: param)
            self.viewModel.submitSuccess.subscribe(onNext: { [weak self]  _ in
                guard let self = self else { return  }
                self.dismissViewWithAnimation()
                
            }).disposed(by: self.disposeBag)
            
        }).disposed(by: disposeBag)
                    
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        // 动画更新约束，使 contentView 上移
        UIView.animate(withDuration: 0.3) {
            self.contentView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(-200 - self.safeAreaInsets.bottom - keyboardHeight)
            }
            self.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // 键盘收起时恢复原状
        UIView.animate(withDuration: 0.3) {
            self.contentView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(-200 - self.safeAreaInsets.bottom)
            }
            self.layoutIfNeeded()
        }
    }
    func showViewWithAnimation() {
        // 更新约束，将 tableView 移动到正确的位置
        let maxHeight = 300 + kSafeHeight
        
        contentView.snp.updateConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(-maxHeight)
        }

        // 使用动画效果显示 tableView
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded() // 这会触发约束的更新
        }, completion: nil)
    }
    
    func dismissViewWithAnimation(){
        //动画效果隐藏 tableView
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.contentView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            self.closeCallBack?()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    private func updateButtonState(isEnabled: Bool) {
        reserveBtn.isEnabled = isEnabled
        reserveBtn.backgroundColor = isEnabled ? .black : AppColors.c_999999
    }
}
