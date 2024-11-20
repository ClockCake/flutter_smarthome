//
//  LoadingHUD.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/3/21.
//

import UIKit
class LoadingHUD {
    static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    static func show() {
        if let window = keyWindow() {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: window, animated: true)
            }
        }
    }

    static func hide() {
        if let window = keyWindow() {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: window, animated: true)
            }
        }
    }
}

// Path: /JiJiaHuiClient/Extension/LoadingHUD.swift
