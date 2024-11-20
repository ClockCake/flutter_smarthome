//
//  FamilyDecorationLogController.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/4/11.
//

import UIKit
class FamilyDecorationLogController: BaseViewController {
    private var scrollView:UIScrollView!
    private var customerProjectId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLab.text = "装修日志"
        setTopBarUI()
        setContentView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func setTopBarUI(){
        let stackView = UIStackView(axis: .horizontal,spacing: 22)
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavBar.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        let images = ["icon_logs_liangfang","icon_logs_design","icon_logs_hetong","icon_logs_zhuangxiu","icon_logs_shouhou"]
        
        let names = ["量房信息","设计信息","合同信息","装修服务","售后保障"]
        
        for(index,(image,name)) in zip(images, names).enumerated() {
            let view = creatItemView(title: name, imageName: image,index: index)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo((kScreenWidth - 4 * 22 - 32) / 5.0)
            }
        }
        
    }
    
    /// 加载内容视图
    func setContentView(){
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: kNavBarAndStatusBarHeight + 72 + 30, width: kScreenWidth, height: kScreenHeight - kNavBarAndStatusBarHeight - 102))
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: kScreenWidth * 5, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        self.scrollView = scrollView
        self.view.addSubview(scrollView)
        
        //量房信息
        let measureRoomView = MeasureRoomView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: scrollView.frame.size.height),customerProjectId: customerProjectId ?? "")
        scrollView.addSubview(measureRoomView)
        
        //设计信息
        let designlogsView = DesignLogsView.init(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: scrollView.frame.size.height),customerProjectId: customerProjectId ?? "")
        scrollView.addSubview(designlogsView)
        
        //合同信息
        let contractLogsView = ContractLogsView.init(frame: CGRect(x: kScreenWidth * 2, y: 0, width: kScreenWidth, height: scrollView.frame.size.height),customerProjectId: customerProjectId ?? "")
        scrollView.addSubview(contractLogsView)
        
        //装修服务
        let decorationServiceView = DecorationServiceView.init(frame: CGRect(x: kScreenWidth * 3, y: 0, width: kScreenWidth, height: scrollView.frame.size.height))
        scrollView.addSubview(decorationServiceView)
        
        //售后保障
        let warrantyView = WarrantyView.init(frame: CGRect(x: kScreenWidth * 4, y: 0, width: kScreenWidth, height: scrollView.frame.size.height))
        scrollView.addSubview(warrantyView)
        
    }
    init(title:String = "",isShowBack:Bool = true,customerProjectId:String) {
        super.init(title: title, isShowBack: isShowBack)
        self.customerProjectId = customerProjectId
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func creatItemView(title:String,imageName:String,index:Int) ->UIView {
        let view = UIView.init()
        view.backgroundColor = .white
        view.tag = index
        let imageView  = UIImageView.init(image: UIImage(named: imageName))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        
        let titleLab = UILabel.labelLayout(text: title, font: FontSizes.regular12, textColor: AppColors.c_999999, ali: .center, isPriority: true, tag: 0)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
        view.isSelect = index == 0 ? true : false
        // 添加点击手势
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleItemViewTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    
    @objc func handleItemViewTap(_ gesture: UITapGestureRecognizer) {
        if let tappedView = gesture.view {
            // 切换选中状态
            let isSelected = !tappedView.isSelect
            tappedView.isSelect = isSelected
            
            // 确保其他views不被选中
            if let stackView = tappedView.superview as? UIStackView {
                for view in stackView.arrangedSubviews {
                    if view !== tappedView {
                        view.isSelect = false
                    }
                }
            }
            //定位scrollView的偏移量
            let index = tappedView.tag
            let offsetX = CGFloat(index) * kScreenWidth
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
    }
}

