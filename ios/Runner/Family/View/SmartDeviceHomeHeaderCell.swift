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
    //点击回调
    var clickBtnAction: (() -> Void)?
    var model:PropertyInfo?{
        didSet{
            setModel()
            
        }
    }
    private var containerImageView:UIImageView!
    private var titleLab:UILabel!
    private var descLab:UILabel!
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
        if let url = URL(string: "https://vr.justeasy.cn/view/xz165se6x8k14880-1657179172.html") {
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
            let vc = QuoteSceneWebViewController.init(title: "", isShowBack: false, decorations: [], type: .none, areaNum: "")
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
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-48)
        }
        self.titleLab = titleLab
        
        let descLab = UILabel.labelLayout(text: "请先去ERP添加项目", font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .left, isPriority: true, tag: 0)
        descLab.numberOfLines = 0
        bgView.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.leading.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-48)
            
        }
        self.descLab = descLab
        
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
        
        bgView.rx.tapGesture().when(.recognized).subscribe(onNext: {  [weak self] _ in
            guard let self = self else { return  }
            guard let callback = self.clickBtnAction else { return  }
            callback()
        }).disposed(by: disposeBag)
        
    }
    
    func setModel(){
        guard let model = model else { return  }
        self.titleLab.text = model.address
        
        generateLayoutDescription(layout: model)
            .subscribe(onNext: { formattedString in
                self.descLab.text = "\(model.address ?? "")・\(formattedString)・\(model.area ?? 0)㎡"
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
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension SmartDeviceHomeHeaderCell:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
                    var parentDiv = document.getElementById('krpanoSWFObject');
                    var childDivs = parentDiv.getElementsByTagName('div');
                    for (var i = 0; i < childDivs.length; i++) {
                        childDivs[i].style.overflow = 'hidden';
                    }

                    var like = document.getElementById('btn_like');
                    like.style.display = 'none';
                    
                    var scene = document.getElementById('show_scenes');
                    scene.style.display = 'none';
                """
        
        //延迟0.5 执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            webView.evaluateJavaScript(js) { (result, error) in
                if error == nil {
                    print("执行成功")
                }else{
                    print("执行失败")
                }
            }
        }
 
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
}
