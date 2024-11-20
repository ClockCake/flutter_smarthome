//
//  Screen.swift
//
//  Created by hyd on 2023/10/20.
//  屏幕相关

import UIKit
/// 屏幕宽
let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width

/// 屏幕高
let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height

/// 屏幕宽比
let kScaleX: CGFloat = kScreenWidth / 375

/// 屏幕高比
let kScaleY: CGFloat = kScreenHeight / 667

/// 判断是否是iPhone
let kIsPhone = (UIDevice.current.userInterfaceIdiom == .phone)

/// 判断是否是iPhoneX
let kIsPhoneX = (kScreenWidth >= 375 && kScreenHeight >= 812 && kIsPhone)


// 使用函数来获取状态栏高度
let kStatusBarHeight: CGFloat = getStatusBarHeight()


/// 导航栏高度
let kNavBarHeight: CGFloat = 44

/// 状态栏和导航栏总高度
let kNavBarAndStatusBarHeight: CGFloat = kStatusBarHeight + kNavBarHeight//(kIsPhoneX ? 88 : 64)

/// 底部安全高度
let kSafeHeight: CGFloat = (kIsPhoneX ? 34 : 0)

/// Tabbar高度
let kTabBarHeight: CGFloat = (kIsPhoneX ? (49 + kSafeHeight) : 49)

/// 导航条和Tabbar总高度
let kNavAndTabHeight: CGFloat = kNavBarAndStatusBarHeight + kTabBarHeight

let segmentedTabHeight = 50.0



// 获取状态栏高度的方法
func getStatusBarHeight() -> CGFloat {
    // 确保使用当前活动的 UIWindowScene
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        // 使用 statusBarManager 来获取状态栏高度
        return windowScene.statusBarManager?.statusBarFrame.height ?? 0
    }
    return 0
}
