//
//  PaddingLabel.swift
//  JiJiaHuiClient
//
//  Created by 黄尧栋 on 2024/6/5.
//  主要功能是可以为文本添加内边距（padding）。通过这个类，你可以设置 UILabel 的文本内容四周的间距，使得文本不会紧贴着标签的边缘。

import UIKit

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textInsets.left + textInsets.right
        size.height += textInsets.top + textInsets.bottom
        return size
    }
}


