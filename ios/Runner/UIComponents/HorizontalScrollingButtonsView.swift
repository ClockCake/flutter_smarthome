//
//  HorizontalScrollingButtonsView.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/8/20.
//

class HorizontalScrollingButtonsView: UIView {
    private let scrollView = UIScrollView()
    private var buttons: [UIButton] = []
    private let buttonSpacing: CGFloat = 20
    private let normalFont = FontSizes.regular14
    private let selectedFont = FontSizes.medium14
    
    private var selectedIndex: Int = 0  // 新增：跟踪选中的索引
    
    var onButtonTapped: ((Int) -> Void)?
    
    init(items: [String]) {
        super.init(frame: .zero)
        setupScrollView()
        createButtons(with: items)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateButtons(with items: [String]) {
        let previouslySelectedIndex = selectedIndex
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        createButtons(with: items)
        selectButton(at: previouslySelectedIndex)  // 保持原来的选中状态，但确保索引有效
    }
    
    private func createButtons(with items: [String]) {
        scrollView.subviews.forEach { $0.snp.removeConstraints() }
        
        var lastButton: UIButton?
        
        for (index, title) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(AppColors.c_999999, for: .normal)
            button.setTitleColor(AppColors.c_222222, for: .selected)
            button.titleLabel?.font = normalFont
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            scrollView.addSubview(button)
            buttons.append(button)
            
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(scrollView)
                if let lastButton = lastButton {
                    make.left.equalTo(lastButton.snp.right).offset(buttonSpacing)
                } else {
                    make.left.equalTo(scrollView).offset(20)
                }
                
                if index == items.count - 1 {
                    make.right.equalTo(scrollView).offset(-20)
                }
            }
            
            lastButton = button
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectButton(at: sender.tag)
        onButtonTapped?(sender.tag)
    }
    
    private func selectButton(at index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        print(index)
        buttons[selectedIndex].isSelected = false
        buttons[selectedIndex].titleLabel?.font = normalFont
        
        selectedIndex = index
        buttons[selectedIndex].isSelected = true
        buttons[selectedIndex].titleLabel?.font = selectedFont
        print(selectedIndex)
        scrollView.scrollRectToVisible(buttons[selectedIndex].frame, animated: true)
    }
    
    // 新增：允许外部设置选中的按钮
    func setSelectedButton(at index: Int) {
        selectButton(at: index)
    }
}
