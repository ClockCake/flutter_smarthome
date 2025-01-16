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
    private var decorations:[DecorationTypeModel]
    private var type:QuickQuoteType
    private var areaNum:String
    lazy var bottomView:UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.c_000000.withAlphaComponent(0.3)
        let btn = UIButton.init(title: "免费领取报价", backgroundColor: .black, titleColor: .white, font: FontSizes.medium15, alignment: .center, image: nil)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20 + kSafeHeight)
            make.height.equalTo(48)
        }
        btn.layer.cornerRadius = 6
        btn.layer.masksToBounds = true
        btn.rx.tap.withUnretained(self).subscribe(onNext: { owner, _ in
            let view = GlobalReserveView(frame: .zero,businessType:"6")
            //获取window
            let window = UIApplication.shared.windows.first
            window?.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            view.closeCallBack = {
                view.removeFromSuperview()

            }
            
        }).disposed(by: disposeBag)
        
        let bedRoomNumber = self.decorations.first { $0.type == .masterBedroom }?.number ?? 0
        let livingRoomNumber = self.decorations.first { $0.type == .livingDiningRoom }?.number ?? 0
        let toiletRoomNumber = self.decorations.first { $0.type == .masterBathroom }?.number ?? 0
        var title = ""
        if let num = Int(self.areaNum),num > 0 {
            title = "\(bedRoomNumber)室\(livingRoomNumber)厅\(toiletRoomNumber)卫・\(self.areaNum)m²"
        }else{
            title = "\(bedRoomNumber)室\(livingRoomNumber)厅"
        }
        let titleLab = UILabel.labelLayout(text: title, font: FontSizes.regular14, textColor: .white, ali: .left, isPriority: true, tag: 0)
        titleLab.numberOfLines = 0
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-64)
        }
        
        // 创建一个 NSMutableAttributedString
        let attributedString = NSMutableAttributedString()

        // 创建并添加第一个部分（数字部分，字号24）
        let largeFontAttribute: [NSAttributedString.Key: Any] = [
            .font: FontSizes.DINBoldFont24
        ]
        let numberString = NSAttributedString(string: "12", attributes: largeFontAttribute)
        attributedString.append(numberString)

        // 创建并添加第二个部分（其余部分，字号12）
        let smallFontAttribute: [NSAttributedString.Key: Any] = [
            .font: FontSizes.regular12
        ]
        let textString = NSAttributedString(string: "万起", attributes: smallFontAttribute)
        attributedString.append(textString)

        // 将富文本字符串设置为 UIButton 的标题
        let button = UIButton.init()
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "chevron.right")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.adjustTitleAndImage(spacing: 0)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        button.rx.tap.subscribe(onNext: { [weak self] in
            let vc = QuoteSchemeController.init(title: "", isShowBack: true, decorations: self?.decorations ?? [], type: self?.type ?? .wholeHouse, areaNum: self?.areaNum ?? "")
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        return view
    }()
     public lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        
        return webView
    }()
    
    init(title: String, isShowBack: Bool = true,decorations:[DecorationTypeModel],type:QuickQuoteType,areaNum:String) {
        self.decorations = decorations
        self.type = type
        self.areaNum = areaNum
        super.init(title: title, isShowBack: true)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "报价明细"
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //加载 URL
        if let url = URL(string: "https://npm.iweekly.top/preview") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.view.bringSubviewToFront(customNavBar)
        self.titleLab.textColor = UIColor.white
        backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        
        webView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(kSafeHeight + 130)
        }
        bottomView.isHidden = type == .none ? true : false


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskPath = UIBezierPath.init(roundedRect: bottomView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bottomView.bounds
        maskLayer.path = maskPath.cgPath
        bottomView.layer.mask = maskLayer
    }
}
extension QuoteSceneWebViewController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // let js = """
        //             var parentDiv = document.getElementById('krpanoSWFObject');
        //             var childDivs = parentDiv.getElementsByTagName('div');
        //             for (var i = 0; i < childDivs.length; i++) {
        //                 childDivs[i].style.overflow = 'hidden';
        //             }

        //             var like = document.getElementById('btn_like');
        //             like.style.display = 'none';
                    
        //             var scene = document.getElementById('show_scenes');
        //             scene.style.display = 'none';
        //         """
        
        // //延迟0.5 执行
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     webView.evaluateJavaScript(js) { (result, error) in
        //         if error == nil {
        //             print("执行成功")
        //         }else{
        //             print("执行失败")
        //         }
        //     }
        // }
 
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
}
