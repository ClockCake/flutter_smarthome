//
//  BaseWebController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/15.
//

import UIKit
import WebKit
enum BaseWebControllerType {
    case membership //会员特权
    case inviteMe //邀请活动
    case privacy //隐私政策
}

class BaseWebController: BaseViewController {
    private let type:BaseWebControllerType
    
    init(type: BaseWebControllerType) {
        self.type = type
        super.init(title: "", isShowBack: true)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        return webView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.view.bringSubviewToFront(customNavBar)
        self.titleLab.textColor = UIColor.white
        backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        
        switch type {
        case .membership:
            ProgressHUDManager.shared.showLoadingOnWindow()
            self.titleLab.text = "会员等级"
            if let url = URL(string: "https://npm.iweekly.top/membership") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        case .inviteMe:
            if let url = URL(string: "https://npm.iweekly.top/invite") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        case .privacy:
            //加载本地 HTML 文件
            titleLab.text = "隐私政策"
            backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)

            let path = Bundle.main.path(forResource: "privacy", ofType: "html")
            let url = URL(fileURLWithPath: path!)
            let request = URLRequest(url: url)
            webView.load(request)
            webView.snp.remakeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(customNavBar.snp.bottom)
            }
        default:
            break
        }
        
    }
}

extension BaseWebController:WKNavigationDelegate,UIScrollViewDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let js = """
//                    var stack = document.getElementById('infoStack');
//                    stack.style.marginTop = '\(kNavBarAndStatusBarHeight + 20)px';
//                """
 
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            webView.evaluateJavaScript(js) { (result, error) in
//                if error == nil {
//                    print("执行成功")
//                }else{
//                    print("执行失败")
//                }
//            }
//        }
//        
        ProgressHUDManager.shared.hideHUDOnWindow()

        
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        // 假设初始偏移量为0，即从顶部开始滚动
        let initialOffset: CGFloat = 0.0

        // 设置透明度变化的最大偏移量
        let maxOffsetForFullAlpha: CGFloat = 200.0 + kStatusBarHeight

        // 计算透明度
        // 当滚动偏移量大于初始偏移量时，透明度增加
        if type != .privacy {
            let alpha = offsetY > initialOffset ? min((offsetY - initialOffset) / maxOffsetForFullAlpha, 1) : 0
            let toBlackColor = UIColor.white.lerp(to: .black, amount: alpha)
            backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(toBlackColor, renderingMode: .alwaysOriginal), for: .normal)        // 应用透明度到 customNavBar
            customNavBar.backgroundColor = UIColor.white.withAlphaComponent(alpha)
            self.titleLab.textColor = toBlackColor
        }

    }
}
