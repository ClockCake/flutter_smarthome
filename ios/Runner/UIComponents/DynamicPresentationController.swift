//
//  DynamicPresentationController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/3/20.
//
import UIKit

// 用于确定弹出样式的枚举
enum CustomPresentationStyle {
    case centered
    case bottomSheet
}

class DynamicPresentationController: UIPresentationController {
    var presentedViewSize: CGSize = .zero
    var customPresentationStyle: CustomPresentationStyle = .centered

    // 初始化时可以选择传入呈现样式和视图的尺寸
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, presentedViewSize: CGSize, style: CustomPresentationStyle) {
        self.presentedViewSize = presentedViewSize
        self.customPresentationStyle = style
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect() }
        
        switch customPresentationStyle {
        case .centered:
            // 计算中心弹出的位置
            let originX = (containerView.bounds.width - presentedViewSize.width) / 2
            let originY = (containerView.bounds.height - presentedViewSize.height) / 2
            return CGRect(x: originX, y: originY, width: presentedViewSize.width, height: presentedViewSize.height)

        case .bottomSheet:
            // 计算底部弹出的位置
            return CGRect(x: 0, y: containerView.bounds.height - presentedViewSize.height, width: containerView.bounds.width, height: presentedViewSize.height)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        // 确保 presentedView 充满整个屏幕
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    // 可以在这里添加一个背景视图，用来模糊或暗化背景
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: containerView!.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        containerView.insertSubview(backgroundView, at: 0)

        // 立即显示背景蒙层
        backgroundView.alpha = 1
        
        // 设置 presentedView 的初始位置在屏幕底部之外
        let finalFrame = frameOfPresentedViewInContainerView
        let initialFrame = CGRect(x: 0, y: containerView.bounds.height, width: finalFrame.width, height: finalFrame.height)
        presentedView.frame = initialFrame

        // 动画使 presentedView 从底部弹出
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            presentedView.frame = finalFrame
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.backgroundView.removeFromSuperview()
        })
    }
    
    @objc private func dismissController() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
