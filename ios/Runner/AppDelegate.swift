import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    private let tuyaAppkey = "ktuupjsdgaheh7gtxhfn"
    private let tuyaSecretKey = "u73nktdvmrxd979aexxx5ug9khum9vhc"
    lazy var flutterEngine: FlutterEngine? = FlutterEngine(name: "my flutter engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let engine = flutterEngine else { return false }
        engine.run()
        
        FlutterUserPlugin.register(with: engine.registrar(forPlugin: "FlutterUserPlugin")!)
        GeneratedPluginRegistrant.register(with: engine)
        
        if let registrar = engine.registrar(forPlugin: "native_ios_view") {
            let factory = FLNativeViewFactory(messenger: registrar.messenger())
            registrar.register(factory, withId: "native_ios_view")
        }
        
        DispatchQueue.global().async {
            ThingSmartSDK.sharedInstance().start(withAppKey: self.tuyaAppkey, secretKey: self.tuyaSecretKey)
#if DEBUG
            ThingSmartSDK.sharedInstance().debugMode = true
#endif
        }
        
        ThingSmartUser.sharedInstance().login(byPhone: "86",
                                              phoneNumber: UserManager.shared.currentUser?.mobile ?? "",
                                              password: UserManager.shared.currentUser?.tuyaPwd ?? "",
                                              success: {
            print("tuya--login success")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginStatus"), object: nil)
        }, failure: { (error) in
            if let e = error {
                print("tuya--login failure: \(e)")
            }
        })
        
        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        // 创建导航控制器并隐藏导航栏
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        navigationController.navigationBar.isHidden = true  // 默认隐藏导航栏
        
        // 创建一个消息通道来控制导航栏的显示/隐藏
        let channel = FlutterMethodChannel(name: "com.yourapp.navigation",
                                           binaryMessenger: flutterViewController.binaryMessenger)
        
        channel.setMethodCallHandler { [weak navigationController] (call, result) in
            switch call.method {
            case "showNavigationBar":
                navigationController?.navigationBar.isHidden = false
                result(nil)
            case "hideNavigationBar":
                navigationController?.navigationBar.isHidden = true
                result(nil)
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
}
