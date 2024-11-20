//
//  DashLineView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/15.
//
import UIKit
import SnapKit

class DashLineView: UIView {
    
    enum LineStyle {
        case solid
        case dashed(dashLength: CGFloat, spaceLength: CGFloat)
    }
    
    private let shapeLayer = CAShapeLayer()
    
    var lineColor: UIColor = .lightGray {
        didSet {
            shapeLayer.strokeColor = lineColor.cgColor
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            shapeLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    
    var lineStyle: LineStyle = .solid {
        didSet {
            updateLineStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.addSublayer(shapeLayer)
        backgroundColor = .clear
        updateLineStyle()
    }
    
    private func updateLineStyle() {
        switch lineStyle {
        case .solid:
            shapeLayer.lineDashPattern = nil
        case .dashed(let dashLength, let spaceLength):
            shapeLayer.lineDashPattern = [NSNumber(value: Float(dashLength)), NSNumber(value: Float(spaceLength))]
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        
        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
    }
}
