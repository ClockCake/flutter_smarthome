import Flutter
import Foundation

class FlutterUserPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example.app/user",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterUserPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        print("FlutterUserPlugin registered")
    }
    
    private let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Received method call: \(call.method)")
        
        switch call.method {
        case "syncUser":
            if let args = call.arguments as? [String: Any] {
                print("Received user data: \(args)")
                handleSyncUser(args)
                result(true)
            } else {
                print("Invalid arguments received")
                result(FlutterError(code: "INVALID_ARGS",
                                  message: "Invalid arguments",
                                  details: nil))
            }
            
        case "clearUser":
            print("Clearing user")
            UserManager.shared.handleLogoutOrTokenExpiration()
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleSyncUser(_ userData: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: userData) {
            print("Converting user data to JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")
            if let user = try? JSONDecoder().decode(UserModel.self, from: jsonData) {
                print("Successfully decoded user")
                UserManager.shared.isSyncing = true
                UserManager.shared.saveUser(user)
                UserManager.shared.isSyncing = false
            } else {
                print("Failed to decode user")
            }
        } else {
            print("Failed to convert user data to JSON")
        }
    }
}

// MARK: - UserManager
class UserManager {
    static let shared = UserManager()
    private let userDefaultsKey = "CurrentUser"
    private(set) var currentUser: UserModel?
    private let channel: FlutterMethodChannel?
    var isSyncing = false
    
    private init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let flutterEngine = appDelegate.flutterEngine {
            channel = FlutterMethodChannel(name: "com.example.app/user",
                                         binaryMessenger: flutterEngine.binaryMessenger)
        } else {
            channel = nil
        }
        
        loadUser()
    }
    
    func saveUser(_ user: UserModel) {
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            if !isSyncing {
                syncToFlutter()
            }
        }
    }
    
    func loadUser() {
        if let savedUser = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data,
           let loadedUser = try? JSONDecoder().decode(UserModel.self, from: savedUser) {
            currentUser = loadedUser
            if !isSyncing {
                syncToFlutter()
            }
        }
    }
    
    func updateUser(_ updateBlock: (inout UserModel) -> Void) {
        guard var user = currentUser else { return }
        updateBlock(&user)
        saveUser(user)
    }
    
    func handleLogoutOrTokenExpiration(isTokenExpired: Bool = false) {
        clearUser()
        
        if isTokenExpired {
            print("Token has expired.")
        } else {
            print("User logged out successfully.")
            ThingSmartUser.sharedInstance().loginOut({
                print("涂鸦登出成功")
            }, failure: { error in
                if let e = error {
                    print("涂鸦登出失败: \(e)")
                }
            })
            
            NotificationCenter.default.post(name: NSNotification.Name("loginStatus"), object: nil)
        }
    }
    
    private func clearUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        if !isSyncing {
            syncToFlutter()
        }
    }
    
    private func syncToFlutter() {
        guard let channel = channel else { return }
        
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user),
           let userDict = try? JSONSerialization.jsonObject(with: userData) {
            isSyncing = true
            channel.invokeMethod("userUpdated", arguments: userDict) { _ in
                self.isSyncing = false
            }
        } else {
            isSyncing = true
            channel.invokeMethod("userCleared", arguments: nil) { _ in
                self.isSyncing = false
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentUser?.accessToken != nil && !(currentUser?.accessToken?.isEmpty ?? true)
    }
    
    var accessToken: String? {
        return currentUser?.accessToken
    }
}
