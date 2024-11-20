//
//  ProgressHUDManager.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/14.
//

import UIKit
import MBProgressHUD

class ProgressHUDManager {
    // 单例
    static let shared = ProgressHUDManager()
    
    private init() {}
    
    
    // 显示加载指示器在指定视图中
    func showLoading(in view: UIView, message: String? = nil) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = message
    }
    
    // 显示加载指示器在window层
    func showLoadingOnWindow(message: String? = nil) {
        guard let window = LoadingHUD.keyWindow() else { return }
        showLoading(in: window, message: message)
    }
    
    // 显示自定义图片和消息在指定视图中
    func showCustomIcon(in view: UIView, iconName: String, message: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView
        if let image = UIImage(named: iconName) {
            hud.customView = UIImageView(image: image)
        }
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    // 显示自定义图片和消息在window层
    func showCustomIconOnWindow(iconName: String, message: String) {
        guard let window = LoadingHUD.keyWindow() else { return }
        showCustomIcon(in: window, iconName: iconName, message: message)
    }
    
    // 显示成功消息在指定视图中
    func showSuccess(in view: UIView, message: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
         hud.mode = .customView
         let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
         hud.customView = imageView
         hud.label.text = message
         hud.hide(animated: true, afterDelay: 2.0)
    }
    
    // 显示成功消息在window层
    func showSuccessOnWindow(message: String) {
        guard let window = LoadingHUD.keyWindow() else { return }
        showSuccess(in: window, message: message)
    }
    
    // 显示错误消息在指定视图中
    func showError(in view: UIView, message: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView
        let imageView = UIImageView(image: UIImage(systemName: "xmark"))
        hud.customView = imageView
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    // 显示错误消息在window层
    func showErrorOnWindow(message: String) {
        guard let window = LoadingHUD.keyWindow() else { return }
        showError(in: window, message: message)
    }
    
    // 显示消息并自动隐藏在指定视图中
    func showMessage(in view: UIView, message: String, delay: TimeInterval = 2.0) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = message
        hud.hide(animated: true, afterDelay: delay)
    }
    
    // 显示消息并自动隐藏在window层
    func showMessageOnWindow(message: String, delay: TimeInterval = 2.0) {
        guard let window = LoadingHUD.keyWindow() else { return }
        showMessage(in: window, message: message, delay: delay)
    }
    
    // 隐藏指定视图中的HUD
    func hideHUD(in view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    // 隐藏window层的HUD
    func hideHUDOnWindow() {
        guard let window = LoadingHUD.keyWindow() else { return }
        MBProgressHUD.hide(for: window, animated: true)
    }
}

