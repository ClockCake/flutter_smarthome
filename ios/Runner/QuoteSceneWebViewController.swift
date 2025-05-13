//
//  QuoteSceneWebView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/7/4.
//

import UIKit
import WebKit
import RxSwift
import SnapKit

class QuoteSceneWebViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    // --- Web View ---
    public lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        webConfiguration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.uiDelegate = self // Needed for potential JS alerts/prompts
        return webView
    }()

    // --- Horizontal Scrolling Collection View ---
    private let cellReuseIdentifier = "BottomScrollCell"
    private let collectionViewHeight: CGFloat = 120 // Adjust height as needed
    private var scrollTimer: Timer?
    private var scrollOffset: CGFloat = 0
    //设备列表
    private var items:[ThingSmartDeviceModel] = []

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: collectionViewHeight - 20) // Adjust item size
        layout.minimumLineSpacing = 10 // Spacing between items
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Padding around the section
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .lightGray // Example background
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(BottomScrollCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier) // Register a custom cell
        return cv
    }()

    // --- Initialization ---
    init(title: String, isShowBack: Bool = true, models: [ThingSmartDeviceModel] = []) {
        self.items = models
        super.init(title: title, isShowBack: isShowBack) // Corrected isShowBack usage
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // --- View Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "装修案例" // Or use the title passed in init
        self.backArrowButton.isHidden = false
        setupViews()
        loadWebViewContent()

        self.view.bringSubviewToFront(customNavBar)
        self.titleLab.textColor = UIColor.black
        // backArrowButton.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    }

 

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoScroll() // Start scrolling when view is visible
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll() // Stop scrolling when view is not visible
    }

    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(collectionView) // Add collection view

        // --- Constraints ---
        // Collection View Constraints
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // Anchor to safe area bottom
            make.height.equalTo(collectionViewHeight)
        }

        // Web View Constraints (Updated)
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(customNavBar.snp.bottom)
            make.bottom.equalTo(collectionView.snp.top) // Anchor bottom to top of collection view
        }
    }

    private func loadWebViewContent() {
        if let url = URL(string: "https://vr.justeasy.cn/view/xz165se6x8k14880-1657179172.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // --- Auto Scrolling Logic ---
    private func startAutoScroll() {
        // Invalidate existing timer just in case
        stopAutoScroll()
        guard !items.isEmpty else { return } // Don't scroll if no items

        scrollTimer = Timer.scheduledTimer(timeInterval: 0.03, // Adjust interval for speed
                                           target: self,
                                           selector: #selector(autoScroll),
                                           userInfo: nil,
                                           repeats: true)
        // Add timer to the main run loop to ensure it fires during UI scrolling/tracking
        if let timer = scrollTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    @objc private func autoScroll() {
        guard let timer = scrollTimer, timer.isValid else {
            stopAutoScroll()
            return
        }

        let currentOffset = collectionView.contentOffset
        let maxOffset = collectionView.contentSize.width - collectionView.bounds.width + flowLayout.sectionInset.right // Include right inset

        guard maxOffset > 0 else { return } // Don't scroll if content doesn't exceed bounds

        var nextOffsetX = currentOffset.x + 0.5 // Adjust scroll step size

        // Reset to beginning if scrolled past the end
        if nextOffsetX >= maxOffset {
             nextOffsetX = 0 // Loop back to the start
             collectionView.setContentOffset(CGPoint(x: nextOffsetX, y: currentOffset.y), animated: false) // Jump instantly
        } else {
            collectionView.setContentOffset(CGPoint(x: nextOffsetX, y: currentOffset.y), animated: false) // Scroll smoothly (false prevents animation conflicts)
        }

        // Update internal tracking if needed, though direct setContentOffset is usually enough
        // scrollOffset = nextOffsetX
    }


    // Move deinit into the main class
    deinit {
        print("QuoteSceneWebViewController deinit")
        stopAutoScroll() // Ensure timer is stopped
        // Check if webView exists before trying to remove handler
        // This prevents potential crashes if deinit is called before webView is fully initialized
        // Although with lazy var, it should be initialized by the time deinit is called if it was accessed.
         webView.navigationDelegate = nil
         webView.uiDelegate = nil // Clean up delegate
         webView.stopLoading() // Stop any ongoing web loading
    }
}

// MARK: - WKNavigationDelegate & WKUIDelegate
extension QuoteSceneWebViewController: WKNavigationDelegate, WKUIDelegate { // Added WKUIDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Webview didStartProvisionalNavigation")
        // Add activity indicator start if needed
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Webview didFinish")
        // Add activity indicator stop if needed
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Webview didFail navigation: \(error.localizedDescription)")
        // Handle error
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Webview didFailProvisionalNavigation: \(error.localizedDescription)")
        // Handle error (e.g., server not found)
    }

    // Optional: Handle JavaScript alerts if the web page uses them
    // func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
    //     let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    //     alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler() }))
    //     present(alertController, animated: true, completion: nil)
    // }
}


// MARK: - WKScriptMessageHandler
extension QuoteSceneWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension QuoteSceneWebViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count // Use the example data count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? BottomScrollCollectionViewCell else {
            fatalError("Unable to dequeue BottomScrollCollectionViewCell")
        }
        cell.configure(with: items[indexPath.item]) // Configure the cell with data
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        let impl = ThingSmartBizCore.sharedInstance().service(of: ThingPanelProtocol.self) as? ThingPanelProtocol
        impl?.gotoPanelViewController(withDevice: model, group: nil, initialProps: nil, contextProps: nil, completion: nil)
    }

    // --- UIScrollViewDelegate Methods for Auto-Scroll Handling ---

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            stopAutoScroll() // Stop auto-scroll when user interacts
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == collectionView && !decelerate {
            // Restart timer only if deceleration finishes immediately
            startAutoScroll()
        }
    }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         if scrollView == collectionView {
             // Restart timer after deceleration finishes
              startAutoScroll()
         }
     }
}


// MARK: - Custom Collection View Cell (Example)
class BottomScrollCollectionViewCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()

    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.backgroundColor = .white // Placeholder color
        // Add a placeholder image if you have one
        // imgView.image = UIImage(named: "placeholder_icon")
        return imgView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white // Cell background
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        // Add subviews (Example: an image view and a label)
        contentView.addSubview(imageView)
        contentView.addSubview(label)

        // Constraints using SnapKit (adjust as needed)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(5)
            make.height.equalToSuperview().multipliedBy(0.6) // Image takes 60% height
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: ThingSmartDeviceModel) {
        self.imageView.kf.setImage(with: URL(string: text.iconUrl))
        self.label.text = text.name
    }
}
