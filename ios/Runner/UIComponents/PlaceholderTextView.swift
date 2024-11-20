//
//  PlaceholderTextView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/5/25.
//  

import UIKit
import RxSwift
import RxCocoa

class PlaceholderTextView: UITextView {
    
    private let placeholderLabel: UILabel = UILabel()
    private let disposeBag = DisposeBag()
    
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    override var text: String! {
        didSet {
            textViewDidChange()
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override var delegate: UITextViewDelegate? {
        didSet {
            super.delegate = self
        }
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.font = font
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = .clear
        addSubview(placeholderLabel)
        
        rx.text.orEmpty
            .subscribe(onNext: { [weak self] _ in
                self?.textViewDidChange()
            })
            .disposed(by: disposeBag)
        
        textContainerInsetObserver()
        textViewDidChange()
    }
    
    private func textContainerInsetObserver() {
        rx.observe(UIEdgeInsets.self, "textContainerInset")
            .subscribe(onNext: { [weak self] _ in
                self?.setNeedsLayout()
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = CGRect(
            x: textContainerInset.left + 4,
            y: textContainerInset.top,
            width: frame.width - textContainerInset.left - textContainerInset.right - 8,
            height: placeholderLabel.sizeThatFits(CGSize(width: frame.width - textContainerInset.left - textContainerInset.right - 8, height: CGFloat.greatestFiniteMagnitude)).height
        )
    }
    
    private func textViewDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

extension PlaceholderTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewDidChange()
    }
}


