//
//  FLQuoteViewFactory.swift
//  Runner
//
//  Created by huangyaodong on 2024/11/25.
//

import Flutter
import UIKit

// MARK: - Factory class for QuoteView
class FLQuoteViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var flutterViewController: FlutterViewController
    
    init(messenger: FlutterBinaryMessenger, flutterViewController: FlutterViewController) {
        self.messenger = messenger
        self.flutterViewController = flutterViewController
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLQuoteView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger,
            flutterViewController: flutterViewController
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - View class for QuoteView
class FLQuoteView: NSObject, FlutterPlatformView {
    private var _nativeView: UIView
    private var _viewController: QuickQuoteNumController?
    private var flutterViewController: FlutterViewController
    private var index = 0  // 0 是整装， 1 是 翻新 2 是软装
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger,
        flutterViewController: FlutterViewController
    ) {
        self.flutterViewController = flutterViewController
        _nativeView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kSafeHeight - kTabBarHeight))
        super.init()
        
        if let params = args as? [String: Any] {
            var width = params["initialWidth"] as? CGFloat ?? frame.width
            var height = params["initialHeight"] as? CGFloat ?? frame.height
            let tabBarHeight = params["tabBarHeight"] as? CGFloat ?? 49
            index = params["index"] as? Int ?? 0
            
            height -= tabBarHeight
            
            let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
            createNativeView(newFrame, params, tabBarHeight)
        } else {
            createNativeView(frame, nil, 49)
        }
    }
    
    func view() -> UIView {
        return _nativeView
    }
    
    private func createNativeView(_ frame: CGRect, _ arguments: Any?, _ tabBarHeight: CGFloat) {
        // 初始化你的报价页面控制器
        var type = QuickQuoteType.wholeHouse
        switch index {
        case 0:
            type = .wholeHouse
        case 1:
            type = .renovation
        case 2:
            type = .softDecoration
        default:
            type = .wholeHouse
        }
        _viewController = QuickQuoteNumController(title: "快速报价", isShowBack: true, type: type)
        
        if let viewController = _viewController {
            flutterViewController.addChild(viewController)
            
            // 设置视图大小
            viewController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - tabBarHeight)

            _nativeView.addSubview(viewController.view)
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
}
