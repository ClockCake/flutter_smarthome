import Flutter
import UIKit

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            messenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _nativeView: UIView
    private var _viewController: SmartDeviceHomeController?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _nativeView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kSafeHeight - kTabBarHeight))
//        UIView(frame: frame)
        super.init()
        
        if let params = args as? [String: Any] {
            var width = params["initialWidth"] as? CGFloat ?? frame.width
            var height = params["initialHeight"] as? CGFloat ?? frame.height
            
            // 获取 Flutter 传来的 tabBar 高度
            let tabBarHeight = params["tabBarHeight"] as? CGFloat ?? 49
            
            // 调整高度，减去 tabbar 的高度
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
        // 初始化视图控制器
        _viewController = SmartDeviceHomeController()
        
        if let viewController = _viewController {
            // 设置视图大小
//            viewController.view.frame = frame
            
            // 修改 collectionView 的 frame 和约束
            viewController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - tabBarHeight)
            viewController.collectionView.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(frame.height - tabBarHeight)
            }
            // 添加为子视图
            _nativeView.addSubview(viewController.view)
            
            // 确保子视图会随父视图调整大小
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
}
