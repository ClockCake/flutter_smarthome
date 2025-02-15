//
//  QuoteSceneWebView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/4.
//

import UIKit
import WebKit
import RxSwift
class QuoteSceneWebViewController: BaseViewController {
    private let disposeBag = DisposeBag()

    private var selectModel:ThingSmartDeviceModel?
    public lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        
        // Add JavaScript message handler
        let contentController = WKUserContentController()
        contentController.add(self, name: "lightToggle")
        webConfiguration.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        
        return webView
    }()
    
    init(title: String, isShowBack: Bool = true,model:ThingSmartDeviceModel) {
        self.selectModel = model
        super.init(title: title, isShowBack: true)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "装修案例"
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(customNavBar.snp.bottom)
        }
        //加载 URL
        if let url = URL(string: "http://erf.gazo.net.cn:8087/webExtension/#/case") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.view.bringSubviewToFront(customNavBar)
        self.titleLab.textColor = UIColor.black
//        backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
 
    
    // Move deinit into the main class
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "lightToggle")
    }
  
}
extension QuoteSceneWebViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
     
 
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    
  
}


// Add WKScriptMessageHandler
extension QuoteSceneWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
        if message.name == "lightToggle" {
            guard let dict = message.body as? [String: Any],
                  let isLightOn = dict["isLightOn"] as? Bool else {
                return
            }
            
            // Handle the light toggle event
            if let name = selectModel?.name {
                if isLightOn {
                    ///快捷开关的逻辑
                    let deviceGroup = ThingSmartDevice(deviceId: self.selectModel?.devId ?? "")
                    let dpsKey = self.selectModel?.switchDps
                    var dpsGroup = [String : Any]()
                    for (_ ,key) in dpsKey!.enumerated(){
                        let keyStr = "\(key)"
                        dpsGroup[keyStr] = isLightOn
                        
                    }
                    deviceGroup?.publishDps(dpsGroup, mode: ThingDevicePublishModeAuto, success: {

                    }, failure: { error in
                        ProgressHUDManager.shared.showErrorOnWindow(message: error?.localizedDescription ?? "操作失败")
                    })
                } else {
                    let deviceGroup = ThingSmartDevice(deviceId: self.selectModel?.devId ?? "")
                    let dpsKey = self.selectModel?.switchDps
                    var dpsGroup = [String : Any]()
                    for (_ ,key) in dpsKey!.enumerated(){
                        let keyStr = "\(key)"
                        dpsGroup[keyStr] = !isLightOn
                        
                    }
                    deviceGroup?.publishDps(dpsGroup, mode: ThingDevicePublishModeAuto, success: {

                    }, failure: { error in
                        ProgressHUDManager.shared.showErrorOnWindow(message: error?.localizedDescription ?? "操作失败")
                    })
                }
            }
        }
    }
}


