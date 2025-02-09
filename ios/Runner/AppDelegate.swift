import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let tuyaAppkey = "ktuupjsdgaheh7gtxhfn"
    private let tuyaSecretKey = "u73nktdvmrxd979aexxx5ug9khum9vhc"
    lazy var flutterEngine: FlutterEngine? = FlutterEngine(name: "my flutter engine")
    
    var navigationChannel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let engine = flutterEngine else { return false }
        engine.run()
        
        FlutterUserPlugin.register(with: engine.registrar(forPlugin: "FlutterUserPlugin")!)
        GeneratedPluginRegistrant.register(with: engine)
        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)

        // 爱家
        if let registrar = engine.registrar(forPlugin: "native_ios_smartlife") {
            let factory = FLNativeViewFactory(messenger: registrar.messenger(), flutterViewController: flutterViewController)
            registrar.register(factory, withId: "native_ios_smartlife")
        }
        

        DispatchQueue.global().async {
            ThingSmartSDK.sharedInstance().start(withAppKey: self.tuyaAppkey, secretKey: self.tuyaSecretKey)
#if DEBUG
            ThingSmartSDK.sharedInstance().debugMode = true
#endif
        }

        // 创建导航控制器并隐藏导航栏
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        navigationController.navigationBar.isHidden = true  // 默认隐藏导航栏

        // 配置导航方法通道
        navigationChannel = FlutterMethodChannel(name: "com.smartlife.navigation",
                                                 binaryMessenger: flutterViewController.binaryMessenger)
        
        navigationChannel?.setMethodCallHandler { [weak navigationController] (call, result) in
            switch call.method {
            case "showNavigationBar":
                navigationController?.navigationBar.isHidden = false
                result(nil)
            case "hideNavigationBar":
                navigationController?.navigationBar.isHidden = true
                result(nil)
            case "popToFlutter":
                navigationController?.popViewController(animated: true)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // 登录消息通道
        let loginChannel = FlutterMethodChannel(name: "com.smartlife.app/login",
                                                binaryMessenger: flutterViewController.binaryMessenger)

        loginChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "tuyaLogin":
                guard let args = call.arguments as? [String: String],
                      let mobile = args["mobile"],
                      let password = args["password"] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Invalid arguments",
                                        details: nil))
                    return
                }
                
                // 执行涂鸦登录
                ThingSmartUser.sharedInstance().login(byPhone: "86",
                                                     phoneNumber: mobile,
                                                     password: password,
                                                     success: {
                    print("tuya--login success")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginStatus"),
                                                    object: nil)
                    result(true)
                }, failure: { (error) in
                    if let e = error {
                        print("tuya--login failure: \(e)")
                        result(FlutterError(code: "LOGIN_FAILED",
                                            message: e.localizedDescription,
                                            details: nil))
                    }
                })
                
            case "tuyaLogout":
                // 执行涂鸦退出登录
                ThingSmartUser.sharedInstance().loginOut({
                    print("涂鸦登出成功")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutStatus"),
                                                    object: nil)
                    result(true)
                }, failure: { (error) in
                    if let e = error {
                        print("涂鸦登出失败: \(e)")
                        result(FlutterError(code: "LOGOUT_FAILED",
                                            message: e.localizedDescription,
                                            details: nil))
                    }
                })
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        

        window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // 添加一个方法以便其他类可以调用 popToFlutter
    func popToFlutter() {
        navigationChannel?.invokeMethod("popToFlutter", arguments: nil)
    }
    
    // 添加一个方法来获取或创建 FlutterViewController
    func getRootFlutterViewController() -> FlutterViewController {
        if let rootVC = window?.rootViewController as? UINavigationController,
           let flutterVC = rootVC.viewControllers.first as? FlutterViewController {
            return flutterVC
        }
        // 如果没有找到，创建一个新的
        return FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
    }
    
    func navigateToFlutterRoute(_ route: String) {
        if let channel = navigationChannel {
            channel.invokeMethod(route, arguments: nil)
        }
    }
}

