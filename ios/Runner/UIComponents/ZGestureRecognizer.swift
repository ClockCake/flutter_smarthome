//
//  ZGestureRecognizer.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/9/3.
//  隐藏功能切换环境的手势

import UIKit

class ZGestureRecognizer: UIGestureRecognizer {
    private var points = [CGPoint]()
    private let minimumPoints = 15 // Reduced from 20
    private let tolerance: CGFloat = 0.7 // Increased from 0.5
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        points.removeAll()
        if let touch = touches.first {
            points.append(touch.location(in: view))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let newPoint = touch.location(in: view)
            if newPoint.distance(to: points.last ?? .zero) > 5 { // Only add points if they're far enough apart
                points.append(newPoint)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        print("Total points collected: \(points.count)")
        if isZShape() {
            print("Z Shape Detected")
            state = .recognized
        } else {
            print("Z Shape Not Detected")
            state = .failed
        }
    }
    
    private func isZShape() -> Bool {
        guard points.count >= minimumPoints else {
            print("Not enough points: \(points.count)")
            return false
        }
        
        let startPoint = points.first!
        let endPoint = points.last!
        let midPoint = points[points.count / 2]
        
        let isHorizontalTop = abs(startPoint.y - points[points.count / 4].y) < tolerance * (endPoint.y - startPoint.y)
        let isDiagonal = abs((midPoint.x - startPoint.x) / (midPoint.y - startPoint.y) - (endPoint.x - midPoint.x) / (endPoint.y - midPoint.y)) < tolerance * 2
        let isHorizontalBottom = abs(endPoint.y - points[3 * points.count / 4].y) < tolerance * (endPoint.y - startPoint.y)
        
        let isLeftToRight = endPoint.x > startPoint.x
        let hasSufficientWidth = abs(endPoint.x - startPoint.x) > 0.3 * view!.bounds.width
        
        print("isHorizontalTop: \(isHorizontalTop)")
        print("isDiagonal: \(isDiagonal)")
        print("isHorizontalBottom: \(isHorizontalBottom)")
        print("isLeftToRight: \(isLeftToRight)")
        print("hasSufficientWidth: \(hasSufficientWidth)")
        
        return isHorizontalTop && isDiagonal && isHorizontalBottom && isLeftToRight && hasSufficientWidth
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
