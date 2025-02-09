//
//  SmartDeviceHomeHeaderCell.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

import UIKit
import RxSwift
import Kingfisher
import WebKit
import RxGesture
class SmartDeviceHomeHeaderCell: UICollectionViewCell{
    private let disposeBag = DisposeBag()
    var toogleBtnAction: (() -> Void)?


    private var containerImageView:UIImageView!
    var titleLab:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        
        return webView
    }()
    func setUI(){
        self.backgroundColor = UIColor.white
        
        //加载 URL
        if let url = URL(string: "https://xjf7711.github.io/decoration/index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        self.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(kStatusBarHeight + 200)
        }
        
        let imageView = UIImageView(image: UIImage(named: "icon_smart_vr"))
        imageView.contentMode = .scaleAspectFit
        webView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        imageView.isUserInteractionEnabled = true
        imageView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return  }
            let vc = QuoteSceneWebViewController.init(title: "", isShowBack: false, areaNum: "")
            UINavigationController.getCurrentNavigationController()?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        let bgView = UIView.init()
        bgView.layer.cornerRadius = 6
        bgView.backgroundColor = .white
        // 添加阴影
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgView.layer.shadowOpacity = 0.1
        bgView.layer.shadowRadius = 6
        bgView.layer.masksToBounds = false
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom).offset(-35)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(73)
        }
        
        let img = UIImageView.init(image: UIImage(named: "icon_family_home"))
        bgView.addSubview(img)
        img.snp.makeConstraints { make in
            make.leading.equalTo(bgView).offset(16)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(18)
        }
        let titleLab = UILabel.labelLayout(text: "暂无项目", font: FontSizes.medium15, textColor: AppColors.c_222222, ali: .left, isPriority: true, tag: 0)
        titleLab.numberOfLines = 0
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(img.snp.trailing).offset(12)
//            make.top.equalToSuperview().offset(16)
            make.centerY.equalTo(bgView)
            make.trailing.equalToSuperview().offset(-48)
        }
        self.titleLab = titleLab

        
        let toggleBtn = UIButton.init(image: UIImage(named: "icon_family_toggle"))
        bgView.addSubview(toggleBtn)
        toggleBtn.snp.makeConstraints { make in
            make.trailing.equalTo(bgView).offset(-16)
            make.centerY.equalTo(bgView)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        toggleBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            guard let callback = self.toogleBtnAction else { return  }
            callback()
        }).disposed(by: disposeBag)
        

        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension SmartDeviceHomeHeaderCell:WKNavigationDelegate {
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
