//
//  LinearProgressBar.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/13.
//

import UIKit

class LinearProgressBar: UIView {
    // 进度条的进度
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsLayout() // 当进度改变时，需要重新布局
        }
    }
    
    // 进度条的填充颜色
    var progressTintColor: UIColor = AppColors.c_FFA555
    
    // 进度条的背景色
    var trackTintColor: UIColor = .white
    
    // 进度条的填充视图
    private let progressView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        layer.cornerRadius = frame.height / 2
        backgroundColor = trackTintColor
        
        progressView.backgroundColor = progressTintColor
        progressView.layer.cornerRadius = frame.height / 2
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let progressWidth = bounds.width * progress
        progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
    }
}
