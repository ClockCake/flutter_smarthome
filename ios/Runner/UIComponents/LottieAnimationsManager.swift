//
//  LottieAnimationsManager.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/16.
//

import UIKit
import Lottie

class LottieAnimationsManager {
    
    static let shared = LottieAnimationsManager()
    
    private var loadingAnimationView: LottieAnimationView?
    
    private init() {}
    
    // 显示加载动画
    func showLoading(on view: UIView) {
        if loadingAnimationView == nil {
            loadingAnimationView = LottieAnimationView(name: "lottie-loading")
            loadingAnimationView?.loopMode = .loop
            loadingAnimationView?.contentMode = .scaleAspectFit
        }
        
        guard let loadingAnimationView = loadingAnimationView else { return }
        
        if loadingAnimationView.superview == nil {
            loadingAnimationView.frame = view.bounds
            view.addSubview(loadingAnimationView)
        }
        
        loadingAnimationView.play()
    }
    
    // 隐藏加载动画
    func hideLoading() {
        loadingAnimationView?.stop()
        loadingAnimationView?.removeFromSuperview()
    }
    
    // 其他常用方法可以在这里添加
    func playAnimation(named name: String, on view: UIView, loopMode: LottieLoopMode = .playOnce)  ->LottieAnimationView{
        let animationView = LottieAnimationView(name: name)
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        view.addSubview(animationView)
        animationView.play { (finished) in
            if loopMode == .playOnce {
                animationView.removeFromSuperview()
            }
        }
        
        return animationView
    }
}
