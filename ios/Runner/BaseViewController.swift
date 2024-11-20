//
//  BaseViewController.swift
//
//  Created by hyd on 2023/10/20.
//  基类 隐藏系统的导航，自定义导航，并实现手势返回

import UIKit
import RxSwift
import SnapKit
import RxCocoa
class BaseViewController: UIViewController {
    private let disposeBag = DisposeBag()
    /// 标题
    private let titleStr:String
    /// 返回按钮显示/不显示
    private var isShowBack:Bool
    /// 导航栏
    public  var customNavBar = UIView()
    /// 标题文本
    public  var titleLab:UILabel!
    ///返回按钮
    public  var backArrowButton:UIButton!
    
    init(title:String = "",isShowBack:Bool = true) {
        self.titleStr = title
        self.isShowBack = isShowBack
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // 隐藏系统导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
 
        setupEdgePanGesture()
        
        setupCustomNavBar()
        
        // 监听登录界面显示的通知
//        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen), name: Notification.Name("ShowLoginScreen"), object: nil)

    }
    //基类登录逻辑只用于 401，本地逻辑在子类单独处理
    @objc func showLoginScreen() {
        // 显示登录界面的逻辑
//        let vc = LoginViewController(title: "", loginType: .mobileNumberLogin)
//        vc.modalPresentationStyle = .fullScreen
//        //如果后续成功失败无其他不同逻辑，可以合并回调
//        vc.loginSuccessCallBack = { [weak self] in
//            guard let self = self else { return }
//            self.refreshData()
//        }
//        vc.loginFailureCallBack = { [weak self] in
//            guard let self = self else { return }
//            self.refreshData()
//        }
//        self.present(vc, animated: true, completion: nil)
    }
    
    // 新增: 刷新数据的方法（子类可以重写）
    @objc func refreshData() {
        print("Refreshing data for YourViewController")
        // 默认实现为空，子类可以根据需要重写此方法
    }

    deinit {
        print("deinit: \(self)")
        NotificationCenter.default.removeObserver(self)

    }
 
    func setupEdgePanGesture() {
        // 添加右滑返回手势
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePan.edges = .left
        self.view.addGestureRecognizer(edgePan)
        
    }
    //创建自定义导航栏
    func setupCustomNavBar() {
        let customNavBar = UIView()
        customNavBar.backgroundColor = UIColor.clear
        self.view.addSubview(customNavBar)
        // 添加到视图
        customNavBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(kNavBarAndStatusBarHeight)
        }
        self.customNavBar = customNavBar
        

        let backButton = UIButton.init()
        customNavBar.addSubview(backButton)
        backButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight + 8.0)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(30)
        }
        backButton.isHidden = !isShowBack
        self.backArrowButton = backButton
        
        backButton.rx.tap.withUnretained(self).subscribe(onNext: { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        

        
        let titleLab = UILabel.labelLayout(text: titleStr, font: FontSizes.medium18, textColor: .black, ali: .center, isPriority: true, tag: 0)
        customNavBar.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        self.titleLab = titleLab
        

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent // 设置为你需要的样式
    }
    @objc func handleEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            // 获取滑动的距离
            let translationX = recognizer.translation(in: self.view).x
           // print("滑动距离: \(translationX)")  // 调试输出
        } else if recognizer.state == .ended || recognizer.state == .cancelled {
            // 滑动结束，这里可以进行其他操作，比如 pop ViewController
            let translationX = recognizer.translation(in: self.view).x
            if translationX > self.view.bounds.width * 0.2 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
  
}


